# Scheme Recommender

A financial scheme recommendation system that helps users find relevant government schemes and financial products based on their profile and needs.

## Project Structure

- **backend-flask/**: Flask backend API
  - API endpoints for scheme recommendations, eligibility checks, and details
  - ML models for predicting scheme details
- **datasets/**: Data files for schemes and user investments
- **models/**: Trained ML models for predictions
- **db_hackathon_new/**: Flutter frontend application

## Getting Started

### Running the Backend

The backend can be run either using Docker or directly:

#### Using Docker (Recommended)

1. Make sure Docker and Docker Compose are installed
2. From the project root, run:

```bash
docker-compose up
```

3. The API will be available at http://localhost:5000

#### Manual Setup

1. Create a Python virtual environment:

```bash
cd backend-flask
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Run the application:

```bash
python app.py
```

### API Endpoints

- **POST /recommend**: AI-powered scheme recommendations
- **POST /eligible_schemes**: Rule-based eligibility filtering
- **GET /scheme_detail**: Detailed scheme information
- **POST /register_scheme**: Register for a scheme
- **POST /chatbot**: AI-powered scheme chatbot

### Running the Frontend

The frontend is a Flutter application. To run it:

1. Make sure Flutter is installed
2. Navigate to the frontend directory:

```bash
cd db_hackathon_new
```

3. Get dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Features

- Multi-language support (English, Hindi, Marathi)
- Personalized scheme recommendations based on user profile
- AI-powered search for schemes matching specific needs
- Voice-enabled interactions
- Scheme registration and tracking

## Environment Configuration

Environment variables can be set in the `.env` file in the backend-flask directory:

- `PORT`: The port to run the Flask application (default: 5000)
- `HOST`: The host to bind to (default: 0.0.0.0)
- `DATASET_PATH`: Path to datasets directory (default: datasets)
- `MODELS_PATH`: Path to models directory (default: models)
- `FLASK_DEBUG`: Enable debug mode (1 for true, 0 for false)

## Docker Usage

The project includes Docker configuration for easy deployment:

- `DockerFile`: Builds the Flask backend
- `docker-compose.yml`: Orchestrates the services

```bash
# Start the services
docker-compose up

# Stop the services
docker-compose down

# Rebuild the services
docker-compose up --build
```
