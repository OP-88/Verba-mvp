# Building Verba Packages

This document explains how to build platform-specific installer packages for Verba.

## Quick Start

```bash
# Build for your current platform
./build-all.sh
```

---

## Platform-Specific Builds

### 🐧 Linux

#### DEB Package (Debian/Ubuntu)

```bash
./build-deb.sh
```

**Output:** `verba_1.0.0_amd64.deb`

**Install:**
```bash
sudo dpkg -i verba_1.0.0_amd64.deb
sudo apt-get install -f  # Install dependencies
verba
```

#### RPM Package (Fedora/RHEL)

```bash
./build-rpm.sh
```

**Output:** `verba-1.0.0-1.fc*.x86_64.rpm`

**Install:**
```bash
sudo dnf install ./verba-1.0.0-1.*.rpm
verba
```

#### Desktop App (Any Linux)

```bash
./install-desktop.sh
```

This installs to `~/.local/share/verba` with a desktop launcher and menu entry.

---

### 🪟 Windows

**Requirements:**
- Windows machine
- [Inno Setup 6](https://jrsoftware.org/isdl.php)

**Build:**
```powershell
powershell -File build-windows.ps1
```

**Output:** `Verba-Setup-1.0.0.exe`

**Install:**
1. Double-click `Verba-Setup-1.0.0.exe`
2. Follow installation wizard
3. Installer checks for Python 3.11+ and Node.js 18+
4. Launch from Start Menu or Desktop shortcut

---

### 🍎 macOS

**Requirements:**
- macOS 11.0+
- Xcode Command Line Tools

**Build:**
```bash
./build-macos.sh
```

**Output:** `Verba-1.0.0.dmg`

**Install:**
1. Open `Verba-1.0.0.dmg`
2. Drag `Verba.app` to Applications
3. Run setup: `cd /Applications/Verba.app/Contents/Application && ./install-macos.sh`
4. Launch from Applications

---

## What Gets Built

### DEB Package Contents
```
/usr/share/verba/          # Application files
/usr/bin/verba             # Launcher script
/usr/share/applications/   # Desktop entry
/usr/share/icons/          # Application icon
```

### RPM Package Contents
```
/usr/share/verba/          # Application files  
/usr/bin/verba             # Launcher script
/usr/share/applications/   # Desktop entry
/usr/share/icons/          # Application icon
```

### Windows Installer
```
C:\Program Files\Verba\    # Application files
Start Menu shortcut
Desktop shortcut (optional)
```

### macOS DMG
```
/Applications/Verba.app/   # App bundle
  Contents/
    MacOS/verba            # Launcher
    Application/           # App files
    Resources/             # Icons
```

---

## Dependencies

All packages require:
- **Python 3.11+**
- **Node.js 18+**
- **ffmpeg**

### Automatic Dependency Installation

- **DEB**: `postinst` script sets up venv and npm
- **RPM**: `%post` script sets up environment
- **Windows**: Installer checks and prompts for downloads
- **macOS**: User runs `install-macos.sh` after drag-install

---

## Distribution

### GitHub Releases

1. Create a new release on GitHub
2. Upload the built packages:
   ```
   verba_1.0.0_amd64.deb
   verba-1.0.0-1.fc*.x86_64.rpm
   Verba-Setup-1.0.0.exe
   Verba-1.0.0.dmg
   ```

3. Users download and install for their platform

### Download Links

After uploading to GitHub releases, users can download:

```bash
# Linux (DEB)
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/verba_1.0.0_amd64.deb

# Linux (RPM)
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/verba-1.0.0-1.fc*.rpm

# Windows
# Download Verba-Setup-1.0.0.exe from releases page

# macOS
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba-1.0.0.dmg
```

---

## Testing Packages

### Linux DEB
```bash
sudo dpkg -i verba_1.0.0_amd64.deb
verba
./test_full_system.sh
```

### Linux RPM
```bash
sudo dnf install ./verba-1.0.0-1.*.rpm
verba
./test_full_system.sh
```

### Windows
```powershell
# Run installer
Verba-Setup-1.0.0.exe

# Launch and test
# Open http://localhost:5173
```

### macOS
```bash
open Verba-1.0.0.dmg
# Drag to Applications
cd /Applications/Verba.app/Contents/Application
./install-macos.sh
open -a Verba
```

---

## Troubleshooting

### DEB Build Fails
```bash
# Install required tools
sudo apt install dpkg-dev build-essential rsync
```

### RPM Build Fails
```bash
# Install RPM tools
sudo dnf install rpm-build rpmdevtools rpmlint
```

### Windows Build Fails
- Ensure Inno Setup 6 is installed
- Check paths in `build-windows.ps1`
- Run PowerShell as Administrator

### macOS Build Fails
- Install Xcode Command Line Tools: `xcode-select --install`
- Ensure you have write permissions to `/tmp`

---

## Version Updates

To update version numbers, edit these files:
- `build-deb.sh` - Line 6: `VERSION="1.0.0"`
- `build-rpm.sh` - Line 6: `VERSION="1.0.0"`
- `build-windows.ps1` - Line 5: `[string]$Version = "1.0.0"`
- `build-macos.sh` - Line 6: `VERSION="1.0.0"`

Or pass version as parameter:
```bash
./build-deb.sh 1.1.0
```

---

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Build Packages

on:
  push:
    tags:
      - 'v*'

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build DEB
        run: ./build-deb.sh
      - name: Upload DEB
        uses: actions/upload-artifact@v2
        with:
          name: verba-deb
          path: '*.deb'

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build EXE
        run: .\build-windows.ps1
      - name: Upload EXE
        uses: actions/upload-artifact@v2
        with:
          name: verba-exe
          path: '*.exe'

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build DMG
        run: ./build-macos.sh
      - name: Upload DMG
        uses: actions/upload-artifact@v2
        with:
          name: verba-dmg
          path: '*.dmg'
```

---

For more information, see [README.md](README.md)
