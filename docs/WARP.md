# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Verba is an offline-first meeting assistant that records speech, transcribes it locally using AI (Whisper), and produces structured meeting notes—all without sending data to the cloud. It's built with privacy and local-first principles at its core.

**Tech Stack:**
- Backend: Python 3.11+ with FastAPI + faster-whisper + SQLite
- Frontend: React 18 + Vite + TailwindCSS
- Audio: MediaRecorder API (browser) + Pydub + ffmpeg

## Quick Start

**Easiest method - use the install script:**
```bash
./install.sh    # Installs to ~/.local/share/verba
verba           # Launch application
```

**Manual start (for development):**
```bash
./start_verba.sh  # Starts both backend and frontend
```
Then open http://localhost:5173

## Development Commands

### Initial Setup

Backend:
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

Frontend:
```bash
cd frontend
npm install
```

### Running the Application

**Always run both servers simultaneously in separate terminals:**

Terminal 1 (Backend):
```bash
cd backend
source venv/bin/activate
python app.py
```
Backend runs at http://localhost:8000

Terminal 2 (Frontend):
```bash
cd frontend
npm run dev
```
Frontend runs at http://localhost:5173

### Building for Production

Frontend only:
```bash
cd frontend
npm run build
```

### Testing

**Backend tests:**
```bash
cd backend
source venv/bin/activate
python test_comprehensive.py  # Full API integration tests
python app_test.py           # Start backend in mock mode (no Whisper)
```

Manual testing workflow:
1. Start both servers
2. Open http://localhost:5173
3. Test recording → transcription → summarization → export flow
4. Verify session persistence by restarting backend

## Architecture

### Request Flow

```
User → Browser (MediaRecorder) → Frontend (React)
                                      ↓
                                 API calls (fetch)
                                      ↓
                            Backend (FastAPI) → Whisper Model
                                      ↓
                                 SQLite (storage.py)
```

### Backend Architecture

**Single-file monolith with clear separation:**

- `app.py`: FastAPI server with all endpoints (transcribe, summarize, sessions CRUD)
- `transcriber.py`: Whisper model wrapper + audio preprocessing (normalize, resample)
- `summarizer.py`: Rule-based NLP for extracting key points, decisions, action items
- `storage.py`: SQLAlchemy ORM for SQLite session persistence
- `settings.py`: Environment-based configuration
- `models/__init__.py`: Database models (SQLAlchemy Base)

**Key Backend Patterns:**
- Lazy-loaded Whisper model (initialized on first transcription)
- Temporary file handling with automatic cleanup
- Audio preprocessing pipeline: mono conversion → 16kHz resampling → volume normalization
- Rule-based summarization (no external API calls for offline capability)

**Database Schema:**
```python
Session:
  - id (UUID primary key)
  - created_at (DateTime)
  - transcript (Text)
  - summary_json (Text, JSON-serialized dict with key_points, decisions, action_items)
```

### Frontend Architecture

**Component Hierarchy:**
```
App.jsx (state management + coordination)
├── Header.jsx (title + status badge)
├── SessionHistory.jsx (collapsible sidebar with past sessions)
├── Recorder.jsx (MediaRecorder wrapper, upload to /api/transcribe)
├── TranscriptBox.jsx (transcript display + action buttons)
├── SummaryBox.jsx (summary display + export)
└── Toast.jsx (notifications)
```

**State Management:**
- No external state library—uses React useState in App.jsx
- Key state: transcript, summary, currentSessionId, loading states
- Props drilling for cross-component communication

**API Layer:**
- `api.js` centralizes all backend fetch calls
- Error handling with user-friendly messages bubbled to Toast component

## Configuration

### Backend Environment Variables

Create `backend/.env`:
```bash
ONLINE_FEATURES_ENABLED=false        # Feature flag for future cloud features
WHISPER_MODEL_SIZE=tiny              # Options: tiny, base, small, medium, large
WHISPER_DEVICE=cpu                   # Options: cpu, cuda
WHISPER_COMPUTE_TYPE=int8            # Options: int8, float16, float32
DATABASE_PATH=verba_sessions.db      # SQLite file location
ENABLE_AUDIO_PREPROCESSING=true      # Toggle normalization/resampling
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000  # CORS
```

