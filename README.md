# Verba MVP

**Verba** is an offline-first meeting assistant that records speech, transcribes it locally, and produces clean, structured meeting notes—all without sending your data to the cloud.

> **Private. Offline-first. Built for classrooms, meetings, and lectures.**

## Why Verba?

- **🔒 Privacy-first**: Everything runs locally. No cloud APIs, no tracking, no data leaks.
- **⚡ Fast**: Uses Whisper tiny model for quick transcription on your machine.
- **📝 Smart summarization**: Automatically extracts key points, decisions, and action items.
- **🖥️ Simple UI**: Clean, intuitive interface built with React and TailwindCSS.
- **🌐 Offline**: Works without internet once dependencies are installed.

Perfect for students, teachers, professionals, and anyone who values privacy and control over their data.

## Features

1. **Audio Recording**: Record directly from your browser microphone
2. **Local Transcription**: Powered by OpenAI's Whisper (tiny model) via faster-whisper
3. **Smart Summarization**: Rule-based NLP to extract:
   - 📌 Key Points
   - ✅ Decisions
   - 🎯 Action Items
4. **Export-Ready Notes**: Clean, structured output perfect for documentation

## Tech Stack

**Backend**:
- Python 3.11+
- FastAPI + Uvicorn
- faster-whisper (Whisper tiny model)
- Rule-based summarization (no external AI APIs)

**Frontend**:
- React 18
- Vite
- TailwindCSS
- Browser MediaRecorder API

## Project Structure

```
verba-mvp/
├── backend/               # Python FastAPI server
│   ├── app.py            # Main API endpoints
│   ├── transcriber.py    # Whisper transcription logic
│   ├── summarizer.py     # Summarization logic
│   ├── models/           # (Future) Database models
│   ├── requirements.txt  # Python dependencies
│   └── README_BACKEND.md
│
├── frontend/             # React + Vite UI
│   ├── src/
│   │   ├── App.jsx           # Main app component
│   │   ├── main.jsx          # React entry
│   │   └── components/
│   │       ├── Recorder.jsx      # Audio recording
│   │       ├── TranscriptBox.jsx # Transcript display
│   │       └── SummaryBox.jsx    # Summary display
│   ├── index.html
│   ├── package.json
│   └── README_FRONTEND.md
│
└── README.md             # This file
```

## Installation & Setup

### Prerequisites

- **Python 3.11+** (with pip)
- **Node.js 18+** (with npm)
- **ffmpeg** (for audio processing)

#### Install ffmpeg (Linux)

```bash
# Fedora/RHEL
sudo dnf install ffmpeg

# Debian/Ubuntu
sudo apt install ffmpeg
```

### Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

**Note**: First run will download the Whisper tiny model (~75MB) automatically.

### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install
```

## Running Verba

You need to run both backend and frontend simultaneously.

### Terminal 1: Backend

```bash
cd backend
source venv/bin/activate
python app.py
```

Backend runs at `http://localhost:8000`

### Terminal 2: Frontend

```bash
cd frontend
npm run dev
```

Frontend runs at `http://localhost:5173`

### Using Verba

1. Open `http://localhost:5173` in your browser
2. Click the **Record** button and allow microphone access
3. Speak into your microphone (try a short test: "We need to schedule a follow-up meeting next week")
4. Click **Stop** when finished
5. Wait for transcription to complete
6. Click **Summarize** to generate meeting notes
7. View your structured notes with key points, decisions, and action items

## API Endpoints

### `POST /transcribe`
- **Input**: Audio file (multipart/form-data)
- **Output**: `{ "transcript": "...", "status": "success" }`

### `POST /summarize`
- **Input**: `{ "transcript": "..." }`
- **Output**: `{ "summary": { "key_points": [...], "decisions": [...], "action_items": [...] }, "status": "success" }`

## Development

### Backend Development

