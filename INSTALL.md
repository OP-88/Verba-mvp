# Verba Installation Guide

## Quick Install (Linux)

```bash
# Clone the repository
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp

# Run the installer
./install.sh
```

This will:
- Install Verba to `~/.local/share/verba`
- Create a `verba` command in your PATH
- Add Verba to your application menu

## Manual Installation

### Prerequisites

**Fedora/RHEL:**
```bash
sudo dnf install python3.11 python3.11-devel nodejs ffmpeg-free ffmpeg-free-devel
```

**Ubuntu/Debian:**
```bash
sudo apt install python3.11 python3.11-dev python3.11-venv nodejs npm ffmpeg
```

### Setup

1. **Backend Setup:**
```bash
cd backend
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

2. **Frontend Setup:**
```bash
cd frontend
npm install
```

3. **System Audio (Optional but Recommended):**
```bash
./setup_system_audio.sh
```

## Running Verba

### After Installation
```bash
verba
```

### From Development Directory
```bash
./start_verba.sh
```

Then open: **http://localhost:5173**

## Network Access (Multi-Device)

To access from phone/tablet on same WiFi:

```bash
./start_verba_network.sh
```

Then from other devices: **http://YOUR_IP:5173**

### Opening Firewall Ports (if needed)
```bash
sudo firewall-cmd --add-port=5173/tcp --add-port=8000/tcp --permanent
sudo firewall-cmd --reload
```

## Usage

1. **Start Verba** - Run `verba` or `./start_verba.sh`
2. **Open browser** - Navigate to http://localhost:5173
3. **Click RECORD** - Select audio source:
   - 🔊 **System Audio** - Records computer audio (videos, music, etc.)
   - 🎤 **Microphone** - Records from microphone only
4. **Speak/Play audio** - Record your meeting or content
5. **Click STOP** - Wait for transcription
6. **Click SUMMARIZE** - Get structured meeting notes
7. **Export** - Download as Markdown

## Features

- ✅ **100% Offline** - No cloud, no tracking, no internet required
- ✅ **Real Whisper AI** - Runs locally on your computer
- ✅ **System Audio Recording** - Capture videos, music, browser audio
- ✅ **Multi-Device Access** - Use from phone/tablet on local network
- ✅ **Session History** - All meetings saved locally
- ✅ **Export to Markdown** - Professional meeting notes
- ✅ **Privacy First** - Everything stays on your device

## Troubleshooting

### Transcription returns only a few words

**Solution:** Make sure you selected "🔊 System Audio" option, not "Microphone".

### Can't access from other devices

**Solution:** 
1. Use `./start_verba_network.sh` instead of `./start_verba.sh`
2. Open firewall ports (see above)
3. Ensure devices are on same WiFi network

### "faster-whisper not available" error

**Solution:** 
```bash
cd backend
source venv/bin/activate
pip install faster-whisper
```

### Audio recording is silent

**Solution:** Run the system audio setup:
```bash
./setup_system_audio.sh
```

## Uninstall

```bash
# Remove installation
rm -rf ~/.local/share/verba
rm ~/.local/bin/verba
rm ~/.local/share/applications/verba.desktop

# Disable system audio
cd Verba-mvp
./disable_system_audio.sh
```

## System Requirements

- **OS:** Linux (Fedora, Ubuntu, Debian, etc.)
- **CPU:** Any modern x86_64 processor
- **RAM:** 2GB minimum, 4GB recommended
- **Storage:** 500MB for installation + models
- **Python:** 3.11 or higher
- **Node.js:** 18 or higher

## Performance

- **Tiny model:** ~5-15 seconds per minute of audio (fastest)
- **Base model:** ~10-30 seconds per minute (more accurate)
- **GPU acceleration:** Set `WHISPER_DEVICE=cuda` in backend/.env (requires CUDA)

## Support

- **GitHub:** https://github.com/OP-88/Verba-mvp
- **Issues:** https://github.com/OP-88/Verba-mvp/issues
- **Docs:** See WARP.md, NETWORK_ACCESS.md, LECTURE_DEMO_GUIDE.md

## License

See LICENSE file in repository.