### Frontend Environment Variables

Create `frontend/.env.local`:
```bash
VITE_API_URL=http://localhost:8000
```

### Deployment

**Docker Compose:**
```bash
docker-compose up -d
```
Access at http://localhost:5173

**Shell scripts:**
```bash
./start_verba.sh           # Start both servers locally
./start_verba_network.sh   # Enable network access from other devices
./stop_verba.sh            # Stop all Verba processes
```

## Common Development Tasks

### Changing Whisper Model

Edit `backend/settings.py` or set env var:
```bash
WHISPER_MODEL_SIZE=base  # Larger = better accuracy but slower
```
First run downloads the model (~75MB for tiny, ~150MB for base).

### Adding New API Endpoints

1. Add route handler in `backend/app.py`
2. Follow existing patterns: error handling, logging, JSONResponse
3. Add corresponding function in `frontend/src/api.js`
4. Update components to use new API function

### Testing Without Whisper

For faster testing without waiting for AI model initialization:
```bash
cd backend
source venv/bin/activate
python app_test.py  # Uses mock transcriber
```
This returns mock transcripts for rapid API testing.

### Modifying Summarization Logic

Edit `backend/summarizer.py`:
- `extract_key_points()`: Heuristic extraction from sentences
- `extract_decisions()`: Keyword matching for decisions
- `extract_action_items()`: Keyword matching for action items

Current implementation is rule-based to maintain offline capability. For LLM-based summarization (future), preserve the same output schema.

### Database Schema Changes

No migration framework is configured. To modify schema:
1. Edit `backend/models/__init__.py`
2. Delete `backend/verba_sessions.db`
3. Restart backend to recreate schema
4. **Warning:** This deletes all existing sessions

### Adding New UI Components

1. Create in `frontend/src/components/`
2. Follow existing patterns: TailwindCSS for styling, prop types documented in JSDoc
3. Import in `App.jsx` and integrate with state

## Important Implementation Details

### Audio Processing Pipeline

1. Browser records via MediaRecorder API (webm format)
2. Uploaded to `/api/transcribe` as multipart/form-data
3. Backend saves to temporary file
4. Pydub preprocessing: mono conversion → 16kHz → normalization
5. Whisper transcription (beam_size=5)
6. Temporary files cleaned up in finally block

### Session Persistence

- Sessions auto-saved when user clicks "Summarize"
- Each session gets a UUID
- Storage is synchronous (no async/await in storage.py)
- Sessions queryable by ID or listable (most recent first)

### Offline-First Design

- No cloud API calls in critical path
- Whisper model cached in memory after first load
- SQLite for local persistence
- Rule-based summarization (no LLM API)
- Frontend works without internet (after initial load)

## System Requirements

- **Python 3.11+**: For FastAPI + faster-whisper
- **Node.js 18+**: For Vite + React
- **ffmpeg**: Required for audio processing (Pydub dependency)
  ```bash
  # Fedora/RHEL
  sudo dnf install ffmpeg-free ffmpeg-free-devel
  
  # Debian/Ubuntu
  sudo apt install ffmpeg
  
  # macOS
  brew install ffmpeg
  ```

## Troubleshooting

### Backend fails to start
- Verify ffmpeg installed: `ffmpeg -version`
- Check Python version: `python3 --version`
- Ensure venv activated: `which python` should show venv path

### Transcription is slow
- Expected on CPU: ~5-15 seconds per minute of audio
- Whisper tiny is optimized for speed over accuracy
- For GPU acceleration: set `WHISPER_DEVICE=cuda` (requires CUDA setup)

### CORS errors
- Backend allows `http://localhost:5173` by default
- If using different port, update `ALLOWED_ORIGINS` in `backend/settings.py`

### Sessions not persisting
- Check `backend/verba_sessions.db` exists
- Verify file permissions in backend directory
- Check backend logs for SQLAlchemy errors
