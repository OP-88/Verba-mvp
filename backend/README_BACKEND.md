# Verba MVP - Backend

FastAPI backend for audio transcription and summarization.

## Features

- **Audio transcription**: Uses `faster-whisper` with Whisper tiny model (fully offline)
- **Summarization**: Rule-based NLP to extract key points, decisions, and action items
- **REST API**: JSON endpoints for frontend communication

## Requirements

- Python 3.11+
- ffmpeg (for audio processing)

## Installation

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Running

```bash
# Development mode
python app.py

# Or with uvicorn directly
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

## API Endpoints

### `GET /`
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "message": "Verba MVP API is running"
}
```

### `POST /transcribe`
Transcribe audio file using Whisper.

**Request:**
- Multipart form data with audio file

**Response:**
```json
{
  "transcript": "Full transcribed text...",
  "status": "success"
}
```

### `POST /summarize`
Generate structured meeting notes from transcript.

**Request:**
```json
{
  "transcript": "Full transcript text..."
}
```

**Response:**
```json
{
  "summary": {
    "key_points": ["Point 1", "Point 2", ...],
    "decisions": ["Decision 1", ...],
    "action_items": ["Action 1", ...]
  },
  "status": "success"
}
```

## Project Structure

```
backend/
├── app.py              # FastAPI application
├── transcriber.py      # Whisper transcription logic
├── summarizer.py       # Summarization logic
├── models/             # (Future) Database models
└── requirements.txt    # Python dependencies
```

## Notes

- First run will download the Whisper tiny model (~75MB)
- Transcription runs on CPU with int8 quantization for speed
- No external API calls - completely offline
