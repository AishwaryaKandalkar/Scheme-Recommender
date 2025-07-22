from flask import Flask, request, jsonify, send_file
import pandas as pd
import numpy as np
import os
from sentence_transformers import SentenceTransformer, util
from io import StringIO
import pickle
from datetime import timedelta

app = Flask(__name__)

# Load schemes dataset
df_schemes = pd.read_csv("C:/Users/USER/Documents/projects/Scheme-Recommender/datasets/financial_inclusion_schemes_1000_v3.csv")
df_schemes['text_blob'] = (
    df_schemes['scheme_goal'].fillna('') + ". " +
    df_schemes['eligibility'].fillna('') + ". " +
    df_schemes['benefits'].fillna('') + ". " +
    df_schemes['total_returns'].fillna('') + ". " +
    df_schemes['time_duration'].fillna('')
)
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

# Load investment data
df_investments = pd.read_csv("C:/Users/USER/Documents/projects/Scheme-Recommender/datasets/user_investments.csv")

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

def recommend_schemes(user_profile, user_text_description, top_k=3):
    filtered_df = filter_by_profile(user_profile, df_schemes)
    user_embedding = model.encode(user_text_description, convert_to_tensor=True)

    search_df = filtered_df if len(filtered_df) > 0 else df_schemes
    search_texts = (
        search_df['scheme_goal'].fillna('') + ". " +
        search_df['eligibility'].fillna('') + ". " +
        search_df['benefits'].fillna('') + ". " +
        search_df['total_returns'].fillna('') + ". " +
        search_df['time_duration'].fillna('')
    ).tolist()
    search_embeddings = model.encode(search_texts, convert_to_tensor=True)

    similarities = util.pytorch_cos_sim(user_embedding, search_embeddings)[0].cpu().numpy()
    top_indices = np.argsort(similarities)[::-1][:top_k]
    recommended = search_df.iloc[top_indices].copy()
    recommended["similarity_score"] = similarities[top_indices]

    return recommended[[
        "scheme_name", "scheme_goal", "benefits", "total_returns",
        "time_duration", "scheme_website", "similarity_score"
    ]]

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

    result_df = recommend_schemes(user_profile, user_text, top_k=3)

    def clean_json(obj):
        if isinstance(obj, dict):
            return {k: clean_json(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [clean_json(v) for v in obj]
        elif isinstance(obj, float) and (np.isnan(obj) or np.isinf(obj)):
            return "N/A"
        return obj

    result_json = clean_json(result_df.to_dict(orient="records"))
    return jsonify({"recommended_schemes": result_json, "count": len(result_json)})

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

amount_model = pickle.load(open("C:/Users/USER/Documents/projects/Scheme-Recommender/models/amount_prediction_model.pkl", "rb"))
duration_model = pickle.load(open("C:/Users/USER/Documents/projects/Scheme-Recommender/models/duration_prediction_model.pkl", "rb"))

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
    combined_text = " ".join([
        str(scheme.get("scheme_goal", "")),
        str(scheme.get("benefits", "")),
        str(scheme.get("application_process", ""))
    ])

    X_vectorized = vectorizer.transform([combined_text])
    predicted_amount = float(amount_model.predict(X_vectorized)[0])
    predicted_duration = int(duration_model.predict(X_vectorized)[0])

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