```bash
cd backend
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development

```bash
cd frontend
npm run dev
```

Changes to frontend code will hot-reload automatically.

## Deployment on Vercel

**Important**: Verba's architecture requires **two separate deployments**:

1. **Frontend**: Can be deployed on Vercel
2. **Backend**: Must be deployed separately (Railway, Render, DigitalOcean, or your own server)

### Why?

Vercel's serverless functions have:
- 10-second execution timeout (Hobby plan) / 60 seconds (Pro)
- Limited memory and CPU
- No support for large ML models like Whisper

The backend requires persistent processes and significant compute power for audio transcription.

### Frontend Deployment (Vercel)

1. **Push your code to GitHub** (already done!)

2. **Import to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your `Verba-mvp` repository
   - Set **Root Directory** to `frontend`

3. **Configure Environment Variable**:
   - Add `VITE_API_URL` = `https://your-backend-url.com`
   - Replace with your actual backend URL

4. **Deploy**

Your frontend will be live at `https://your-app.vercel.app`

### Backend Deployment Options

#### Option 1: Railway (Recommended)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

#### Option 2: Render
1. Create new Web Service
2. Connect your GitHub repo
3. Set **Root Directory**: `backend`
4. **Build Command**: `pip install -r requirements.txt`
5. **Start Command**: `python app.py`

#### Option 3: DigitalOcean App Platform
- Similar to Render
- Good pricing for CPU-intensive workloads

#### Option 4: Self-hosted VPS
- Use any Linux server with Docker or systemd
- Best for full control and privacy

### Update CORS

Once backend is deployed, update `backend/app.py`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "https://your-app.vercel.app"  # Add your Vercel domain
    ],
    # ...
)
```

### Local Development with Production Backend

Create `frontend/.env.local`:
```
VITE_API_URL=https://your-backend-url.com
```

## How It Works

1. **Recording**: Browser captures audio via MediaRecorder API
2. **Upload**: Audio sent to local backend as WebM file
3. **Transcription**: faster-whisper processes audio using Whisper tiny model
4. **Summarization**: Rule-based NLP extracts structured information:
   - Key points from longest and initial sentences
   - Decisions from keywords (decided, agreed, will, etc.)
   - Action items from keywords (need to, must, task, etc.)
5. **Display**: Frontend shows transcript and structured summary

## Limitations (MVP)

- **No database**: Transcripts are not persisted
- **Basic summarization**: Uses keyword-based rules, not advanced AI
- **No speaker diarization**: Can't identify different speakers
- **Single language**: Optimized for English
- **No editing**: Transcript/summary cannot be edited in UI

These are intentional MVP constraints. Future versions can add these features.

## Future Enhancements

- [ ] Export to Markdown, PDF, or DOCX
- [ ] Database storage for session history
- [ ] Speaker diarization
- [ ] Better summarization with local LLMs (llama.cpp, etc.)
- [ ] Multi-language support
- [ ] In-app transcript editing
- [ ] Desktop app (Tauri/Electron)

## Troubleshooting

### Backend won't start
- Make sure Python 3.11+ is installed: `python3 --version`
- Check ffmpeg is installed: `ffmpeg -version`
- Verify virtual environment is activated

### Frontend won't start
- Make sure Node.js 18+ is installed: `node --version`
- Try deleting `node_modules` and running `npm install` again

### Microphone not working
- Check browser permissions (usually a popup on first use)
- Try Chrome/Firefox (best MediaRecorder support)
- Test on `http://localhost:5173` (not HTTPS needed for localhost)

### Transcription is slow
- Expected on CPU. Whisper tiny is optimized for speed.
- For longer audio, consider using `base` or `small` models (edit `transcriber.py`)

### CORS errors
- Backend CORS is configured for `http://localhost:5173`
- If using different port, update `app.py` CORS settings

## License

[Add your license here - e.g., MIT, Apache 2.0, etc.]

## Contributing

This is an MVP. Contributions welcome! Please open an issue first to discuss changes.

---

**Built with ❤️ for privacy and local-first software.**
