# Scheme Recommender - Backend API

This is the backend service for the Scheme Recommender application. It provides API endpoints for scheme recommendations and eligibility checks.

## Docker Setup

### Prerequisites

- Docker installed on your system
- Docker Compose installed on your system

### Running with Docker Compose

1. Navigate to the project root directory:

```bash
cd Scheme-Recommender
```

2. Start the application using Docker Compose:

```bash
docker-compose up
```

This will:
- Build the Docker image for the Flask backend
- Mount the necessary volumes for datasets and models
- Start the Flask server on port 5000

3. Access the API at http://localhost:5000

To stop the application:

```bash
docker-compose down
```

### API Endpoints

- **POST /recommend**: Returns AI-powered scheme recommendations based on user profile and situation
- **POST /eligible_schemes**: Returns all schemes the user is eligible for based on profile
- **GET /scheme_detail**: Returns detailed information about a specific scheme
- **POST /register_scheme**: Register for a specific scheme
- **POST /chatbot**: AI-powered chatbot for answering scheme-related questions

### Environment Variables

Create a `.env` file based on the `.env.example` to configure the application.

## Development Setup

If you prefer to run the application without Docker:

1. Create a Python virtual environment:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:

```bash
pip install -r backend-flask/requirements.txt
```

3. Run the application:

```bash
cd backend-flask
python app.py
```

## Project Structure

- `backend-flask/`: Flask API code
  - `app.py`: Main application file
  - `requirements.txt`: Python dependencies
- `datasets/`: Data files used by the application
- `models/`: Machine learning models used for predictions
