# Verba v1.0.0 - Release Notes

## 🎉 What's New

Verba is a **100% offline-first meeting assistant** that transcribes speech locally using Whisper AI and produces structured meeting notes—all without sending data to the cloud.

### Key Features

✅ **Real Whisper AI Transcription** - Runs locally on your computer  
✅ **System Audio Recording** - Capture videos, music, browser audio  
✅ **Audio Source Selection** - Choose between System Audio or Microphone  
✅ **Multi-Device Access** - Use from phone/tablet on local network  
✅ **Session History** - All meetings saved locally with SQLite  
✅ **Export to Markdown** - Professional meeting notes  
✅ **100% Privacy** - No cloud, no tracking, everything stays local

### Technical Stack

- **Backend:** Python 3.11 + FastAPI + faster-whisper + SQLite
- **Frontend:** React 18 + Vite + TailwindCSS  
- **Audio:** MediaRecorder API + PulseAudio/PipeWire + ffmpeg
- **AI Model:** OpenAI Whisper (tiny model by default)

## 📦 Installation

### Quick Install
```bash
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp
./install.sh
```

### Or Download Release
1. Download `verba-1.0.0-linux.tar.gz`
2. Extract: `tar -xzf verba-1.0.0-linux.tar.gz`
3. Run: `cd verba-1.0.0-linux && ./install.sh`

## 🚀 Usage

```bash
# Start Verba
verba

# Or from source
./start_verba.sh
```

Then open: **http://localhost:5173**

### Recording Audio
1. Click **RECORD** button
2. Select audio source:
   - 🔊 **System Audio** - Records computer audio (videos, music, apps)
   - 🎤 **Microphone** - Records from microphone only
3. Speak or play audio
4. Click **STOP**
5. Wait for transcription
6. Click **SUMMARIZE** for structured notes
7. **Export** as Markdown

## 🌐 Network Access

Access Verba from phone/tablet:

```bash
./start_verba_network.sh
```

Then from other devices: `http://YOUR_IP:5173`

## 📊 Performance

- **Tiny model:** ~5-15 seconds per minute of audio (fastest)
- **Base model:** ~10-30 seconds per minute (more accurate)
- Change model: Set `WHISPER_MODEL_SIZE=base` in `backend/.env`

## 🔧 System Requirements

- **OS:** Linux (Fedora, Ubuntu, Debian tested)
- **CPU:** Any modern x86_64 processor
- **RAM:** 2GB minimum, 4GB recommended
- **Storage:** 500MB for installation + models
- **Python:** 3.11+
- **Node.js:** 18+
- **ffmpeg:** Required for audio processing

## 🐛 Known Issues

None reported yet!

## 📝 Changelog

### v1.0.0 (2025-01-04)

**Features:**
- Initial release with full Whisper AI transcription
- Audio source selection dialog
- System audio + microphone recording
- Multi-device network access
- Session history and export
- One-command installation
- Desktop application entry

**Technical:**
- Fixed system audio capture (loopback from both sink monitor and mic)
- Improved device detection for PipeWire and PulseAudio
- Better recording state management
- CORS configuration for local network
- Comprehensive documentation

## 🤝 Contributing

Contributions welcome! See GitHub repository for guidelines.

## 📄 License

See LICENSE file in repository.

## 🙏 Acknowledgments

- OpenAI Whisper AI
- FastAPI framework
- React + Vite
- PulseAudio/PipeWire community

## 📚 Documentation

- **INSTALL.md** - Installation guide
- **NETWORK_ACCESS.md** - Multi-device setup
- **LECTURE_DEMO_GUIDE.md** - Demo and presentation tips
- **WARP.md** - Development guide

## 🔗 Links

- **GitHub:** https://github.com/OP-88/Verba-mvp
- **Issues:** https://github.com/OP-88/Verba-mvp/issues
- **Releases:** https://github.com/OP-88/Verba-mvp/releases
