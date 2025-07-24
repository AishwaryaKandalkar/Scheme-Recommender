from flask import Flask, request, jsonify, send_file
import pandas as pd
import numpy as np
import os
from sentence_transformers import SentenceTransformer, util
from io import StringIO
import pickle
from datetime import timedelta
from sklearn.feature_extraction.text import TfidfVectorizer
from dotenv import load_dotenv

# Load environment variables from .env file if present
load_dotenv()

# Get configuration from environment variables
PORT = int(os.getenv('PORT', 5000))
HOST = os.getenv('HOST', '0.0.0.0')
DATASET_PATH = os.getenv('DATASET_PATH', 'datasets')
MODELS_PATH = os.getenv('MODELS_PATH', 'models')

app = Flask(__name__)

# Load schemes dataset
schemes_path = os.path.join(DATASET_PATH, "financial_inclusion_schemes_translated_final_updated.csv")
print(f"Loading schemes data from: {schemes_path}")
df_schemes = pd.read_csv(schemes_path)
print("Available columns in schemes dataset:", df_schemes.columns.tolist())
df_schemes['text_blob'] = (
    df_schemes['scheme_goal'].fillna('') + ". " +
    df_schemes['eligibility'].fillna('') + ". " +
    df_schemes['benefits'].fillna('') + ". " +
    df_schemes['total_returns'].fillna('') + ". " +
    df_schemes['time_duration'].fillna('')
)
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')
def get_col(col, lang):
    if lang == "hi" and f"{col}_hi" in df_schemes.columns:
        print(f"Using Hindi column: {col}_hi")
        return f"{col}_hi"
    elif lang == "mr" and f"{col}_mr" in df_schemes.columns:
        print(f"Using Marathi column: {col}_mr")
        return f"{col}_mr"
    print(f"Using default column: {col}")
    return col

# Load investment data
investments_path = os.path.join(DATASET_PATH, "user_investments.csv")
print(f"Loading investments data from: {investments_path}")
df_investments = pd.read_csv(investments_path)

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
def recommend_schemes(user_profile, user_text_description, lang="en", top_k=3):
    filtered_df = filter_by_profile(user_profile, df_schemes)
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

    # Always include both English and language columns so you can pick later
    columns = [
        "scheme_name", "scheme_goal", "benefits","application_process", "eligibility","total_returns",
        "time_duration", "scheme_website", "similarity_score",
        "scheme_name_hi", "scheme_goal_hi", "benefits_hi","application_process_hi", "eligibility_hi", "total_returns_hi", "time_duration_hi",
        "scheme_name_mr", "scheme_goal_mr", "benefits_mr","application_process_mr", "eligibility_mr", "total_returns_mr", "time_duration_mr"
    ]
    # Only keep columns that exist in the DataFrame
    columns = [col for col in columns if col in recommended.columns]
    return recommended[columns]
    # Select available columns safely
    base_columns = ["scheme_name", "scheme_goal", "benefits", "total_returns", "time_duration", "scheme_website"]
    available_columns = [col for col in base_columns if col in recommended.columns]
    available_columns.append("similarity_score")  # Always add similarity score for ML results

    return recommended[available_columns]

@app.route("/recommend", methods=["POST"])
def recommend():
    data = request.get_json()
    lang = data.get("lang", "en")
    print(lang)  # Pass lang in request body
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

    # Pick columns based on language
    result_json = []
    for row in result_df.to_dict(orient="records"):
        result_json.append({
            "scheme_name": row.get(get_col("scheme_name", lang), row.get("scheme_name")),
            "scheme_goal": row.get(get_col("scheme_goal", lang), row.get("scheme_goal")),
            "benefits": row.get(get_col("benefits", lang), row.get("benefits")),
            "application_process": row.get(get_col("application_process", lang), row.get("application_process")),
            "eligibility": row.get(get_col("eligibility", lang), row.get("eligibility")),
            "total_returns": row.get(get_col("total_returns", lang), row.get("total_returns")),
            "time_duration": row.get(get_col("time_duration", lang), row.get("time_duration")),
            "scheme_website": row.get("scheme_website"),
            "similarity_score": row.get("similarity_score"),
        })
    print(clean_json(result_json))
    return jsonify({
        "recommended_schemes": clean_json(result_json), 
        "count": len(result_json),
        "filter_type": "ml_powered",
        "sorted_by": "similarity_score"
    })

