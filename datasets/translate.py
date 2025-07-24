import pandas as pd
from googletrans import Translator
import time

# Load dataset
df = pd.read_csv("financial_inclusion_schemes_1000_v3.csv")

# Columns to translate
columns_to_translate = [
    "scheme_name", "scheme_goal", "eligibility", "benefits",
    "application_process", "total_returns", "time_duration"
]

# Translator instance
translator = Translator()

# Function to safely translate a cell
def translate_text(text, dest_lang, retries=3):
    for _ in range(retries):
        try:
            if pd.isna(text) or str(text).strip() == "":
                return text
            translated = translator.translate(str(text), dest=dest_lang)
            return translated.text
        except Exception as e:
            print(f"Retrying due to error: {e}")
            time.sleep(1)
    return text  # fallback to original if it keeps failing

# Batch processing settings
batch_size = 100
start_row = 0
output_file = "financial_inclusion_schemes_translated_final.csv"

# Process in batches
while start_row < len(df):
    print(f"Processing rows {start_row} to {start_row + batch_size - 1}")
    batch_df = df.iloc[start_row:start_row+batch_size].copy()

    for col in columns_to_translate:
        batch_df[f"{col}_hi"] = batch_df[col].apply(lambda x: translate_text(x, 'hi'))
        batch_df[f"{col}_mr"] = batch_df[col].apply(lambda x: translate_text(x, 'mr'))

    # Append or save
    if start_row == 0:
        batch_df.to_csv(output_file, index=False, mode='w')  # Write header
    else:
        batch_df.to_csv(output_file, index=False, mode='a', header=False)  # Append without header

    start_row += batch_size
    time.sleep(2)  # delay between batches to reduce API load

print("All batches completed. File saved as", output_file)
