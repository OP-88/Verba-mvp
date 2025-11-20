# Building Verba for All Platforms

This guide covers building the standalone desktop app on **Windows**, **macOS**, and **Linux**.

---

## Important: Platform-Specific Builds Required

⚠️ **Tauri applications must be built on their target platform.** Cross-compilation is not officially supported.

- **Windows MSI/EXE** → Build on Windows
- **macOS DMG/App** → Build on macOS
- **Linux DEB/RPM** → Build on Linux

---

## Windows Build Instructions

### Prerequisites

1. **Install Rust**
   ```powershell
   # Download and run from https://rustup.rs/
   # Or use winget:
   winget install Rustlang.Rustup
   ```

2. **Install Node.js**
   ```powershell
   winget install OpenJS.NodeJS.LTS
   ```

3. **Install Python 3.11+**
   ```powershell
   winget install Python.Python.3.11
   ```

4. **Install Visual Studio Build Tools**
   - Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - Select "Desktop development with C++"

5. **Install WebView2**
   - Usually pre-installed on Windows 10/11
   - Download from: https://developer.microsoft.com/en-us/microsoft-edge/webview2/

### Build Steps

```powershell
# Clone repository
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp

# Setup backend
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
deactivate
cd ..

# Build standalone app
cd frontend
npm install
npm run tauri build
```

### Output Location

After successful build:
- **MSI Installer**: `frontend\src-tauri\target\release\bundle\msi\Verba_1.0.0_x64-setup.msi`
- **Portable EXE**: `frontend\src-tauri\target\release\verba.exe`

### Testing

```powershell
# Run the built executable
.\frontend\src-tauri\target\release\verba.exe
```

---

## macOS Build Instructions

### Prerequisites

1. **Install Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

2. **Install Rust**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   ```

3. **Install Homebrew** (if not already installed)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. **Install Dependencies**
   ```bash
   brew install node python@3.11 ffmpeg
   ```

### Build Steps

```bash
# Clone repository
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp

# Setup backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

# Build standalone app
cd frontend
npm install
npm run tauri build
```

### Output Location

After successful build:
- **App Bundle**: `frontend/src-tauri/target/release/bundle/macos/Verba.app`
- **DMG Image**: `frontend/src-tauri/target/release/bundle/dmg/Verba_1.0.0_x64.dmg`

### Testing

```bash
# Run the built app
open frontend/src-tauri/target/release/bundle/macos/Verba.app
```

### Code Signing (Optional but Recommended)

For distribution without Gatekeeper warnings:

```bash
# Sign the app (requires Apple Developer account)
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" Verba.app

# Create signed DMG
hdiutil create -volname Verba -srcfolder Verba.app -ov -format UDZO Verba-Signed.dmg
```

---

## Linux Build Instructions

### Prerequisites (Fedora/RHEL)

```bash
sudo dnf install -y webkit2gtk4.1-devel openssl-devel curl wget file \
    libappindicator-gtk3-devel librsvg2-devel \
    python3.11 python3.11-devel nodejs ffmpeg-free
```

### Prerequisites (Debian/Ubuntu)

```bash
sudo apt install -y libwebkit2gtk-4.1-dev build-essential curl wget file \
    libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev \
    python3.11 python3.11-dev python3.11-venv nodejs npm ffmpeg
```

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Build Steps

```bash
# Clone repository
git clone https://github.com/OP-88/Verba-mvp.git
cd Verba-mvp

# Use the build script (easiest)
./build-tauri.sh
```

Or manually:

```bash
# Setup backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

# Build standalone app
cd frontend
npm install
npm run tauri build
```

### Output Location

After successful build:
- **DEB Package**: `frontend/src-tauri/target/release/bundle/deb/Verba_1.0.0_amd64.deb` (167MB)
- **RPM Package**: `frontend/src-tauri/target/release/bundle/rpm/Verba-1.0.0-1.x86_64.rpm` (168MB)
- **AppImage**: `frontend/src-tauri/target/release/bundle/appimage/verba_1.0.0_amd64.AppImage` (if build succeeds)

### Testing

```bash
# Install and run (Fedora)
sudo dnf install ./frontend/src-tauri/target/release/bundle/rpm/Verba-1.0.0-1.x86_64.rpm
verba

