from flask import Flask, request, jsonify, send_file
import pandas as pd
import numpy as np
import os
from sentence_transformers import SentenceTransformer, util
from io import StringIO
import pickle
from datetime import timedelta
from sklearn.feature_extraction.text import TfidfVectorizer

app = Flask(__name__)

# Load schemes dataset
df_schemes = pd.read_csv("datasets/financial_inclusion_schemes_1000_v3.csv")
print("Available columns in schemes dataset:", df_schemes.columns.tolist())
df_schemes['text_blob'] = (
    df_schemes['scheme_goal'].fillna('') + ". " +
    df_schemes['eligibility'].fillna('') + ". " +
    df_schemes['benefits'].fillna('') + ". " +
    df_schemes['total_returns'].fillna('') + ". " +
    df_schemes['time_duration'].fillna('')
)
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

# Load investment data
df_investments = pd.read_csv("datasets/user_investments.csv")

def normalize_duration(text):
    text = str(text).lower()
    if "year" in text:
        return int(float(text.split()[0])) * 12
    elif "month" in text:
        return int(float((text.split()[0])))
    return None

def extract_return_range(return_text):
    if pd.isna(return_text) or 'n/a' in str(return_text).lower():
        return (None, None)
    try:
        rates = [float(s.strip().replace('%','')) for s in return_text.lower().replace("interest rate", "").replace("estimated", "").replace("~", "").replace("-", " to ").split("to") if s.strip()]
        if len(rates) == 2:
            return (min(rates), max(rates))
        elif len(rates) == 1:
            return (rates[0], rates[0])
    except:
        pass
    return (None, None)

# Preprocess investments
if not df_investments.empty:
    df_investments["duration_months"] = df_investments["time_duration"].apply(normalize_duration)
    df_investments[["return_min", "return_max"]] = df_investments["total_returns"].apply(lambda x: pd.Series(extract_return_range(x)))

def matches(dataframe, field, value):
    val = dataframe[field].fillna("All").astype(str).str.lower()
    return val.str.contains(value.lower()) | val.str.contains("all")

def age_matches(user_age, age_group_str):
    if user_age is None or not isinstance(user_age, int):
        return False
    if pd.isna(age_group_str) or 'all' in age_group_str.lower():
        return True
    parts = [a.strip() for a in age_group_str.split(',')]
    for part in parts:
        if '-' in part:
            try:
                low, high = map(int, part.split('-'))
                if low <= user_age <= high:
                    return True
            except Exception:
                continue
        elif '+' in part:
            try:
                if user_age >= int(part.replace('+', '')):
                    return True
            except Exception:
                continue
    return False

def filter_by_profile(user, df):
    income_field = "annual_income_group" if "annual_income_group" in df.columns else ("income_group" if "income_group" in df.columns else None)
    income_match = matches(df, income_field, user["income_group"]) if income_field else True
    return df[
        (matches(df, "gender", user["gender"])) &
        (matches(df, "social_category", user["social_category"])) &
        income_match &
        (matches(df, "location", user["location"])) &
        (df["age_group"].fillna("All").apply(lambda ag: age_matches(user["age"], ag)))
    ].reset_index(drop=True)

def filter_eligible_schemes(user, df):
    """More lenient filtering for eligible schemes - considers 'All' values and partial matches"""
    
    # Age filtering - more lenient
    age_filter = df["age_group"].fillna("All").apply(lambda ag: age_matches(user["age"], ag) or pd.isna(ag) or 'all' in str(ag).lower())
    
    # Gender filtering - include 'All' gender schemes
    gender_filter = (
        df["gender"].fillna("All").astype(str).str.lower().str.contains("all") |
        df["gender"].fillna("All").astype(str).str.lower().str.contains(user["gender"].lower()) |
        pd.isna(df["gender"])
    )
    
    # Social category filtering - include 'All' category schemes
    social_filter = (
        df["social_category"].fillna("All").astype(str).str.lower().str.contains("all") |
        df["social_category"].fillna("All").astype(str).str.lower().str.contains(user["social_category"].lower()) |
        pd.isna(df["social_category"])
    )
    
    # Income filtering - include 'All' income schemes
    income_field = "annual_income_group" if "annual_income_group" in df.columns else ("income_group" if "income_group" in df.columns else None)
    if income_field and user["income_group"]:
        income_filter = (
            df[income_field].fillna("All").astype(str).str.lower().str.contains("all") |
            df[income_field].fillna("All").astype(str).str.lower().str.contains(user["income_group"].lower()) |
            pd.isna(df[income_field])
        )
    else:
        income_filter = pd.Series([True] * len(df))
    
    # Location filtering - include 'All' location schemes
    location_filter = (
        df["location"].fillna("All").astype(str).str.lower().str.contains("all") |
        df["location"].fillna("All").astype(str).str.lower().str.contains(user["location"].lower()) |
        pd.isna(df["location"])
    )
    
    return df[age_filter & gender_filter & social_filter & income_filter & location_filter].reset_index(drop=True)

