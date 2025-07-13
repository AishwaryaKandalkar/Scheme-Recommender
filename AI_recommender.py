from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report
import pandas as pd
import numpy as np

# Load synthetic data
data = pd.read_csv("synthetic_user_scheme_data.csv")

# Encode categorical data
features = ["age", "gender", "social_category", "annual_income_group", "location"]
X = data[features].copy()
y = data["matched_scheme"]

for col in X.columns:
    X[col] = LabelEncoder().fit_transform(X[col])

y_encoded = LabelEncoder().fit_transform(y)

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2, random_state=42)

# Train model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
print(classification_report(y_test, y_pred))

def get_top_3_recommendations(user_input, model, label_encoder):
    # Encode the input
    user_df = pd.DataFrame([user_input])
    for col in user_df.columns:
        user_df[col] = LabelEncoder().fit(data[col]).transform(user_df[col])

    # Get probabilities
    probs = model.predict_proba(user_df)

    # Top 3 scheme indices
    top_indices = np.argsort(probs[0])[::-1][:3]

    # Decode to scheme names
    top_schemes = label_encoder.inverse_transform(top_indices)
    top_probs = probs[0][top_indices]

    # Display
    for name, prob in zip(top_schemes, top_probs):
        print(f"🔹 {name} — confidence: {prob:.2f}")

user_input = {
    "age": 45,
    "gender": "Male",
    "social_category": "OBC",
    "annual_income_group": "Low Income",
    "location": "Rural"
}

get_top_3_recommendations(user_input, model, LabelEncoder().fit(data["matched_scheme"]))