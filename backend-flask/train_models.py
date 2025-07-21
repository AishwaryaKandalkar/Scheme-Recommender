import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import Ridge
import pickle

df = pd.read_csv("datasets/financial_inclusion_schemes_1000_v3.csv")

df["combined_text"] = (
    df["scheme_goal"].fillna("") + " " +
    df["benefits"].fillna("") + " " +
    df["application_process"].fillna("")
)

vectorizer = TfidfVectorizer(max_features=500)
X = vectorizer.fit_transform(df["combined_text"])

# Train amount model
amount_df = df[~df["amount_to_be_paid"].isin(["NA", "N/A", "", None])]
# y_amount = amount_df["amount_to_be_paid"].astype(float)
import re

def extract_amount(value):
    if pd.isna(value):
        return None
    match = re.search(r'[\d,]+', value.replace(",", ""))
    if match:
        return float(match.group().replace(",", ""))
    return None

amount_df["amount_numeric"] = amount_df["amount_to_be_paid"].apply(extract_amount)
amount_df = amount_df.dropna(subset=["amount_numeric"])

y_amount = amount_df["amount_numeric"]

X_amount = vectorizer.transform(amount_df["combined_text"])

amount_model = Ridge()
amount_model.fit(X_amount, y_amount)
pickle.dump(amount_model, open("models/amount_prediction_model.pkl", "wb"))

# Train duration model
duration_df = df[~df["time_duration"].isin(["NA", "N/A", "", None])]
def extract_duration(value):
    if pd.isna(value):
        return None
    match = re.search(r'\d+', value)
    return int(match.group()) if match else None

duration_df["duration_numeric"] = duration_df["time_duration"].apply(extract_duration)
duration_df = duration_df.dropna(subset=["duration_numeric"])

y_dur = duration_df["duration_numeric"]
X_dur = vectorizer.transform(duration_df["combined_text"])

duration_model = Ridge()
duration_model.fit(X_dur, y_dur.values.ravel())
pickle.dump(duration_model, open("models/duration_prediction_model.pkl", "wb"))