# Install and run (Debian/Ubuntu)
sudo dpkg -i ./frontend/src-tauri/target/release/bundle/deb/Verba_1.0.0_amd64.deb
verba

# Run AppImage directly (no install)
chmod +x ./frontend/src-tauri/target/release/bundle/appimage/verba_1.0.0_amd64.AppImage
./frontend/src-tauri/target/release/bundle/appimage/verba_1.0.0_amd64.AppImage
```

---

## Build Troubleshooting

### Windows Issues

**Error: "WebView2 not found"**
- Install WebView2 Runtime from Microsoft
- Restart your terminal

**Error: "MSVC not found"**
- Install Visual Studio Build Tools with C++ workload
- Restart your terminal

### macOS Issues

**Error: "Command line tools not found"**
```bash
xcode-select --install
```

**Error: "Gatekeeper blocks app"**
- Right-click app → "Open" → "Open anyway"
- Or disable Gatekeeper temporarily: `sudo spctl --master-disable`

**Error: "Backend not found"**
- Ensure backend/venv exists and has dependencies installed
- Check tauri.conf.json has `"resources": ["../../backend"]`

### Linux Issues

**Error: "webkit2gtk not found"**
```bash
# Fedora
sudo dnf install webkit2gtk4.1-devel

# Ubuntu
sudo apt install libwebkit2gtk-4.1-dev
```

**Error: "AppImage build failed with 503"**
- This is an upstream issue with AppImage download server
- Use DEB or RPM packages instead
- AppImage is optional; installers work fine

---

## CI/CD Automation

### GitHub Actions Example

Create `.github/workflows/build.yml`:

```yaml
name: Build Standalone Apps

on:
  push:
    tags:
      - 'v*'

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - uses: dtolnay/rust-toolchain@stable
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y libwebkit2gtk-4.1-dev build-essential curl wget file \
            libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
      - name: Build
        run: ./build-tauri.sh
      - uses: actions/upload-artifact@v3
        with:
          name: linux-packages
          path: frontend/src-tauri/target/release/bundle/**/*

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - uses: dtolnay/rust-toolchain@stable
      - name: Build
        run: |
          cd frontend
          npm install
          npm run tauri build
      - uses: actions/upload-artifact@v3
        with:
          name: windows-msi
          path: frontend/src-tauri/target/release/bundle/msi/*.msi

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - uses: dtolnay/rust-toolchain@stable
      - name: Build
        run: |
          cd frontend
          npm install
          npm run tauri build
      - uses: actions/upload-artifact@v3
        with:
          name: macos-dmg
          path: frontend/src-tauri/target/release/bundle/dmg/*.dmg
```

---

## Package Sizes

| Platform | Package Type | Size |
|----------|--------------|------|
| Linux | DEB | ~167MB |
| Linux | RPM | ~168MB |
| Linux | AppImage | ~170MB |
| Windows | MSI | ~170MB* |
| macOS | DMG | ~165MB* |

*Estimated sizes for Windows and macOS (must be built on respective platforms)

---

## Distribution Checklist

Before releasing packages:

- [ ] Built on native platform (not cross-compiled)
- [ ] Tested installation process
- [ ] Tested launch and basic functionality
- [ ] Verified backend auto-starts/stops
- [ ] Checked application icon displays correctly
- [ ] Windows: Test on Windows 10 and 11
- [ ] macOS: Test Gatekeeper behavior (unsigned)
- [ ] Linux: Test on both DEB and RPM distros
- [ ] Document any platform-specific quirks
- [ ] Create GitHub release with all packages

---

## Next Steps

After building packages:

1. **Test thoroughly** on target platform
2. **Upload to GitHub Releases**
3. **Update README.md** with download links
4. **Create release notes** describing changes
5. **Announce release** to users

See [STANDALONE.md](STANDALONE.md) for user installation instructions.
