from flask import Flask, request, jsonify, send_file
import pandas as pd
import numpy as np
import os
from sentence_transformers import SentenceTransformer, util
from io import StringIO

app = Flask(__name__)

# Load model and data once on startup
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

def matches(dataframe, field, value):
    val = dataframe[field].fillna("All").astype(str).str.lower()
    return val.str.contains(value.lower()) | val.str.contains("all")

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

def filter_by_profile(user, df):
    return df[
        (matches(df, "gender", user["gender"])) &
        (matches(df, "social_category", user["social_category"])) &
        (matches(df, "annual_income_group", user["income_group"])) &
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

    user_profile = {
        "age": int(data["age"]),
        "gender": data["gender"],
        "social_category": data["social_category"],
        "income_group": data["income_group"],
        "location": data["location"]
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

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)

