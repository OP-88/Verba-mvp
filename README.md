# Verba - Offline AI Meeting Assistant

<div align="center">

**100% Private. 100% Offline. 100% Yours.**

Record meetings, transcribe speech, and generate structured notes—all locally on your device.  
No cloud. No tracking. No subscription.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/OP-88/Verba-mvp)](https://github.com/OP-88/Verba-mvp/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/OP-88/Verba-mvp/total)](https://github.com/OP-88/Verba-mvp/releases)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Node](https://img.shields.io/badge/node-18+-green.svg)](https://nodejs.org/)
[![Rust](https://img.shields.io/badge/rust-1.91+-orange.svg)](https://www.rust-lang.org/)

[Features](#-features) • [Quick Start](#-quick-start) • [Installation](#-installation) • [Documentation](#-documentation)

</div>

---

## ✨ Features

- **🎹️ Accurate Transcription** - OpenAI Whisper 'base' model for excellent accuracy
- **🌍 Multi-Accent Support** - Auto-detects language, handles different accents perfectly
- **⏱️ Long Recording Support** - Supports 3-4 hour recordings with VAD filtering
- **🔊 System Audio Capture** - Record videos, music, browser audio
- **📝 Smart Summarization** - Extract key points, decisions, action items
- **💾 Session History** - All meetings saved locally in SQLite
- **📱 Multi-Device Access** - Use from phone/tablet on local network
- **🔒 100% Private** - No cloud, no tracking, data never leaves your device
- **📤 Markdown Export** - Download professional meeting notes
- **⚡ Efficient Processing** - Base model: ~10-20s per minute of audio

## 🚀 Quick Start

### 📦 Standalone Desktop App (Recommended)

**True native application - no browser needed!**

✨ **What you get:**
- 🖥️ Native desktop window (not a browser tab)
- ⚡ Backend auto-starts/stops with the app
- 🔒 Works completely offline
- 📱 Real application in your menu/taskbar

**Download and install:**

<div align="center">

### 📥 Click to Download v1.0.0

[![Download DEB](https://img.shields.io/badge/Debian%2FUbuntu-Download%20DEB%20(167MB)-D70A53?style=for-the-badge&logo=debian&logoColor=white)](https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba_1.0.0_amd64.deb)
[![Download RPM](https://img.shields.io/badge/Fedora%2FRHEL-Download%20RPM%20(168MB)-0B57D0?style=for-the-badge&logo=fedora&logoColor=white)](https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba-1.0.0-1.x86_64.rpm)

[![Download for Windows](https://img.shields.io/badge/Windows-Download%20MSI%20(170MB)-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba_1.0.0_x64-setup.msi)
[![Download for macOS](https://img.shields.io/badge/macOS-Download%20DMG%20(165MB)-000000?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba_1.0.0_x64.dmg)

[![Build Status](https://github.com/OP-88/Verba-mvp/actions/workflows/release.yml/badge.svg)](https://github.com/OP-88/Verba-mvp/actions)

**Or browse all releases:** [github.com/OP-88/Verba-mvp/releases](https://github.com/OP-88/Verba-mvp/releases)

</div>

| Platform | Install Command | Launch |
|----------|----------------|--------|
| 🐧 **Debian/Ubuntu** | `sudo dpkg -i Verba_1.0.0_amd64.deb` or `sudo apt install ./Verba_1.0.0_amd64.deb` | Find "Verba" in apps menu |
| 🐧 **Fedora/RHEL** | `sudo dnf install ./Verba-1.0.0-1.x86_64.rpm` | Find "Verba" in apps menu |
| 🪟 **Windows** | Double-click the MSI installer | Find "Verba" in Start Menu |
| 🍎 **macOS** | Open DMG & drag to Applications | Find "Verba" in Applications |

**After install:** Find "Verba" in your applications menu → Click to launch → Native window opens instantly! 🎉

*\*Windows and macOS packages must be built on their respective platforms. Sizes are estimated.*

---

### 🌐 Alternative: Browser-Based Version

<details>
<summary><b>For developers or if you prefer browser interface</b></summary>

Runs in your web browser with separate backend process:
- Easy to develop and modify  
- Works with Chrome, Firefox, Safari  
- Requires manual start of backend + frontend

**🐧 Linux (Git)**

```bash
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp
./install.sh
verba
```

**🪟 Windows (PowerShell)**

```powershell
# Download and run installer script
Invoke-WebRequest -Uri https://raw.githubusercontent.com/OP-88/Verba-mvp/main/install-windows.ps1 -OutFile install-windows.ps1
powershell -ExecutionPolicy Bypass -File install-windows.ps1
```

**🍎 macOS (Git)**

```bash
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp
./install-macos.sh
./start_verba.sh
```

**Browser opens automatically at http://localhost:5173**

</details>

---

## 📥 Installation

### Option 1: Standalone Desktop App (Recommended)

See [Quick Start](#-quick-start) above for download links.

**Fedora/RHEL:**
```bash
sudo dnf install ./Verba-1.0.0-1.x86_64.rpm
# Launch from applications menu or run: verba
```

**Debian/Ubuntu:**
```bash
sudo dpkg -i Verba_1.0.0_amd64.deb
# Launch from applications menu or run: verba
```

**Windows:**
1. Download `Verba_1.0.0_x64-setup.msi`
2. Double-click to install
3. Launch "Verba" from Start Menu
4. Native window opens - no browser needed!

*Note: Windows package must be built on Windows. See [STANDALONE.md](STANDALONE.md) for build instructions.*

**macOS:**
1. Download `Verba_1.0.0_x64.dmg`
2. Open DMG and drag `Verba.app` to Applications
3. Launch from Applications (may need to right-click → Open first time)
4. Native window opens - no browser needed!

*Note: macOS package must be built on macOS. See [STANDALONE.md](STANDALONE.md) for build instructions.*

### Option 2: Build Standalone App Yourself

See [STANDALONE.md](STANDALONE.md) for instructions on building the native desktop app with Tauri.

### Option 3: Browser-Based Version (Development)

For developers who want to modify the code:

See [BUILD.md](BUILD.md) for instructions on building browser-based packages (DEB, RPM, EXE, DMG).

### Prerequisites (for manual development setup)

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


## 🎯 Usage

### Standalone Desktop App

1. **Launch Verba**: Find in applications menu or run `verba`
2. **Native Window Opens**: App window opens instantly (no browser!)
3. **Click RECORD**: Select audio source
   - 🔊 **System Audio** - Records computer audio (videos, music, etc.)
   - 🎤 **Microphone** - Records from microphone only
4. **Speak or Play Audio**: Record your meeting or content
5. **Click STOP**: Wait for AI transcription
6. **Click SUMMARIZE**: Get structured meeting notes
7. **Export**: Download as Markdown
8. **Close Window**: Backend automatically stops

### Browser-Based Version

1. **Start Verba**: Run `verba` or `./start_verba.sh`
2. **Browser Opens Automatically**: App opens at http://localhost:5173
3. Follow steps 3-7 above

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
**Frontend**: React 18 • Vite • TailwindCSS • Tauri (desktop app)  
**AI**: OpenAI Whisper (tiny model, runs locally)  
**Desktop**: Rust • Tauri • WebKit

## 📚 Documentation

### Core Docs
- **[STANDALONE.md](STANDALONE.md)** - 🖥️ **Build native desktop app (RECOMMENDED)**
- **[PRODUCTION_READY.md](PRODUCTION_READY.md)** - ✅ Production verification (100% test pass rate)
- **[READY_TO_RELEASE.md](READY_TO_RELEASE.md)** - 🚀 Release launch guide

### Installation & Build
- **[BUILD_PLATFORMS.md](BUILD_PLATFORMS.md)** - 🔨 **Build for Windows, macOS, and Linux**
- **[BUILD.md](BUILD.md)** - 📦 Build browser-based packages (legacy)
- **[INSTALL.md](INSTALL.md)** - Detailed installation guide
- **[INSTALL_WINDOWS.md](INSTALL_WINDOWS.md)** - Windows-specific setup

### Advanced
- **[NETWORK_ACCESS.md](NETWORK_ACCESS.md)** - Multi-device configuration
- **[RELEASE_NOTES.md](RELEASE_NOTES.md)** - Version history and changelog
- **[docs/LECTURE_DEMO_GUIDE.md](docs/LECTURE_DEMO_GUIDE.md)** - Demo guide

## 🧪 Testing

### Run Comprehensive Tests

```bash
./test_full_system.sh
```

This runs **36 automated tests** covering:
- ✅ Environment verification (Python, Node.js, ffmpeg)
- ✅ Backend API endpoints
- ✅ Database & storage with ISO 8601 timestamps
- ✅ Transcription & summarization
- ✅ Session management (CRUD operations)
- ✅ Frontend availability
- ✅ Dependencies verification
- ✅ Performance benchmarks (6-7ms response times)

**Current Status:** 100% pass rate (36/36 tests) ✅

---

## ⚠️ Known Issues

### Desktop App - Fedora/RHEL

The desktop app packages are currently built on Ubuntu and may have Python library compatibility issues on Fedora/RHEL systems. If you encounter "Backend server is unavailable" errors:

**Workaround:** Use the browser-based version instead:
```bash
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp
./install.sh
verba
```

**Status:** This will be fixed in v1.0.1 by using system Python instead of bundled dependencies.

---

## 🐛 Troubleshooting

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

We welcome contributions! Whether you're fixing bugs, adding features, or improving documentation.

### 🐛 Found a Bug?

**Please report it!** We want to make Verba better:

1. **Check existing issues**: https://github.com/OP-88/Verba-mvp/issues
2. **Create a new issue** with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Your system info (OS, version)
   - Error messages or screenshots

### 💡 Want to Contribute Code?

1. **Fork the repository**: Click "Fork" at https://github.com/OP-88/Verba-mvp
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Verba-mvp.git
   cd Verba-mvp
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** and test thoroughly
5. **Run tests**:
   ```bash
   ./test_full_system.sh
   ```
6. **Commit your changes**:
   ```bash
   git commit -m "Add your feature description"
   ```
7. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
8. **Submit a pull request** at https://github.com/OP-88/Verba-mvp/pulls

### 📋 Contribution Guidelines

- Write clear, descriptive commit messages
- Add tests for new features
- Update documentation as needed
- Follow existing code style
- Keep PRs focused on a single change
- Be respectful and constructive

### 🔧 Development Setup

See [BUILD_PLATFORMS.md](BUILD_PLATFORMS.md) for building on your platform.  
See [docs/WARP.md](docs/WARP.md) for detailed development environment setup.

### 🌟 Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🧪 Write tests
- 🎨 Improve UI/UX
- 🌍 Add translations
- 🔧 Fix issues

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
