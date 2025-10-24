# Verba - Public Beta v0.2.0

**Verba** is an offline-first meeting assistant that records speech, transcribes it locally using AI, and produces clean, structured meeting notes—all without sending your data to the cloud.

> **Private. Offline-first. Built for classrooms, meetings, and lectures.**

---

## 🎯 Current Capabilities (v0.2.0)

### ✅ Core Features
- **Audio Recording**: One-click browser-based recording with MediaRecorder API
- **Local Transcription**: Powered by OpenAI's Whisper (tiny model) via faster-whisper
- **Audio Preprocessing**: Automatic volume normalization and format optimization for better quality
- **Smart Summarization**: AI-powered extraction of key points, decisions, and action items
- **Session History**: All sessions automatically saved with SQLite persistence
- **Export to Markdown**: Download formatted meeting notes for sharing
- **Offline Mode**: Works completely offline once dependencies are installed
- **Responsive Design**: Works on desktop, tablet, and mobile browsers

### 💾 Session Management
- Browse past sessions in collapsible sidebar
- Click any session to view full transcript and summary
- Sessions persist across app restarts
- Export any session as beautifully formatted Markdown
- Automatic deduplication and cleaning

### 🎨 User Experience
- Real-time loading states and progress indicators
- Toast notifications for all operations
- Graceful error handling with user-friendly messages
- Status badge showing offline/enhanced mode
- Clean, modern UI with glassmorphism design
- Mobile-responsive layout

### 🔒 Privacy & Security
- **No cloud calls**: Everything runs on your machine
- **No tracking**: Zero analytics or telemetry
- **Local storage**: SQLite database on your machine
- **No account required**: Just download and run
- **Offline-capable**: Works without internet

---

## 🚀 Why Verba Matters

### Privacy
Your meeting notes often contain sensitive information—strategy discussions, personal details, financial data. With Verba, none of that ever leaves your device. No cloud provider can access, analyze, or leak your private conversations.

### Accessibility
Not everyone has reliable internet. Students in rural areas, professionals in secure facilities, or anyone wanting to work offline can use Verba without limitations.

### Reliability
Cloud services go down. APIs rate-limit. Verba works even when the internet doesn't. Your critical meeting notes are never held hostage by service outages.

### Cost
No monthly subscriptions. No per-minute billing. No surprise charges. Install once, use forever.

---

## 📋 Tech Stack

**Backend**:
- Python 3.11+
- FastAPI + Uvicorn (REST API)
- faster-whisper (Whisper tiny model)
- SQLAlchemy + SQLite (session persistence)
- Pydub (audio preprocessing)
- Rule-based NLP summarization

**Frontend**:
- React 18
- Vite (build tool)
- TailwindCSS (styling)
- Browser MediaRecorder API (audio capture)

---

## 🛠️ Installation & Setup

### Prerequisites

- **Python 3.11+** with pip
- **Node.js 18+** with npm
- **ffmpeg** (for audio processing)

#### Install ffmpeg

```bash
# Fedora/RHEL
sudo dnf install ffmpeg

# Debian/Ubuntu
sudo apt install ffmpeg

# macOS
brew install ffmpeg
```

### Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

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

---

## 🎮 Running Verba

You need **two terminals** running simultaneously:

### Terminal 1: Backend API

```bash
cd backend
source venv/bin/activate
python app.py
```

Backend runs at `http://localhost:8000`

### Terminal 2: Frontend UI

```bash
cd frontend
npm run dev
```

Frontend runs at `http://localhost:5173`

### Using Verba

1. Open `http://localhost:5173` in your browser
2. Click the **Record** button and allow microphone access
3. Speak your meeting content
4. Click **Stop** when finished
5. Wait for transcription (usually 5-15 seconds)
6. Click **Summarize** to generate structured notes
7. View your notes with key points, decisions, and action items
8. Click **Export** to download as Markdown
9. Access past sessions from the sidebar anytime

---

## 📁 Project Structure

```
verba-mvp/
├── backend/               # Python FastAPI server
│   ├── app.py            # Main API with all endpoints
│   ├── storage.py        # SQLite session persistence
│   ├── transcriber.py    # Whisper transcription + preprocessing
│   ├── summarizer.py     # NLP summarization logic
│   ├── settings.py       # Configuration management
│   ├── models/           # Database models (SQLAlchemy)
│   ├── requirements.txt  # Python dependencies
│   └── README_BACKEND.md # Backend documentation
│
├── frontend/             # React + Vite UI
│   ├── src/
│   │   ├── App.jsx           # Main application
│   │   ├── api.js            # API helper module
│   │   ├── main.jsx          # React entry point
│   │   ├── index.css         # Global styles
│   │   └── components/
│   │       ├── Header.jsx         # App header with status
│   │       ├── Recorder.jsx       # Audio recording
│   │       ├── TranscriptBox.jsx  # Transcript display
│   │       ├── SummaryBox.jsx     # Summary display
│   │       ├── SessionHistory.jsx # Past sessions sidebar
│   │       └── Toast.jsx          # Notifications
│   ├── index.html
│   ├── package.json
│   └── README_FRONTEND.md # Frontend documentation
│
└── README.md             # This file
```

