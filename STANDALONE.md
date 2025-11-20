# Verba Standalone Desktop App

**✨ This is the RECOMMENDED way to run Verba!**

No browser required! Verba runs in its own native window with embedded browser engine.

---

## Why Standalone? 

### Standalone App (RECOMMENDED)
- ✅ **Own native window** - looks like a real desktop app
- ✅ **Backend auto-starts** - just double-click to launch
- ✅ **Single process** - close window = everything stops
- ✅ **No browser dependency** - works on headless servers
- ✅ **Professional appearance** - in app menus, taskbar, dock

### Browser-Based Version (For Development)
- ❌ Requires Chrome/Firefox/Safari
- ❌ Manual backend startup
- ❌ Two separate processes
- ✅ Easy to develop and debug

---

## Prerequisites

Install Rust (one-time setup):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

**Platform-specific requirements:**

<details>
<summary><b>🐧 Linux (Fedora/RHEL)</b></summary>

```bash
sudo dnf install webkit2gtk4.1-devel openssl-devel curl wget file \
    libappindicator-gtk3-devel librsvg2-devel
```
</details>

<details>
<summary><b>🐧 Linux (Debian/Ubuntu)</b></summary>

```bash
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file \
    libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
```
</details>

<details>
<summary><b>🪟 Windows</b></summary>

- Install [Microsoft Visual Studio C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
- Install [WebView2](https://developer.microsoft.com/en-us/microsoft-edge/webview2/) (usually pre-installed on Windows 11)
</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
xcode-select --install
```
</details>

---

## Building the Standalone App

### Option 1: Use the Build Script

```bash
cd /home/marc/projects/Verba-mvp
./build-tauri.sh
```

### Option 2: Manual Build

```bash
cd frontend
npm install
npm run tauri:build
```

---

## What Gets Built

### Linux
- **DEB Package**: `frontend/src-tauri/target/release/bundle/deb/verba_1.0.0_amd64.deb`
- **RPM Package**: `frontend/src-tauri/target/release/bundle/rpm/verba-1.0.0-1.x86_64.rpm`
- **AppImage**: `frontend/src-tauri/target/release/bundle/appimage/verba_1.0.0_amd64.AppImage`

### Windows
- **MSI Installer**: `frontend/src-tauri/target/release/bundle/msi/Verba_1.0.0_x64.msi`
- **EXE**: `frontend/src-tauri/target/release/verba.exe`

### macOS
- **App Bundle**: `frontend/src-tauri/target/release/bundle/macos/Verba.app`
- **DMG**: `frontend/src-tauri/target/release/bundle/dmg/Verba_1.0.0_x64.dmg`

---

## Installing & Running

### Quick Install (Recommended)

**Download from releases:**
- [Latest Release](https://github.com/OP-88/Verba-mvp/releases/latest)

### Linux (DEB/RPM)

```bash
# Fedora/RHEL (Current build: 168MB)
sudo dnf install ./Verba-1.0.0-1.x86_64.rpm
verba  # Launch

# Debian/Ubuntu (Current build: 167MB)
sudo dpkg -i Verba_1.0.0_amd64.deb
verba  # Launch
```

**After install:** Find "Verba" in your applications menu or run `verba` from terminal.

### Linux (AppImage - If Available)

```bash
# Make executable
chmod +x verba_1.0.0_amd64.AppImage

# Run
./verba_1.0.0_amd64.AppImage
```

*Note: AppImage build may fail due to upstream download issues. Use DEB/RPM instead.*

### Windows

1. Double-click `Verba_1.0.0_x64.msi`
2. Follow installer
3. Launch from Start Menu

### macOS

1. Open `Verba_1.0.0_x64.dmg`
2. Drag to Applications
3. Launch from Applications (no terminal needed!)

---

## How It Works

```
┌─────────────────────────────────────┐
│  Verba Desktop App                   │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  React Frontend               │ │
│  │  (Embedded in App Window)     │ │
│  └───────────────────────────────┘ │
│              ↕                      │
│  ┌───────────────────────────────┐ │
│  │  Python Backend               │ │
│  │  (Auto-started/stopped)       │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
        Single Native App
```

**When you launch:**
1. Tauri app window opens
2. Backend automatically starts in background
3. Frontend loads in the embedded window
4. Everything works seamlessly

**When you close:**
1. Window closes
2. Backend automatically stops
3. Clean shutdown

---

## Advantages

### For Users

✅ **Feels native** - Looks like any desktop app  
✅ **Simple** - Double-click to run  
✅ **No browser** - Works everywhere  
✅ **Offline** - Complete independence  
✅ **Professional** - Proper app icon, menu integration  

### For Developers

✅ **Single artifact** - One file to distribute  
✅ **Automatic updates** - Tauri supports this  
✅ **Cross-platform** - Same code, all OSes  
✅ **Smaller size** - ~30MB vs browser-based  
✅ **Better security** - Sandboxed environment  

---

## Comparison

| Feature | Browser-Based | Standalone App |
|---------|---------------|----------------|
| **Browser Required** | ✅ Chrome/Firefox | ❌ None |
| **Installation** | Script install | Native installer |
| **Startup** | Manual backend | Automatic |
| **Shutdown** | Manual stop | Automatic |
| **Window** | Browser tab | Native app window |
| **Taskbar/Dock** | Browser icon | Verba icon |
| **Offline** | ✅ Yes | ✅ Yes |
| **Size** | N/A | ~30-50MB |
| **Updates** | Git pull | Auto-update |

---

## Development Mode

Test the standalone app during development:

```bash
cd frontend
npm run tauri:dev
```

This launches the app with hot-reload enabled!

---

## Troubleshooting

### "Rust not found"
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### "webkit2gtk not found" (Linux)
```bash
# Fedora
sudo dnf install webkit2gtk4.1-devel

# Ubuntu
sudo apt install libwebkit2gtk-4.1-dev
```

### Build takes a long time
First build downloads Rust dependencies (~5-10 minutes). Subsequent builds are much faster (~1-2 minutes).

### Backend doesn't start
Make sure backend is in `resources` path:
```bash
ls frontend/src-tauri/target/release/backend/app.py
```

---

## File Size Comparison

**Browser-based install**: ~200MB (Python + Node modules)  
**Standalone app**: ~50MB (includes WebView)  
**AppImage**: ~60MB (fully portable)

---

## Distribution

Once built, distribute the standalone package:

1. **GitHub Releases**:
   - Upload the .deb, .rpm, .AppImage, .msi, .dmg
   - Users download and install like any app

2. **App Stores** (future):
   - Tauri supports publishing to app stores
   - Can submit to Flathub, Snap Store, Microsoft Store, Mac App Store

3. **Auto-updates**:
   - Tauri has built-in update system
   - Apps can check for and install updates automatically

---

## Next Steps

1. **Build it**: `./build-tauri.sh`
2. **Test it**: Double-click the built app
3. **Distribute it**: Upload to GitHub releases
4. **Enjoy**: Users get a professional desktop experience!

---

For more info:
- **Tauri Docs**: https://tauri.app/
- **README.md**: Main documentation
- **BUILD.md**: All build options

**Version**: 1.0.0 | **License**: MIT
