# scheme_recommender.py

import pandas as pd
import numpy as np
from sentence_transformers import SentenceTransformer, util

# Load the scheme dataset
df_schemes = pd.read_csv("financial_inclusion_schemes.csv")

# Prepare text blob for semantic analysis
df_schemes['text_blob'] = (
    df_schemes['scheme_goal'].fillna('') + ". " +
    df_schemes['eligibility'].fillna('') + ". " +
    df_schemes['benefits'].fillna('') + ". " +
    df_schemes['total_returns'].fillna('') + ". " +
    df_schemes['time_duration'].fillna('')
)

# Load transformer model
print("🔄 Loading SentenceTransformer model...")
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

# Precompute scheme embeddings
print("📦 Embedding all scheme descriptions...")
scheme_embeddings = model.encode(df_schemes['text_blob'].tolist(), convert_to_tensor=True)


def filter_by_profile(user, df):
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

    return df[
        (matches(df, "gender", user["gender"])) &
        (matches(df, "social_category", user["social_category"])) &
        (matches(df, "annual_income_group", user["income_group"])) &
        (matches(df, "location", user["location"])) &
        (df["age_group"].fillna("All").apply(lambda ag: age_matches(user["age"], ag)))
    ].reset_index(drop=True)

# === Main Recommendation Function ===
def recommend_schemes(user_profile, user_text_description, top_k=3):
    print("🔎 Filtering schemes based on structured profile...")
    filtered_df = filter_by_profile(user_profile, df_schemes)

    if len(filtered_df) == 0:
        return "⚠️ No eligible schemes found based on your profile."

    print(f"✅ {len(filtered_df)} eligible schemes found. Now matching semantics...")

    # Step 2: Embed user's financial situation
    user_embedding = model.encode(user_text_description, convert_to_tensor=True)

    # Step 3: Embed only filtered schemes
    filtered_texts = (
        filtered_df['scheme_goal'].fillna('') + ". " +
        filtered_df['eligibility'].fillna('') + ". " +
        filtered_df['benefits'].fillna('') + ". " +
        filtered_df['total_returns'].fillna('') + ". " +
        filtered_df['time_duration'].fillna('')
    ).tolist()
    filtered_embeddings = model.encode(filtered_texts, convert_to_tensor=True)

    # Step 4: Compute cosine similarities
    similarities = util.pytorch_cos_sim(user_embedding, filtered_embeddings)[0].cpu().numpy()

    # Step 5: Rank and select top K
    top_indices = np.argsort(similarities)[::-1][:top_k]
    recommended = filtered_df.iloc[top_indices].copy()
    recommended["similarity_score"] = similarities[top_indices]

    return recommended[[
        "scheme_name", "scheme_goal", "benefits", "total_returns",
        "time_duration", "scheme_website", "similarity_score"
    ]]

# === Example Usage ===
if __name__ == "__main__":
    user_input = {
        "age": 45,
        "gender": "Male",
        "social_category": "OBC",
        "income_group": "Low Income",
        "location": "Rural"
    }

    user_text = """
    I have an unstable job with inconsistent income. I support a family of 5 including 2 children. 
    One child is in school and the other is preparing for college. I have a small outstanding loan. 
    I need help managing education costs and future marriage expenses. 
    """

    result = recommend_schemes(user_input, user_text, top_k=3)

    if isinstance(result, str):
        print(result)  # In case of "No eligible schemes found"
    else:
        output_path = "recommended_schemes.csv"
        result.to_csv(output_path, index=False)
        print(f"\n✅ Top {len(result)} schemes saved to: {output_path}")