def recommend_schemes(user_profile, user_text_description, top_k=None):
    """Return eligible schemes sorted by similarity score (eligibility filtering + AI ranking)"""
    user_embedding = model.encode(user_text_description, convert_to_tensor=True)

    # First filter by eligibility using the lenient filtering approach
    eligible_df = filter_eligible_schemes(user_profile, df_schemes)
    
    # If very few eligible schemes, fall back to broader criteria
    if len(eligible_df) < 10:
        print(f"Only {len(eligible_df)} eligible schemes found, using broader criteria...")
        age_filter = df_schemes["age_group"].fillna("All").apply(lambda ag: age_matches(user_profile["age"], ag) or pd.isna(ag) or 'all' in str(ag).lower())
        eligible_df = df_schemes[age_filter].reset_index(drop=True)
        print(f"Broader criteria found {len(eligible_df)} schemes")
    
    # Now rank the eligible schemes by AI similarity to search text
    search_df = eligible_df
    search_texts = (
        search_df['scheme_goal'].fillna('') + ". " +
        search_df['eligibility'].fillna('') + ". " +
        search_df['benefits'].fillna('') + ". " +
        search_df['total_returns'].fillna('') + ". " +
        search_df['time_duration'].fillna('')
    ).tolist()
    search_embeddings = model.encode(search_texts, convert_to_tensor=True)

    similarities = util.pytorch_cos_sim(user_embedding, search_embeddings)[0].cpu().numpy()
    
    # Sort eligible schemes by similarity score (best matches first)
    top_indices = np.argsort(similarities)[::-1]
    
    # If top_k is specified, limit results, otherwise return all
    if top_k:
        top_indices = top_indices[:top_k]
    
    recommended = search_df.iloc[top_indices].copy()
    recommended["similarity_score"] = similarities[top_indices]

    # Select available columns safely
    base_columns = ["scheme_name", "scheme_goal", "benefits", "total_returns", "time_duration", "scheme_website"]
    available_columns = [col for col in base_columns if col in recommended.columns]
    available_columns.append("similarity_score")  # Always add similarity score for ML results

    return recommended[available_columns]

