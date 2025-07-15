import streamlit as st
import requests

API_URL = "http://10.78.91.251:5000/recommend" # Change this if your backend is deployed elsewhere

st.set_page_config(page_title="Scheme Recommender", layout="centered")

st.title("🧠 AI Scheme Recommender")
st.markdown("Fill out your details to get the top 3 best-fit government schemes for your financial situation.")

with st.form("user_form"):
    col1, col2 = st.columns(2)
    with col1:
        age = st.number_input("Age", min_value=0, max_value=100, value=30)
        gender = st.selectbox("Gender", ["Male", "Female", "Other"])
        income_group = st.selectbox("Income Group", ["Low Income", "Middle Income", "High Income"])
    with col2:
        social_category = st.selectbox("Social Category", ["SC", "ST", "OBC", "General"])
        location = st.selectbox("Location", ["Urban", "Rural", "Semi-Urban"])

    situation = st.text_area("Tell us about your current financial condition", placeholder="e.g. I have a loan, 2 school-going kids, and no stable income...")

    submitted = st.form_submit_button("🔍 Recommend Schemes")

if submitted:
    with st.spinner("Analyzing your situation..."):
        payload = {
            "age": age,
            "gender": gender,
            "social_category": social_category,
            "income_group": income_group,
            "location": location,
            "situation": situation
        }

        try:
            response = requests.post(API_URL, json=payload)
            if response.status_code == 200:
                result = response.json()
                if result.get("recommended_schemes"):
                    st.success("✅ Here are your top scheme recommendations:")
                    for scheme in result["recommended_schemes"]:
                        with st.expander(f"📌 {scheme['scheme_name']} (Score: {scheme['similarity_score']:.2f})"):
                            st.markdown(f"**Goal:** {scheme['scheme_goal']}")
                            st.markdown(f"**Benefits:** {scheme['benefits']}")
                            st.markdown(f"**Returns:** {scheme['total_returns']}")
                            st.markdown(f"**Duration:** {scheme['time_duration']}")
                            if scheme['scheme_website']:
                                st.markdown(f"[🔗 Official Website]({scheme['scheme_website']})")
                else:
                    st.warning("No schemes matched your profile.")
            else:
                st.error("Something went wrong. Check the backend or input format.")
        except requests.exceptions.RequestException as e:
            st.error(f"🚨 Could not connect to backend: {e}")
