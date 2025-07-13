import pandas as pd

# Load dataset
df = pd.read_csv("financial_inclusion_schemes.csv")

# Clean and normalize
df = df.fillna("Unknown")
df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# Helper: match categorical field
def match_score(user_value, scheme_value):
    if scheme_value.lower() in ["all", "unknown"]:
        return 1
    return int(user_value.lower() in scheme_value.lower())

# Helper: age matching logic
def age_matches(user_age, age_group_str):
    if age_group_str.lower() in ["all", "unknown"]:
        return True

    ranges = age_group_str.split(',')
    for age_range in ranges:
        age_range = age_range.strip()
        if "+" in age_range:
            min_age = int(age_range.replace("+", "").strip())
            if user_age >= min_age:
                return True
        elif "-" in age_range:
            try:
                min_age, max_age = map(int, age_range.split("-"))
                if min_age <= user_age <= max_age:
                    return True
            except:
                continue
    return False

# Main recommender function
def recommend_schemes(user_profile, df_data=df):
    scores = []
    for idx, row in df_data.iterrows():
        score = 0
        if age_matches(user_profile["age"], row["age_group"]):
            score += 1
        score += match_score(user_profile["gender"], row["gender"])
        score += match_score(user_profile["social_category"], row["social_category"])
        score += match_score(user_profile["annual_income_group"], row["annual_income_group"])
        score += match_score(user_profile["location"], row["location"])
        scores.append((score, idx))

    top_indices = sorted(scores, key=lambda x: x[0], reverse=True)[:3]
    recommendations = []

    for _, idx in top_indices:
        row = df_data.loc[idx]
        recommendations.append({
            "scheme_name": row["scheme_name"],
            "scheme_type": row["scheme_type"],
            "scheme_goal": row["scheme_goal"],
            "eligibility": row["eligibility"],
            "benefits": row["benefits"],
            "application_process": row["application_process"],
            "scheme_website": row["scheme_website"],
            "total_returns": row["total_returns"],
            "time_duration": row["time_duration"]
        })

    return recommendations

# Example user
example_user = {
    "age": 35,
    "gender": "Male",
    "social_category": "SC",
    "annual_income_group": "Below Poverty Line",
    "location": "Rural"
}

# Get recommendations
recommendations = recommend_schemes(example_user)
for rec in recommendations:
    print("\n--- Recommended Scheme ---")
    for k, v in rec.items():
        print(f"{k}: {v}")