@app.route("/recommend", methods=["POST"])
def recommend():
    data = request.get_json()
    required_fields = {"age", "gender", "social_category", "income_group", "location", "situation"}
    if not required_fields.issubset(set(data)):
        return jsonify({"error": f"Missing fields. Required: {', '.join(required_fields)}"}), 400

    try:
        age = int(data.get("age", "")) if str(data.get("age", "")).strip().isdigit() else None
    except Exception:
        age = None

    income_group = data.get("income_group") or data.get("annual_income_group") or ""

    user_profile = {
        "age": age,
        "gender": data.get("gender", ""),
        "social_category": data.get("social_category", ""),
        "income_group": income_group,
        "location": data.get("location", "")
    }
    user_text = data["situation"]

    # Return all matching schemes (no limit on top_k)
    result_df = recommend_schemes(user_profile, user_text, top_k=None)

    def clean_json(obj):
        if isinstance(obj, dict):
            return {k: clean_json(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [clean_json(v) for v in obj]
        elif isinstance(obj, float) and (np.isnan(obj) or np.isinf(obj)):
            return "N/A"
        return obj

    result_json = clean_json(result_df.to_dict(orient="records"))
    return jsonify({
        "recommended_schemes": result_json, 
        "count": len(result_json),
        "filter_type": "ml_powered",
        "sorted_by": "similarity_score"
    })

@app.route("/eligible_schemes", methods=["POST"])
def eligible_schemes():
    """Fast rule-based filtering for initial page load without ML processing"""
    data = request.get_json()
    required_fields = {"age", "gender", "social_category", "income_group", "location"}
    if not required_fields.issubset(set(data)):
        return jsonify({"error": f"Missing fields. Required: {', '.join(required_fields)}"}), 400

    try:
        age = int(data.get("age", "")) if str(data.get("age", "")).strip().isdigit() else None
    except Exception:
        age = None

    income_group = data.get("income_group") or data.get("annual_income_group") or ""

    user_profile = {
        "age": age,
        "gender": data.get("gender", ""),
        "social_category": data.get("social_category", ""),
        "income_group": income_group,
        "location": data.get("location", "")
    }

    print(f"User profile for eligibility: {user_profile}")

    # Use lenient rule-based filtering (includes schemes marked as "All" for any criteria)
    filtered_df = filter_eligible_schemes(user_profile, df_schemes)
    print(f"Initial eligible schemes found: {len(filtered_df)}")
    
    # If still very few schemes, fallback to even broader criteria
    if len(filtered_df) < 5:
        print("Too few schemes found, using broader criteria...")
        # Just filter by age and include schemes open to all demographics
        age_filter = df_schemes["age_group"].fillna("All").apply(lambda ag: age_matches(user_profile["age"], ag) or pd.isna(ag) or 'all' in str(ag).lower())
        filtered_df = df_schemes[age_filter].reset_index(drop=True)
        print(f"Broader criteria schemes found: {len(filtered_df)}")
    
    # Sort schemes by scheme name for consistent ordering (alphabetical)
    filtered_df = filtered_df.sort_values('scheme_name').reset_index(drop=True)
    
    # Return ALL eligible schemes (no artificial limit)
    # The Flutter app will handle pagination on the frontend
    
    # Select relevant columns for display (only include columns that exist)
    available_columns = ["scheme_name", "scheme_goal", "benefits", "total_returns", "time_duration", "scheme_website"]
    optional_columns = ["risk", "eligibility", "application_process", "required_documents", "funding_agency", "contact_details"]
    
    # Add optional columns if they exist in the dataframe
    for col in optional_columns:
        if col in filtered_df.columns:
            available_columns.append(col)
    
    result_df = filtered_df[available_columns].copy()

    def clean_json(obj):
        if isinstance(obj, dict):
            return {k: clean_json(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [clean_json(v) for v in obj]
        elif isinstance(obj, float) and (np.isnan(obj) or np.isinf(obj)):
            return "N/A"
        return obj

    result_json = clean_json(result_df.to_dict(orient="records"))
    print(f"Returning {len(result_json)} eligible schemes")
    
    return jsonify({
        "eligible_schemes": result_json, 
        "count": len(result_json),
        "filter_type": "rule_based",
        "sorted_by": "scheme_name"
    })

@app.route("/chatbot", methods=["POST"])
def chatbot():
    data = request.get_json()
    question = data.get("question", "").strip()
    if not question:
        return jsonify({"answer": "Please provide a question."}), 400

    question_embedding = model.encode(question, convert_to_tensor=True)
    scheme_texts = df_schemes['text_blob'].tolist()
    scheme_embeddings = model.encode(scheme_texts, convert_to_tensor=True)
    similarities = util.pytorch_cos_sim(question_embedding, scheme_embeddings)[0].cpu().numpy()
    top_indices = np.argsort(similarities)[::-1][:3]
    top_schemes = df_schemes.iloc[top_indices]

    answer = "Here are the most relevant schemes I found for your question:\n\n"
    for idx, row in top_schemes.iterrows():
        answer += f"📄 {row['scheme_name']}\n"
        if pd.notna(row['scheme_goal']):
            answer += f"Goal: {row['scheme_goal']}\n"
        if pd.notna(row['eligibility']):
            answer += f"Eligibility: {row['eligibility']}\n"
        if pd.notna(row['benefits']):
            answer += f"Benefits: {row['benefits']}\n"
        if pd.notna(row['total_returns']):
            answer += f"Returns: {row['total_returns']}\n"
        if pd.notna(row['time_duration']):
            answer += f"Duration: {row['time_duration']}\n"
        if pd.notna(row['scheme_website']):
            answer += f"Website: {row['scheme_website']}\n"
        answer += "\n"
    return jsonify({"answer": answer.strip()})

@app.route("/debug_data", methods=["GET"])
def debug_data():
    """Debug endpoint to check dataset structure"""
    sample_data = df_schemes.head(5).to_dict(orient="records")
    
    # Check unique values in key columns
    debug_info = {
        "total_schemes": len(df_schemes),
        "columns": df_schemes.columns.tolist(),
        "sample_schemes": sample_data,
        "unique_genders": df_schemes["gender"].value_counts().head(10).to_dict() if "gender" in df_schemes.columns else "No gender column",
        "unique_social_categories": df_schemes["social_category"].value_counts().head(10).to_dict() if "social_category" in df_schemes.columns else "No social_category column",
        "unique_age_groups": df_schemes["age_group"].value_counts().head(10).to_dict() if "age_group" in df_schemes.columns else "No age_group column",
        "unique_locations": df_schemes["location"].value_counts().head(10).to_dict() if "location" in df_schemes.columns else "No location column"
    }
    
    # Check for income-related columns
    income_columns = [col for col in df_schemes.columns if 'income' in col.lower()]
    debug_info["income_columns"] = income_columns
    
    return jsonify(debug_info)

# Load ML models safely
try:
    amount_model = pickle.load(open("models/amount_prediction_model.pkl", "rb"))
    duration_model = pickle.load(open("models/duration_prediction_model.pkl", "rb"))
    models_available = True
    print("ML models loaded successfully")
except FileNotFoundError as e:
    print(f"ML models not found: {e}")
    amount_model = None
    duration_model = None
    models_available = False

# Initialize vectorizer for ML predictions
try:
    vectorizer = pickle.load(open("models/vectorizer.pkl", "rb"))
    print("Vectorizer loaded successfully")
except FileNotFoundError:
    # Create a simple vectorizer if model file doesn't exist
    print("Vectorizer not found, creating new one")
    vectorizer = TfidfVectorizer(max_features=1000, stop_words='english')
    # Fit on scheme text data
    scheme_texts = df_schemes['text_blob'].fillna('').tolist()
    vectorizer.fit(scheme_texts)

@app.route("/predict_limits", methods=["GET"])
def predict_limits():
    """Predict recommended amount and duration for a scheme"""
    scheme_name = request.args.get("scheme_name", "").strip().lower()
    if not scheme_name:
        return jsonify({"error": "Scheme name is required."}), 400

    # If models are not available, return default values
    if not models_available:
        return jsonify({
            "predicted_amount": 5000.0,
            "predicted_duration_months": 12
        })

    def normalize(text):
        return " ".join(text.lower().strip().split())

    normalized_query = normalize(scheme_name)
    df_schemes["normalized_name"] = df_schemes["scheme_name"].astype(str).apply(normalize)
    matched = df_schemes[df_schemes["normalized_name"] == normalized_query]

    if matched.empty:
        return jsonify({"error": f"Scheme '{scheme_name}' not found."}), 404

    scheme = matched.iloc[0]
    combined_text = " ".join([
        str(scheme.get("scheme_goal", "")),
        str(scheme.get("benefits", "")),
        str(scheme.get("application_process", ""))
    ])

    try:
        X_vectorized = vectorizer.transform([combined_text])
        predicted_amount = float(amount_model.predict(X_vectorized)[0])
        predicted_duration = int(duration_model.predict(X_vectorized)[0])

        return jsonify({
            "predicted_amount": round(predicted_amount, 2),
            "predicted_duration_months": predicted_duration
        })
    except Exception as e:
        print(f"Prediction error: {e}")
        # Fallback values if prediction fails
        return jsonify({
            "predicted_amount": 5000.0,
            "predicted_duration_months": 12
        })

@app.route("/scheme_detail", methods=["GET"])
def scheme_detail():
    scheme_name = request.args.get("name", "").strip().lower()
    if not scheme_name:
        return jsonify({"error": "Scheme name is required."}), 400

    def normalize(text):
        return " ".join(text.lower().strip().split())

    normalized_query = normalize(scheme_name)
    df_schemes["normalized_name"] = df_schemes["scheme_name"].astype(str).apply(normalize)
    matched = df_schemes[df_schemes["normalized_name"] == normalized_query]

    if matched.empty:
        return jsonify({"error": f"Scheme '{scheme_name}' not found."}), 404

    scheme = matched.iloc[0].to_dict()
    scheme_duration = normalize_duration(scheme.get("time_duration"))
    ret_min, ret_max = extract_return_range(scheme.get("total_returns"))

    def is_similar(row):
        dur_similar = scheme_duration is not None and row["duration_months"] is not None and abs(row["duration_months"] - scheme_duration) <= 6
        return_similar = (
            ret_min is not None and ret_max is not None and
            row["return_min"] is not None and row["return_max"] is not None and
            not (row["return_max"] < ret_min or row["return_min"] > ret_max)
        )
        return dur_similar and return_similar

    similar_investments = df_investments[df_investments.apply(is_similar, axis=1)]
    scheme["similar_investments"] = similar_investments[[
        "investment_type", "investment_name", "investment_amount",
        "total_returns", "time_duration", "current_value"
    ]].to_dict(orient="records")

    def clean(val):
        if isinstance(val, list):
            return [clean(v) for v in val]
        elif isinstance(val, dict):
            return {k: clean(v) for k, v in val.items()}
        elif pd.isna(val):
            return "N/A"
        return val

    return jsonify({k: clean(v) for k, v in scheme.items()})

@app.route("/register_scheme", methods=["POST"])
def register_scheme():
    data = request.get_json()
    scheme_name = data.get("scheme_name")
    amount_paid = data.get("amount_paid")
    start_date = data.get("start_date")

    if not scheme_name:
        return jsonify({"error": "Missing scheme_name"}), 400

    def normalize(text):
        return " ".join(text.lower().strip().split())

    norm_name = normalize(scheme_name)
    df_schemes["normalized_name"] = df_schemes["scheme_name"].astype(str).apply(normalize)
    match = df_schemes[df_schemes["normalized_name"] == norm_name]

    if match.empty:
        return jsonify({"error": f"Scheme '{scheme_name}' not found."}), 404

    scheme = match.iloc[0]
    
    # Use model predictions if available, otherwise use defaults
    if models_available:
        try:
            combined_text = " ".join([
                str(scheme.get("scheme_goal", "")),
                str(scheme.get("benefits", "")),
                str(scheme.get("application_process", ""))
            ])

            X_vectorized = vectorizer.transform([combined_text])
            predicted_amount = float(amount_model.predict(X_vectorized)[0])
            predicted_duration = int(duration_model.predict(X_vectorized)[0])
        except Exception as e:
            print(f"Model prediction failed: {e}")
            predicted_amount = 5000.0
            predicted_duration = 12
    else:
        predicted_amount = 5000.0
        predicted_duration = 12

    response = {
        "scheme_name": scheme_name,
        "predicted_amount": round(predicted_amount, 2),
        "predicted_duration_months": predicted_duration
    }

    lower_bound = 0.8 * predicted_amount
    upper_bound = 1.2 * predicted_amount

    if amount_paid:
        try:
            paid = float(amount_paid)
            response["user_entered_amount"] = paid
            if not (lower_bound <= paid <= upper_bound):
                response["note"] = f"Your entered amount ₹{paid} seems off. Based on scheme details, we recommend around ₹{round(predicted_amount, 2)}."
            else:
                response["note"] = "Your entered amount is within expected range."
        except ValueError:
            response["note"] = "Invalid amount entered. Using predicted amount."
    else:
        response["note"] = "No amount entered. Using predicted amount."

    print(f"[REGISTERED] Scheme: {scheme_name} | Recommended Amount: ₹{predicted_amount} | Duration: {predicted_duration} months | Start: {start_date}")

    return jsonify({
        "message": "Registration successful (with smart amount and duration prediction).",
        "details": response
    }), 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
