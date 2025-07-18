from flask import Flask, request, jsonify, send_file
import pandas as pd
import numpy as np
import os
from sentence_transformers import SentenceTransformer, util
from io import StringIO

app = Flask(__name__)

# Load model and data once on startup

df_schemes = pd.read_csv("C:/Users/USER/Documents/projects/Scheme-Recommender/datasets//financial_inclusion_schemes.csv")
df_schemes['text_blob'] = (
    df_schemes['scheme_goal'].fillna('') + ". " +
    df_schemes['eligibility'].fillna('') + ". " +
    df_schemes['benefits'].fillna('') + ". " +
    df_schemes['total_returns'].fillna('') + ". " +
    df_schemes['time_duration'].fillna('')
)
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

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
    # Use annual_income_group if present, else fallback to income_group
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

    # If no profile match, fallback to semantic search over all schemes
    if len(filtered_df) == 0:
        search_df = df_schemes
    else:
        search_df = filtered_df

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

    user_text = data["situation"]

    result_df = recommend_schemes(user_profile, user_text, top_k=3)
    if result_df is None:
        return jsonify({"message": "No eligible schemes found."})

    # Clean NaN and infinite values before returning JSON
    import numpy as np
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
        "count": len(result_json)
    })


# Chatbot endpoint: answers any question about the schemes dataset
@app.route("/chatbot", methods=["POST"])
def chatbot():
    data = request.get_json()
    question = data.get("question", "").strip()
    if not question:
        return jsonify({"answer": "Please provide a question."}), 400

    # Embed the user question
    question_embedding = model.encode(question, convert_to_tensor=True)
    # Use the text_blob column for semantic search
    scheme_texts = df_schemes['text_blob'].tolist()
    scheme_embeddings = model.encode(scheme_texts, convert_to_tensor=True)
    similarities = util.pytorch_cos_sim(question_embedding, scheme_embeddings)[0].cpu().numpy()
    top_indices = np.argsort(similarities)[::-1][:3]
    top_schemes = df_schemes.iloc[top_indices]

    # Compose a conversational answer
    answer = "Here are the most relevant schemes I found for your question:\n\n"
    for idx, row in top_schemes.iterrows():
        answer += f"\U0001F4C4 {row['scheme_name']}\n"
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
    answer = answer.strip()
    return jsonify({"answer": answer})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)

