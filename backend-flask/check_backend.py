import requests

try:
    response = requests.get("http://10.166.220.105:5000/news")  # Change to your backend IP if needed
    if response.status_code == 200:
        print("Backend is running! News endpoint is reachable.")
        print("Sample response:", response.json())
    else:
        print(f"Backend responded with status code: {response.status_code}")
except Exception as e:
    print("Backend is NOT running or not reachable.")
    print("Error:", e)