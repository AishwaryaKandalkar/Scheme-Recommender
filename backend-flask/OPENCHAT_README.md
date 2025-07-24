# OpenChat Integration for Scheme Recommender

This module enhances the Scheme Recommender application with an OpenChat-based intelligent chatbot capable of providing accurate, contextual responses about financial schemes and financial literacy concepts.

## Features

- **AI-Powered Financial Assistant**: Uses OpenChat 3.5 model for natural language understanding and generation
- **Context-Aware Responses**: Incorporates knowledge of available schemes into responses
- **Multi-Language Support**: Responses in English, Hindi, and Marathi
- **Fallback Mechanism**: Falls back to basic similarity search if AI response fails
- **Memory Efficient**: Uses lazy loading to initialize the model only when needed

## How It Works

1. When a user asks a question, the system finds relevant schemes using semantic search
2. These schemes provide context for the OpenChat model
3. The model then generates a response that explains the schemes in natural language
4. All responses are provided in the requested language (English, Hindi, or Marathi)

## Configuration

The OpenChat integration can be configured via environment variables:

```
USE_OPENCHAT=true              # Enable/disable OpenChat (true/false)
OPENCHAT_MODEL=openchat/openchat_3.5  # Model to use
```

## API Usage

The `/chatbot` endpoint accepts POST requests with:

```json
{
  "question": "Tell me about schemes for senior citizens",
  "lang": "en"  // "en", "hi", or "mr"
}
```

The response includes:

```json
{
  "answer": "Here is information about schemes for senior citizens...",
  "model": "openchat",  // or "basic" if fallback is used
  "language": "en"
}
```

## Docker Setup

The Docker configuration includes GPU support for faster inference. To use:

1. Ensure you have NVIDIA Docker runtime installed
2. Run with `docker-compose up`

## Requirements

- CUDA-capable GPU (recommended but not required)
- At least 8GB RAM, preferably 16GB or more
- Python 3.8+ with dependencies listed in requirements.txt
