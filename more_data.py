import pandas as pd
import numpy as np
import random

# Load your scheme dataset
df = pd.read_csv("financial_inclusion_schemes.csv")
df = df.fillna("Unknown")

# Clean helpers
def clean(val):
    return val.strip().lower() if isinstance(val, str) else val

# Demographic options
ages = list(range(18, 80))
genders = ["Male", "Female", "Other"]
categories = ["General", "SC", "ST", "OBC"]
income_groups = ["Below Poverty Line", "Low Income", "Middle Income", "High Income"]
locations = ["Urban", "Rural", "Semi-Urban"]

# Generate synthetic users
def generate_user():
    return {
        "age": random.choice(ages),
        "gender": random.choice(genders),
        "social_category": random.choice(categories),
        "annual_income_group": random.choice(income_groups),
        "location": random.choice(locations)
    }

# Match schemes using logic from before
def match_scheme(user, row):
    def age_matches(age, age_str):
        if age_str.lower() == "all":
            return True
        for part in age_str.split(","):
            part = part.strip()
            if "+" in part:
                if age >= int(part.replace("+", "").strip()):
                    return True
            elif "-" in part:
                try:
                    low, high = map(int, part.split("-"))
                    if low <= age <= high:
                        return True
                except:
                    continue
        return False

    def match(val1, val2):
        return (val2.lower() in ["all", "unknown"]) or (val1.lower() in val2.lower())

    return (
        age_matches(user["age"], row["age_group"]) and
        match(user["gender"], row["gender"]) and
        match(user["social_category"], row["social_category"]) and
        match(user["annual_income_group"], row["annual_income_group"]) and
        match(user["location"], row["location"])
    )

# Generate dataset
user_data = []
for _ in range(1000):
    user = generate_user()
    matches = []
    for _, scheme in df.iterrows():
        if match_scheme(user, scheme):
            matches.append(scheme["scheme_name"])
    if matches:
        user["matched_scheme"] = random.choice(matches)  # randomly assign one from matches
        user_data.append(user)

synthetic_df = pd.DataFrame(user_data)
synthetic_df.to_csv("synthetic_user_scheme_data.csv", index=False)
print("Synthetic data created with", len(synthetic_df), "entries")
