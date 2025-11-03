# Verba - Local Deployment Guide

## 🚀 Quick Start

Run Verba on your local Fedora machine with one command:

```bash
./start_verba.sh
```

That's it! The script will:
1. Start the backend server (port 8000)
2. Start the frontend server (port 5173)
3. Open your browser automatically to http://localhost:5173

## 🛑 Stop Verba

```bash
./stop_verba.sh
```

Or manually:
```bash
pkill -f "python app.py"
pkill -f "vite"
```

## 📋 Manual Start (if you prefer)

### Terminal 1 - Backend:
```bash
cd backend
source venv/bin/activate
python app.py
```

### Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
```

Then open http://localhost:5173

## 📊 Check Status

```bash
# Backend health
curl http://localhost:8000/api/status

# Frontend
curl http://localhost:5173
```

## 📝 View Logs

```bash
# Backend logs
tail -f verba-backend.log

# Frontend logs
tail -f verba-frontend.log

# Both
tail -f verba-backend.log verba-frontend.log
```

## 🔧 Troubleshooting

### Port Already in Use

If ports 8000 or 5173 are busy:

```bash
# Kill processes on those ports
sudo lsof -ti:8000 | xargs kill -9
sudo lsof -ti:5173 | xargs kill -9

# Then restart
./start_verba.sh
```

### Backend Won't Start

```bash
# Check Python version (need 3.11+)
python3 --version

# Reinstall dependencies
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

### Frontend Won't Start

```bash
# Reinstall dependencies
cd frontend
rm -rf node_modules
npm install
```

## 🎯 URLs

- **Frontend UI**: http://localhost:5173
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs (FastAPI auto-docs)

## 📱 Using Verba

1. Click **Record** button
2. Allow microphone access
3. Speak your meeting notes
4. Click **Stop** when done
5. Wait for transcription (~5-15 seconds)
6. Click **Summarize** for AI-generated summary
7. Click **Export** to download as Markdown

## 🔒 Privacy

Everything runs locally:
- No cloud services
- No data leaves your machine
- No internet required (after setup)
- All sessions stored in local SQLite database

## 💾 Data Location

Your sessions are stored in:
```
backend/verba_sessions.db
```

To backup your data:
```bash
cp backend/verba_sessions.db ~/verba_backup_$(date +%Y%m%d).db
```

## 🐛 Common Issues

**"Backend not available"**
- Make sure Python virtual environment is activated
- Check `verba-backend.log` for errors
- Ensure port 8000 is free

**"Frontend build failed"**
- Delete `node_modules` and run `npm install` again
- Check Node.js version: `node --version` (need 18+)

**"Transcription slow"**
- Normal on CPU (5-15 seconds per minute of audio)
- Using "tiny" model for speed (set in `backend/.env`)

## 🎉 Success Indicators

When everything is working, you'll see:
```
✅ Verba is running locally!
📱 Open in browser: http://localhost:5173
🔧 Backend API:     http://localhost:8000
```

Your browser should open automatically to the Verba interface.