---

## 🌐 API Endpoints

### Status
- `GET /api/status` - Get system status (online/offline mode, model info)

### Transcription
- `POST /api/transcribe` - Upload audio, receive transcript

### Summarization
- `POST /api/summarize` - Send transcript, receive structured summary

### Session Management
- `GET /api/sessions` - List all saved sessions
- `GET /api/sessions/{id}` - Get full session data
- `GET /api/sessions/{id}/export` - Export session as Markdown
- `DELETE /api/sessions/{id}` - Delete a session

---

## 🗺️ Roadmap to v1.0

### Near-term (Q1 2025)
- [ ] Desktop app (Tauri) - no browser required
- [ ] Speaker diarization - identify different speakers
- [ ] Multiple language support
- [ ] In-app transcript editing
- [ ] Custom export templates

### Mid-term (Q2 2025)
- [ ] Local LLM integration (llama.cpp) for better summaries
- [ ] Search across all sessions
- [ ] Tags and categories
- [ ] PDF export with formatting
- [ ] Audio playback with transcript sync

### Long-term (Q3-Q4 2025)
- [ ] Team collaboration features
- [ ] Optional cloud sync (encrypted)
- [ ] Mobile apps (iOS/Android)
- [ ] Real-time transcription during recording
- [ ] Integration with calendar apps

---

## 🐛 Troubleshooting

### Backend won't start
- Verify Python 3.11+: `python3 --version`
- Check ffmpeg: `ffmpeg -version`
- Ensure virtual environment is activated
- Try: `pip install --upgrade -r requirements.txt`

### Frontend won't start
- Verify Node.js 18+: `node --version`
- Delete `node_modules` and run `npm install` again
- Clear browser cache

### Microphone not working
- Check browser permissions (usually a popup)
- Use Chrome, Firefox, or Edge (best support)
- HTTPS not required for localhost

### Transcription is slow
- Expected on CPU (~5-15 seconds per minute of audio)
- Whisper tiny is optimized for speed over accuracy
- For better accuracy, edit `backend/settings.py` to use `base` or `small` model

### CORS errors
- Backend allows `http://localhost:5173` by default
- If using different port, update `backend/settings.py`
- Or set environment variable: `ALLOWED_ORIGINS=http://localhost:3000`

### Sessions not saving
- Check file permissions in backend directory
- Database file: `backend/verba_sessions.db`
- View logs in terminal for errors

---

## ⚙️ Configuration

### Environment Variables

Create `backend/.env` file:

```bash
# Feature flags
ONLINE_FEATURES_ENABLED=false

# Model configuration
WHISPER_MODEL_SIZE=tiny          # Options: tiny, base, small, medium, large
WHISPER_DEVICE=cpu               # Options: cpu, cuda
WHISPER_COMPUTE_TYPE=int8        # Options: int8, float16, float32

# Database
DATABASE_PATH=verba_sessions.db

# Audio processing
ENABLE_AUDIO_PREPROCESSING=true

# CORS (comma-separated)
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Frontend Configuration

Create `frontend/.env.local`:

```bash
VITE_API_URL=http://localhost:8000
```

---

## 📸 Screenshots

_Coming soon - add screenshots of:_
- Main dashboard with recording
- Transcript view
- Summary output
- Session history sidebar
- Export functionality

---

## 🤝 Contributing

Verba is in public beta. Contributions are welcome!

### How to contribute:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Please:
- Open an issue first to discuss major changes
- Write clear commit messages
- Add tests for new features
- Update documentation

---

## 📄 License

[Add your license here - e.g., MIT, Apache 2.0, GPL-3.0]

---

## 🙏 Acknowledgments

- **OpenAI Whisper**: For the incredible speech recognition model
- **faster-whisper**: For the optimized implementation
- **FastAPI**: For the elegant Python API framework
- **React & Vite**: For the modern frontend tooling
- **TailwindCSS**: For the beautiful styling system

---

## 📧 Contact & Support

- **Issues**: Open a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Email**: [Your email for support]

---

**Built with ❤️ for privacy and local-first software.**

_Verba - Your meetings, your notes, your data._
