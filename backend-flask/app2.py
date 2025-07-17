from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from sentence_transformers import SentenceTransformer, util
from io import StringIO
import json

app = Flask(__name__)

# ========== CONFIGURATION ==========
SCHEMA_CONFIG = {
    "gender": "categorical",
    "social_category": "categorical",
    "income_group": "categorical",
    "location": "categorical",
    "age_group": "range"
}

WEIGHTS = {
    "semantic": 0.6,
    "demographic": 0.3,
    "benefit_score": 0.1
}

# ========== LOAD DATA AND MODEL ==========
print("Loading model and data...")
df_schemes = pd.read_csv("datasets/financial_inclusion_schemes.csv")

df_schemes['text_blob'] = (
    df_schemes['scheme_goal'].fillna('') + ". " +
    df_schemes['eligibility'].fillna('') + ". " +
    df_schemes['benefits'].fillna('') + ". " +
    df_schemes['total_returns'].fillna('') + ". " +
    df_schemes['time_duration'].fillna('')
)

model = SentenceTransformer('paraphrase-MiniLM-L6-v2')


# ========== UTILITIES ==========

def clean_json(obj):
    if isinstance(obj, dict):
        return {k: clean_json(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [clean_json(v) for v in obj]
    elif isinstance(obj, float) and (np.isnan(obj) or np.isinf(obj)):
        return "N/A"
    return obj

def age_matches(user_age, age_group_str):
    if pd.isna(age_group_str) or 'all' in age_group_str.lower():
        return True
    parts = [a.strip() for a in age_group_str.split(',')]
    for part in parts:
        if '-' in part:
            try:
                low, high = map(int, part.split('-'))
                if low <= user_age <= high:
                    return True
            except:
                continue
        elif '+' in part:
            try:
                if user_age >= int(part.replace('+', '')):
                    return True
            except:
                continue
    return False

def dynamic_filter(user_profile, df, config):
    df_filtered = df.copy()
    for field, rule_type in config.items():
        # Map user_profile and DataFrame field names for compatibility
        df_field = field
        if field == "income_group":
            if field not in df.columns and "annual_income_group" in df.columns:
                df_field = "annual_income_group"
        if field not in user_profile or df_field not in df.columns:
            continue
        user_value = user_profile[field]
        if rule_type == "categorical":
            df_filtered = df_filtered[
                df_filtered[df_field].fillna("All").astype(str).str.lower().str.contains(str(user_value).lower())
                | df_filtered[df_field].str.lower().str.contains("all")
            ]
        elif rule_type == "range":
            df_filtered = df_filtered[
                df_filtered[df_field].fillna("All").apply(lambda ag: age_matches(user_value, ag))
            ]
    return df_filtered.reset_index(drop=True)

# ========== MAIN RECOMMENDATION ENGINE ==========

def recommend_schemes(user_profile, user_text, top_k=3):
    # Semantic vector for user need
    user_embedding = model.encode(user_text, convert_to_tensor=True)

    # Filtered schemes
    filtered_df = dynamic_filter(user_profile, df_schemes, SCHEMA_CONFIG)
    if len(filtered_df) == 0:
        filtered_df = df_schemes.copy()

    search_texts = filtered_df['text_blob'].tolist()
    search_embeddings = model.encode(search_texts, convert_to_tensor=True)
    similarities = util.pytorch_cos_sim(user_embedding, search_embeddings)[0].cpu().numpy()

    # Placeholder for benefit-based score (replace with ML model or rules)
    benefit_scores = filtered_df['benefits'].fillna('').str.len() / 100.0
    benefit_scores = np.clip(benefit_scores, 0, 1)

    demographic_match = np.ones(len(filtered_df))  # placeholder — can be improved

    total_scores = (
        WEIGHTS["semantic"] * similarities +
        WEIGHTS["demographic"] * demographic_match +
        WEIGHTS["benefit_score"] * benefit_scores.values
    )

    top_indices = np.argsort(total_scores)[::-1][:top_k]
    top_schemes = filtered_df.iloc[top_indices].copy()
    top_schemes["match_score"] = total_scores[top_indices]

    return top_schemes[[
        "scheme_name", "scheme_goal", "benefits", "total_returns",
        "time_duration", "scheme_website", "match_score"
    ]]

# ========== ENDPOINTS ==========

@app.route("/recommend", methods=["POST"])
def recommend():
    data = request.get_json()

    required_fields = {"age", "gender", "social_category", "income_group", "location", "situation"}
    if not required_fields.issubset(set(data)):
        return jsonify({"error": f"Missing fields. Required: {', '.join(required_fields)}"}), 400


    # Defensive conversion for age
    age_val = data.get("age", "")
    try:
        age = int(age_val) if str(age_val).strip().isdigit() else None
    except Exception:
        age = None

    # Fallback for income_group/annual_income_group
    income_group = data.get("income_group") or data.get("annual_income_group") or ""

    user_profile = {
        "age": age,
        "gender": data.get("gender", ""),
        "social_category": data.get("social_category", ""),
        "income_group": income_group,
        "location": data.get("location", "")
    }

    result_df = recommend_schemes(user_profile, data["situation"], top_k=3)
    return jsonify({
        "recommended_schemes": clean_json(result_df.to_dict(orient="records")),
        "count": len(result_df)
    })


# ========== BASIC RAG-LIKE CHATBOT ==========
@app.route("/chatbot", methods=["POST"])
def chatbot():
    data = request.get_json()
    question = data.get("question", "").strip()
    if not question:
        return jsonify({"answer": "Please provide a question."}), 400

    question_embedding = model.encode(question, convert_to_tensor=True)
    scheme_embeddings = model.encode(df_schemes["text_blob"].tolist(), convert_to_tensor=True)
    similarities = util.pytorch_cos_sim(question_embedding, scheme_embeddings)[0].cpu().numpy()
    top_indices = np.argsort(similarities)[::-1][:3]
    top_schemes = df_schemes.iloc[top_indices]

    answer = "Here are the most relevant schemes for your query:\n\n"
    for _, row in top_schemes.iterrows():
        answer += f"\U0001F4C4 {row['scheme_name']}\n"
        if pd.notna(row['scheme_goal']):
            answer += f"Goal: {row['scheme_goal']}\n"
        if pd.notna(row['eligibility']):
            answer += f"Eligibility: {row['eligibility']}\n"
        if pd.notna(row['benefits']):
            answer += f"Benefits: {row['benefits']}\n"
        if pd.notna(row['scheme_website']):
            answer += f"Website: {row['scheme_website']}\n"
        answer += "\n"

    return jsonify({"answer": answer.strip()})


# ========== RUN APP ==========
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
