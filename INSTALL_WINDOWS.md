# Verba Installation Guide - Windows

## Prerequisites

### 1. Install Python 3.11+
Download from: https://www.python.org/downloads/

**Important**: Check "Add Python to PATH" during installation

### 2. Install Node.js
Download from: https://nodejs.org/

### 3. Install ffmpeg
Download from: https://www.gyan.dev/ffmpeg/builds/

Extract and add to PATH:
1. Extract ffmpeg to `C:\ffmpeg`
2. Add `C:\ffmpeg\bin` to System PATH
3. Restart terminal

## Installation

### Option 1: Git Clone (Recommended)

```powershell
# Install Git if not already installed
# Download from: https://git-scm.com/download/win

# Clone repository
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp

# Run install script
.\install_windows.bat
```

### Option 2: Manual Installation

```powershell
# Download and extract Verba-mvp from GitHub

cd Verba-mvp

# Backend setup
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

# Frontend setup
cd ..\frontend
npm install

cd ..
```

## Running Verba

### Quick Start
```powershell
.\start_verba.bat
```

### Manual Start

**Terminal 1 - Backend:**
```powershell
cd backend
venv\Scripts\activate
python app.py
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
npm run dev
```

Then open: **http://localhost:5173**

## System Audio Recording (Windows)

Windows doesn't support system audio recording in browsers by default. You have two options:

### Option 1: Use VB-Audio Virtual Cable
1. Download: https://vb-audio.com/Cable/
2. Install VB-Audio Virtual Cable
3. Set it as your default audio device
4. In Verba, select VB-Audio Cable as microphone

### Option 2: Use Microphone Only
Just use the microphone option in Verba - no system audio.

## Troubleshooting

### Python not found
Make sure Python is in PATH:
```powershell
python --version
```

### ffmpeg not found
```powershell
ffmpeg -version
```
If not found, add ffmpeg to PATH and restart terminal.

### Port already in use
```powershell
# Kill processes on ports 8000 or 5173
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

## Uninstall

```powershell
# Remove installation
rmdir /s Verba-mvp

# Remove virtual environment
rmdir /s backend\venv
rmdir /s frontend\node_modules
```

## Performance

- **CPU Mode**: 5-15 seconds per minute of audio
- **GPU Mode** (if you have NVIDIA GPU with CUDA):
  - Edit `backend\.env`
  - Set `WHISPER_DEVICE=cuda`
  - Much faster transcription!
