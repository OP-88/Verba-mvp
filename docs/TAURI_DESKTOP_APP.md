# Verba Desktop App - Production Ready

## 🎯 Overview

This guide will help you create a production-ready desktop application using Tauri that:
- ✅ Bundles backend + frontend into ONE installable app
- ✅ Works on Windows, Linux, and macOS
- ✅ Uses REAL Whisper AI transcription (not mock)
- ✅ Runs completely offline
- ✅ Single `.exe`, `.deb`, `.dmg` installer

## 📋 Prerequisites

### All Platforms
- **Node.js 18+**: `node --version`
- **Rust**: `rustc --version`

### Platform-Specific

**Linux (Fedora/RHEL):**
```bash
sudo dnf install webkit2gtk4.1-devel openssl-devel curl wget file libappindicator-gtk3-devel librsvg2-devel
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev
```

**macOS:**
```bash
xcode-select --install
```

**Windows:**
- Install Visual Studio Build Tools
- Or: `winget install Microsoft.VisualStudio.2022.BuildTools`

## 🚀 Current Issue & Solution

**Problem:** Tauri is complex to set up with a Python backend.

**Better Solution:** Create a **standalone executable** that bundles everything.

## 📦 Recommended Approach: PyInstaller + Electron Alternative

Since Verba uses Python + React, here's the production-ready approach:

### Option 1: Standalone Executable (Recommended)

Use **PyInstaller** to create a single executable:

```bash
# Install PyInstaller
cd /home/marc/dev/Verba-mvp/backend
source venv/bin/activate
pip install pyinstaller

# Create standalone executable
pyinstaller --onefile --name verba-backend app.py

# This creates: dist/verba-backend (single executable!)
```

Then package frontend as static files and create an installer.

### Option 2: Docker Desktop App

Package as Docker container with Docker Desktop:

```bash
# Already have docker-compose.yml
docker-compose build
docker save verba > verba-app.tar
```

### Option 3: Electron (Instead of Tauri)

Electron is better suited for Python backends:

```bash
npm install --save-dev electron electron-builder
```

## 🎯 QUICK WIN: Create Native Installer Now

Let me create scripts that bundle everything into installers:

### For Linux (.deb / .rpm):

```bash
#!/bin/bash
# build-linux-installer.sh

# 1. Build frontend
cd frontend
npm run build

# 2. Package backend
cd ../backend
source venv/bin/activate
pip install pyinstaller
pyinstaller --onefile --add-data "../frontend/dist:dist" app.py

# 3. Create .deb package
mkdir -p verba-app/usr/local/bin
mkdir -p verba-app/usr/share/applications
cp dist/app verba-app/usr/local/bin/verba
dpkg-deb --build verba-app verba-1.0.0-amd64.deb
```

### For Windows (.exe):

```bash
# Use Inno Setup or NSIS
pyinstaller --onefile --windowed app.py
```

### For macOS (.dmg):

```bash
# Use create-dmg
npm install --save-dev create-dmg
```

## 💡 SIMPLEST PRODUCTION SOLUTION

Since you want it production-ready NOW, here's what I recommend:

### 1. Use Existing Web App + Systemd Service (Linux)

Create a system service that auto-starts Verba:

```bash
# /etc/systemd/system/verba.service
[Unit]
Description=Verba Meeting Assistant
After=network.target

[Service]
Type=simple
User=marc
WorkingDirectory=/home/marc/dev/Verba-mvp
ExecStart=/home/marc/dev/Verba-mvp/start_verba.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Then:
```bash
sudo systemctl enable verba
sudo systemctl start verba
```

Now Verba starts automatically on boot!

### 2. Create Desktop Shortcut

```bash
# ~/.local/share/applications/verba.desktop
[Desktop Entry]
Type=Application
Name=Verba Meeting Assistant
Comment=Offline-first meeting transcription
Exec=xdg-open http://localhost:5173
Icon=/home/marc/dev/Verba-mvp/frontend/public/icon.png
Terminal=false
Categories=Office;AudioVideo;
```

### 3. Package as AppImage (Universal Linux)

```bash
# Use AppImage builder
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage verba.AppDir
```

## 🔥 FASTEST PATH TO PRODUCTION

Given where you are RIGHT NOW, here's the fastest path:

1. **Verify Python 3.11 + faster-whisper is working**
2. **Test real transcription** (not mock)
3. **Create systemd service** for auto-start
4. **Create desktop shortcut**
5. **Document installation** for users

Then later:
6. Package as AppImage/Snap/Flatpak (Linux)
7. Create .exe installer (Windows)
8. Create .dmg (macOS)

## 📝 Next Steps

Let me:
1. ✅ Verify faster-whisper is installed correctly
2. ✅ Test real transcription
3. ✅ Create systemd service file
4. ✅ Create desktop launcher
5. ✅ Create installation script

This gets you production-ready in 10 minutes instead of days of Tauri setup.

## 🎯 Want Tauri Anyway?

If you still want Tauri, I'll need to:
1. Create `src-tauri/` directory structure
2. Write Rust code to spawn Python backend
3. Configure IPC between Rust and Python
4. Handle cross-platform Python bundling
5. Build for each platform separately

**Estimated time: 4-6 hours**

vs.

**Systemd + Desktop shortcut: 10 minutes**

Which approach do you prefer?