@app.route("/eligible_schemes", methods=["POST"])
def eligible_schemes():
    """Fast rule-based filtering for initial page load without ML processing"""
    data = request.get_json()
    lang = data.get("lang", "en")
    print(f"Language requested: {lang}")
    
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
    
    # Always include both English and language columns so you can pick later
    columns = [
        "scheme_name", "scheme_goal", "benefits", "application_process", "eligibility", "total_returns",
        "time_duration", "scheme_website",
        "scheme_name_hi", "scheme_goal_hi", "benefits_hi", "application_process_hi", "eligibility_hi", "total_returns_hi", "time_duration_hi",
        "scheme_name_mr", "scheme_goal_mr", "benefits_mr", "application_process_mr", "eligibility_mr", "total_returns_mr", "time_duration_mr"
    ]
    # Only keep columns that exist in the DataFrame
    columns = [col for col in columns if col in filtered_df.columns]
    
    # Additional optional columns
    optional_columns = ["risk", "required_documents", "funding_agency", "contact_details"]
    for col in optional_columns:
        if col in filtered_df.columns:
            columns.append(col)
    
    result_df = filtered_df[columns].copy()

    def clean_json(obj):
        if isinstance(obj, dict):
            return {k: clean_json(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [clean_json(v) for v in obj]
        elif isinstance(obj, float) and (np.isnan(obj) or np.isinf(obj)):
            return "N/A"
        return obj

    # Pick columns based on language
    result_json = []
    for row in result_df.to_dict(orient="records"):
        result_json.append({
            "scheme_name": row.get(get_col("scheme_name", lang), row.get("scheme_name")),
            "scheme_goal": row.get(get_col("scheme_goal", lang), row.get("scheme_goal")),
            "benefits": row.get(get_col("benefits", lang), row.get("benefits")),
            "application_process": row.get(get_col("application_process", lang), row.get("application_process")),
            "eligibility": row.get(get_col("eligibility", lang), row.get("eligibility")),
            "total_returns": row.get(get_col("total_returns", lang), row.get("total_returns")),
            "time_duration": row.get(get_col("time_duration", lang), row.get("time_duration")),
            "scheme_website": row.get("scheme_website"),
            # Include optional columns if they exist
            "risk": row.get("risk") if "risk" in row else None,
            "required_documents": row.get("required_documents") if "required_documents" in row else None,
            "funding_agency": row.get("funding_agency") if "funding_agency" in row else None,
            "contact_details": row.get("contact_details") if "contact_details" in row else None,
        })
    
    print(f"Returning {len(result_json)} eligible schemes in language: {lang}")
    
    return jsonify({
        "eligible_schemes": clean_json(result_json), 
        "count": len(result_json),
        "filter_type": "rule_based",
        "sorted_by": "scheme_name"
    })

@app.route("/chatbot", methods=["POST"])
def chatbot():
    data = request.get_json()
    question = data.get("question", "").strip()
    lang = data.get("lang", "en")
    print(f"Language requested for chatbot: {lang}")
    
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
        scheme_name = row.get(get_col("scheme_name", lang), row.get("scheme_name"))
        scheme_goal = row.get(get_col("scheme_goal", lang), row.get("scheme_goal"))
        eligibility = row.get(get_col("eligibility", lang), row.get("eligibility"))
        benefits = row.get(get_col("benefits", lang), row.get("benefits"))
        total_returns = row.get(get_col("total_returns", lang), row.get("total_returns"))
        time_duration = row.get(get_col("time_duration", lang), row.get("time_duration"))
        
        answer += f"📄 {scheme_name}\n"
        if pd.notna(scheme_goal):
            answer += f"Goal: {scheme_goal}\n"
        if pd.notna(eligibility):
            answer += f"Eligibility: {eligibility}\n"
        if pd.notna(benefits):
            answer += f"Benefits: {benefits}\n"
        if pd.notna(total_returns):
            answer += f"Returns: {total_returns}\n"
        if pd.notna(time_duration):
            answer += f"Duration: {time_duration}\n"
        if pd.notna(row['scheme_website']):
            answer += f"Website: {row['scheme_website']}\n"
        answer += "\n"
    return jsonify({"answer": answer.strip()})



# Check if model files and vectorizer exist before loading
amount_model_path = os.path.join(MODELS_PATH, "amount_prediction_model.pkl")
duration_model_path = os.path.join(MODELS_PATH, "duration_prediction_model.pkl")
vectorizer_path = os.path.join(MODELS_PATH, "vectorizer.pkl")

print(f"Checking for models at: {amount_model_path}, {duration_model_path}, {vectorizer_path}")
models_available = os.path.exists(amount_model_path) and os.path.exists(duration_model_path) and os.path.exists(vectorizer_path)
if models_available:
    import pickle
    amount_model = pickle.load(open(amount_model_path, "rb"))
    duration_model = pickle.load(open(duration_model_path, "rb"))
    vectorizer = pickle.load(open(vectorizer_path, "rb"))
else:
    amount_model = None
    duration_model = None
    vectorizer = None


# Unified /scheme_detail endpoint (merging both functionalities)
@app.route("/scheme_detail", methods=["GET"])
def scheme_detail():
    scheme_name = request.args.get("name", "").strip().lower()
    lang = request.args.get("lang", "en")
    location = request.args.get("location", "").strip()
    print(f"Language requested for scheme detail: {lang}")
    print(f"Location requested for scheme detail: {location}")

    def normalize(text):
        return " ".join(text.lower().strip().split())

    name_col = get_col("scheme_name", lang)
    df_schemes["normalized_name"] = df_schemes[name_col].astype(str).apply(normalize)
    matched = df_schemes[df_schemes["normalized_name"] == normalize(scheme_name)]
    
    # If we have location parameter and multiple matches, filter by location as well
    if not matched.empty and len(matched) > 1 and location:
        # Filter for schemes that match the location or have 'All' for location
        location_match = matched[
            (matched["location"].fillna("All").astype(str).str.lower().str.contains("all")) |
            (matched["location"].fillna("All").astype(str).str.lower().str.contains(location.lower()))
        ]
        # Only use location filtered results if we found any
        if not location_match.empty:
            matched = location_match

    if matched.empty:
        return jsonify({"error": f"Scheme '{scheme_name}' not found."}), 404

    scheme = matched.iloc[0].to_dict()
    scheme_duration = normalize_duration(scheme.get(get_col("time_duration", lang)))
    ret_min, ret_max = extract_return_range(scheme.get(get_col("total_returns", lang)))

    # Find investments with similar duration and greater returns
    def is_similar_and_better(row):
        row_ret_min, row_ret_max = extract_return_range(row.get("total_returns", ""))
        # If scheme duration is N/A, consider all investments with greater returns
        if scheme_duration is None and ret_max is not None:
            return row_ret_max is not None and row_ret_max > ret_max
        # If scheme returns is N/A, show investments with highest returns
        if ret_max is None:
            return True  # We'll sort and pick top 4 later
        # Otherwise, match similar duration and greater returns
        dur_similar = row["duration_months"] is not None and abs(row["duration_months"] - scheme_duration) <= 6
        better_return = row_ret_max is not None and row_ret_max > ret_max
        return dur_similar and better_return

    def get_investment_details(row):
        details = {}
        # Example logic, you can customize per investment type/name
        details["risk"] = "High Risk"
        details["demat_account_required"] = True
        details["eligibility"] = "No eligibility criteria"
        details["documents_required"] = ["PAN", "AADHAR"]
        details["bank_account_required"] = True
        return details

    similar_investments = df_investments[df_investments.apply(is_similar_and_better, axis=1)].copy()
    similar_investments["sort_return"] = similar_investments["total_returns"].apply(
        lambda x: extract_return_range(x)[1] if extract_return_range(x)[1] is not None else 0
    )
    similar_investments = similar_investments.sort_values("sort_return", ascending=False).head(4)
    # Add extra details to each investment
    similar_investments["extra_details"] = similar_investments.apply(get_investment_details, axis=1)

    scheme["similar_investments"] = similar_investments[[
        "investment_type", "investment_name", "investment_amount",
        "total_returns", "time_duration", "current_value", "extra_details"
    ]].to_dict(orient="records")

    # Use language columns for response
    response = {
        "scheme_name": scheme.get(get_col("scheme_name", lang), scheme.get("scheme_name")),
        "scheme_goal": scheme.get(get_col("scheme_goal", lang), scheme.get("scheme_goal")),
        "benefits": scheme.get(get_col("benefits", lang), scheme.get("benefits")),
        "total_returns": scheme.get(get_col("total_returns", lang), scheme.get("total_returns")),
        "time_duration": scheme.get(get_col("time_duration", lang), scheme.get("time_duration")),
        "scheme_website": scheme.get("scheme_website"),
        "similar_investments": scheme.get("similar_investments", []),
        # ...other fields...
    }

    # If models are available, add predictions
    if models_available and amount_model is not None and duration_model is not None:
        try:
            combined_text = " ".join([
                str(scheme.get("scheme_goal", "")),
                str(scheme.get("benefits", "")),
                str(scheme.get("application_process", ""))
            ])
            # Assume vectorizer is available in the global scope
            X_vectorized = vectorizer.transform([combined_text])
            predicted_amount = float(amount_model.predict(X_vectorized)[0])
            predicted_duration = int(duration_model.predict(X_vectorized)[0])
            response["predicted_amount"] = round(predicted_amount, 2)
            response["predicted_duration_months"] = predicted_duration
        except Exception as e:
            print(f"Prediction error: {e}")
            response["predicted_amount"] = 5000.0
            response["predicted_duration_months"] = 12
    else:
        response["predicted_amount"] = 5000.0
        response["predicted_duration_months"] = 12

    def clean(val):
        if isinstance(val, list):
            return [clean(v) for v in val]
        elif isinstance(val, dict):
            return {k: clean(v) for k, v in val.items()}
        elif pd.isna(val):
            return "N/A"
        return val

    return jsonify({k: clean(v) for k, v in response.items()})

@app.route("/register_scheme", methods=["POST"])
def register_scheme():
    data = request.get_json()
    scheme_name = data.get("scheme_name")
    amount_paid = data.get("amount_paid")
    start_date = data.get("start_date")
    location = data.get("location", "")
    lang = data.get("lang", "en")
    print(f"Language requested for scheme registration: {lang}")
    print(f"Location for scheme registration: {location}")

    if not scheme_name:
        return jsonify({"error": "Missing scheme_name"}), 400

    def normalize(text):
        return " ".join(text.lower().strip().split())

    norm_name = normalize(scheme_name)
    df_schemes["normalized_name"] = df_schemes["scheme_name"].astype(str).apply(normalize)
    
    # First try to find an exact match for the scheme
    match = df_schemes[df_schemes["normalized_name"] == norm_name]
    
    # If we have a location filter and multiple matches, filter by location as well
    if not match.empty and len(match) > 1 and location:
        # Filter for schemes that match the location or have 'All' for location
        location_match = match[
            (match["location"].fillna("All").astype(str).str.lower().str.contains("all")) |
            (match["location"].fillna("All").astype(str).str.lower().str.contains(location.lower()))
        ]
        # Only use location filtered results if we found any
        if not location_match.empty:
            match = location_match

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
        "predicted_duration_months": predicted_duration,
        "location": location or scheme.get("location", "All")
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

    print(f"[REGISTERED] Scheme: {scheme_name} | Recommended Amount: ₹{predicted_amount} | Duration: {predicted_duration} months | Start: {start_date} | Location: {location}")

    return jsonify({
        "message": "Registration successful (with smart amount and duration prediction).",
        "details": response
    }), 200


if __name__ == "__main__":
    # Use environment variables for host and port
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() in ('true', '1', 't')
    print(f"Starting Flask app on {HOST}:{PORT} (Debug: {debug_mode})")
    app.run(host=HOST, port=PORT, debug=debug_mode)
