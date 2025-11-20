#!/bin/bash
# Build DEB package for Debian/Ubuntu

set -e

VERSION="1.0.0"
ARCH="amd64"

echo "========================================"
echo "  Building Verba DEB Package"
echo "  Version: $VERSION"
echo "========================================"
echo ""

# Create package directory structure
PKG_NAME="verba_${VERSION}_${ARCH}"
PKG_DIR="/tmp/$PKG_NAME"

echo "Creating package structure..."
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/share/verba"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PKG_DIR/usr/share/doc/verba"

# Copy application files
echo "Copying application files..."
rsync -av --exclude='node_modules' --exclude='venv' --exclude='.git' \
    --exclude='*.db' --exclude='*.log' --exclude='__pycache__' \
    backend "$PKG_DIR/usr/share/verba/"
rsync -av --exclude='node_modules' --exclude='.git' \
    frontend "$PKG_DIR/usr/share/verba/"
cp start_verba.sh "$PKG_DIR/usr/share/verba/"
cp README.md "$PKG_DIR/usr/share/doc/verba/"

# Create launcher script
echo "Creating launcher..."
cat > "$PKG_DIR/usr/bin/verba" << 'LAUNCHER_EOF'
#!/bin/bash
cd /usr/share/verba
exec ./start_verba.sh "$@"
LAUNCHER_EOF
chmod +x "$PKG_DIR/usr/bin/verba"

# Create desktop entry
cat > "$PKG_DIR/usr/share/applications/verba.desktop" << 'DESKTOP_EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Verba
Comment=Offline AI Meeting Assistant - 100% Private
Exec=verba
Icon=verba
Terminal=true
Categories=Office;AudioVideo;Recorder;Audio;
Keywords=meeting;transcription;AI;whisper;notes;offline;
StartupNotify=true
DESKTOP_EOF

# Copy icon
if [ -f "frontend/src-tauri/icons/128x128.png" ]; then
    cp frontend/src-tauri/icons/128x128.png \
        "$PKG_DIR/usr/share/icons/hicolor/256x256/apps/verba.png"
fi

# Create control file
cat > "$PKG_DIR/DEBIAN/control" << CONTROL_EOF
Package: verba
Version: $VERSION
Section: sound
Priority: optional
Architecture: $ARCH
Depends: python3 (>= 3.11), python3-venv, nodejs (>= 18), npm, ffmpeg
Maintainer: Verba Team <hello@verba.app>
Description: Offline AI Meeting Assistant
 Verba is a 100% offline, privacy-first AI meeting assistant.
 Record meetings, transcribe speech with OpenAI Whisper, and
 generate structured notes—all locally on your device.
 .
 Features:
  - Real-time transcription with Whisper AI
  - Smart summarization (key points, decisions, actions)
  - Session history with timestamps
  - Markdown export
  - 100% private - no cloud dependencies
Homepage: https://github.com/OP-88/Verba-mvp
CONTROL_EOF

# Create postinst script
cat > "$PKG_DIR/DEBIAN/postinst" << 'POSTINST_EOF'
#!/bin/bash
set -e

echo "Setting up Verba..."

# Setup backend
cd /usr/share/verba/backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate
fi

# Setup frontend
cd /usr/share/verba/frontend
if [ ! -d "node_modules" ]; then
    npm install
fi

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications
fi

echo "Verba installation complete!"
echo "Run 'verba' to launch the application."

exit 0
POSTINST_EOF

chmod +x "$PKG_DIR/DEBIAN/postinst"

# Create prerm script
cat > "$PKG_DIR/DEBIAN/prerm" << 'PRERM_EOF'
#!/bin/bash
set -e

# Stop any running instances
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "node.*vite" 2>/dev/null || true

exit 0
PRERM_EOF

chmod +x "$PKG_DIR/DEBIAN/prerm"

# Build package
echo "Building DEB package..."
dpkg-deb --build "$PKG_DIR"

# Move to current directory
mv "/tmp/${PKG_NAME}.deb" .

echo ""
echo "✅ DEB package created!"
echo ""
echo "Package: ${PKG_NAME}.deb"
echo ""
echo "To install:"
echo "  sudo dpkg -i ${PKG_NAME}.deb"
echo "  sudo apt-get install -f  # Install dependencies if needed"
echo ""
echo "To run after install:"
echo "  verba"
echo ""
