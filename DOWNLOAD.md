# Download Verba

**100% Private Offline AI Meeting Assistant**

---

## 📦 Desktop Installers (Recommended)

Click to download the installer for your operating system:

### 🐧 Linux

**Fedora / RHEL / CentOS:**
```bash
wget https://github.com/OP-88/Verba-mvp/releases/latest/download/verba-1.0.0-1.fc*.rpm
sudo dnf install ./verba-1.0.0-1.*.rpm
verba
```

**Debian / Ubuntu:**
```bash
wget https://github.com/OP-88/Verba-mvp/releases/latest/download/verba_1.0.0_amd64.deb
sudo dpkg -i verba_1.0.0_amd64.deb
sudo apt-get install -f
verba
```

### 🪟 Windows

1. **[Download Verba-Setup-1.0.0.exe](https://github.com/OP-88/Verba-mvp/releases/latest/download/Verba-Setup-1.0.0.exe)**
2. Double-click the installer
3. Follow the installation wizard
4. Launch from Start Menu

### 🍎 macOS

1. **[Download Verba-1.0.0.dmg](https://github.com/OP-88/Verba-mvp/releases/latest/download/Verba-1.0.0.dmg)**
2. Open the DMG file
3. Drag Verba to Applications folder
4. Open Terminal: `cd /Applications/Verba.app/Contents/Application && ./install-macos.sh`
5. Launch from Applications

---

## 🚀 What Happens After Install?

1. **Find "Verba" in your applications menu**
2. **Click to launch** - browser opens automatically
3. **Start recording meetings!**

---

## 📋 System Requirements

- **Python 3.11+** (auto-installed by package managers)
- **Node.js 18+** (auto-installed by package managers)
- **ffmpeg** (auto-installed by package managers)
- **~500MB disk space**
- **~500MB RAM** while running

---

## ❓ Having Issues?

### Installation Problems

**Linux:**
```bash
# Fedora/RHEL
sudo dnf install python3.11 nodejs ffmpeg-free

# Debian/Ubuntu
sudo apt install python3.11 nodejs ffmpeg
```

**Windows:**
- Installer checks for Python and Node.js
- Prompts to download if missing

**macOS:**
```bash
brew install python@3.11 node ffmpeg
```

### Running the App

After installation, find **Verba** in:
- **Linux:** Applications → Office → Verba
- **Windows:** Start Menu → Verba
- **macOS:** Applications → Verba

Or run from terminal:
```bash
verba
```

---

## 🔧 Advanced Installation

For manual installation or building from source, see:
- **[README.md](README.md)** - Complete documentation
- **[BUILD.md](BUILD.md)** - Build your own packages
- **[INSTALL.md](INSTALL.md)** - Manual installation guide

---

## 📞 Support

- **Documentation:** [README.md](README.md)
- **Issues:** [GitHub Issues](https://github.com/OP-88/Verba-mvp/issues)
- **Releases:** [All Versions](https://github.com/OP-88/Verba-mvp/releases)

---

## 🎯 Quick Start After Install

1. Launch Verba from your applications menu
2. Browser opens to http://localhost:5173
3. Click **RECORD** button
4. Select audio source (microphone or system audio)
5. Record your meeting
6. Click **STOP** to transcribe
7. Click **SUMMARIZE** for structured notes
8. **Export** to Markdown

---

**Verba v1.0.0** | 100% Private | 0% Cloud | MIT License
