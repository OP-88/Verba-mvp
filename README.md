# Verba - Offline AI Meeting Assistant

<div align="center">

**100% Private. 100% Offline. 100% Yours.**

Record meetings, transcribe speech, and generate structured notes—all locally on your device.  
No cloud. No tracking. No subscription.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Node](https://img.shields.io/badge/node-18+-green.svg)](https://nodejs.org/)

[Features](#-features) • [Quick Start](#-quick-start) • [Installation](#-installation) • [Documentation](#-documentation)

</div>

---

## ✨ Features

- **🎙️ Real-time Transcription** - OpenAI Whisper AI running locally
- **🔊 System Audio Capture** - Record videos, music, browser audio
- **📝 Smart Summarization** - Extract key points, decisions, action items
- **💾 Session History** - All meetings saved locally in SQLite
- **📱 Multi-Device Access** - Use from phone/tablet on local network
- **🔒 100% Private** - No cloud, no tracking, data never leaves your device
- **📤 Markdown Export** - Download professional meeting notes
- **⚡ Fast & Efficient** - Tiny model: ~5-15s per minute of audio

## 🚀 Quick Start

### 📥 Download & Run (Easiest)

**Pick your platform:**

| Platform | Download | Installation |
|----------|----------|-------------|
| 🐧 **Linux** | [verba-1.0.0-installer.sh](https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/verba-1.0.0-installer.sh) | `bash verba-1.0.0-installer.sh` |
| 🫵 **Windows** | [Setup Guide](INSTALL_WINDOWS.md) | See [INSTALL_WINDOWS.md](INSTALL_WINDOWS.md) |
| 🍎 **macOS** | [Manual Install](INSTALL.md) | `brew install python@3.11 node ffmpeg` |

**Linux users**: Just download and run the installer - it does everything!

### Alternative: One-Line Install

```bash
git clone https://github.com/OP-88/Verba-mvp.git && cd Verba-mvp && ./install.sh && verba
```

Then open: **http://localhost:5173** 🎉

### Prerequisites

<details>
<summary><b>Linux (Fedora/RHEL)</b></summary>

```bash
sudo dnf install python3.11 python3.11-devel nodejs ffmpeg-free ffmpeg-free-devel
```
</details>

<details>
<summary><b>Linux (Ubuntu/Debian)</b></summary>

```bash
sudo apt install python3.11 python3.11-dev python3.11-venv nodejs npm ffmpeg
```
</details>

<details>
<summary><b>Windows</b></summary>

1. Install [Python 3.11+](https://www.python.org/downloads/) (check "Add to PATH")
2. Install [Node.js](https://nodejs.org/)
3. Install [ffmpeg](https://www.gyan.dev/ffmpeg/builds/)

See [INSTALL_WINDOWS.md](INSTALL_WINDOWS.md) for detailed guide.
</details>

<details>
<summary><b>macOS</b></summary>

```bash
brew install python@3.11 node ffmpeg
```
</details>

## 📦 Installation

### Method 1: Quick Install Script (Recommended)

```bash
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp
./install.sh
verba
```

### Method 2: Manual Installation

See [INSTALL.md](INSTALL.md) for detailed manual setup instructions.

## 🎯 Usage

1. **Start Verba**: Run `verba` or `./start_verba.sh`
2. **Open Browser**: Navigate to http://localhost:5173
3. **Click RECORD**: Select audio source
   - 🔊 **System Audio** - Records computer audio (videos, music, etc.)
   - 🎤 **Microphone** - Records from microphone only
4. **Speak or Play Audio**: Record your meeting or content
5. **Click STOP**: Wait for AI transcription
6. **Click SUMMARIZE**: Get structured meeting notes
7. **Export**: Download as Markdown

### System Audio Recording (Linux)

Enable recording of system audio + microphone:
```bash
./setup_system_audio.sh
```

Disable:
```bash
./disable_system_audio.sh
```

## 🌐 Network Access

Access Verba from phone/tablet on same WiFi:

```bash
./start_verba_network.sh
```

Then open: **http://YOUR_IP:5173** from any device

See [NETWORK_ACCESS.md](NETWORK_ACCESS.md) for firewall configuration.

## 📋 Tech Stack

**Backend**: Python 3.11 • FastAPI • faster-whisper • SQLite  
**Frontend**: React 18 • Vite • TailwindCSS  
**AI**: OpenAI Whisper (tiny model, runs locally)

## 📚 Documentation

- **[INSTALL.md](INSTALL.md)** - Detailed installation guide
- **[INSTALL_WINDOWS.md](INSTALL_WINDOWS.md)** - Windows-specific setup
- **[NETWORK_ACCESS.md](NETWORK_ACCESS.md)** - Multi-device configuration
- **[RELEASE_NOTES.md](RELEASE_NOTES.md)** - Version history and changelog
- **[docs/LECTURE_DEMO_GUIDE.md](docs/LECTURE_DEMO_GUIDE.md)** - Demo and presentation guide

## 🛠️ Troubleshooting

### Transcription returns mock output
Make sure `faster-whisper` is properly installed:
```bash
cd backend
source venv/bin/activate
pip install faster-whisper requests
```

### Port already in use
```bash
./stop_verba.sh
# Or manually:
pkill -f "python app.py"
pkill -f "vite"
```

### Can't access from other devices
1. Use `./start_verba_network.sh`
2. Open firewall: `sudo firewall-cmd --add-port=5173/tcp --add-port=8000/tcp`
3. Check same WiFi network

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [docs/WARP.md](docs/WARP.md) for development setup.

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper) - Speech recognition model
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [React](https://react.dev/) - UI library
- [Vite](https://vitejs.dev/) - Frontend build tool

## ⭐ Support

If you find Verba useful, please star the repository!

**Issues & Questions**: https://github.com/OP-88/Verba-mvp/issues

---

<div align="center">

**Built with ❤️ for privacy and local-first software**

v1.0.0 | [Releases](https://github.com/OP-88/Verba-mvp/releases) | [Documentation](INSTALL.md) | [Report Bug](https://github.com/OP-88/Verba-mvp/issues)

</div>
