#!/bin/bash
# Create Verba Self-Extracting Bundle
# Users just run one file - it auto-installs and launches

VERSION="1.0.0"
BUNDLE_NAME="verba-${VERSION}-installer.sh"

echo "📦 Creating Verba self-extracting bundle..."
echo ""

# Create temporary directory
TMP_DIR=$(mktemp -d)
BUNDLE_DIR="$TMP_DIR/verba-bundle"
mkdir -p "$BUNDLE_DIR"

# Copy application files (excluding dev files)
echo "   Packaging application..."
cp -r backend "$BUNDLE_DIR/"
cp -r frontend "$BUNDLE_DIR/"
cp *.sh "$BUNDLE_DIR/" 2>/dev/null || true
cp *.md "$BUNDLE_DIR/" 2>/dev/null || true

# Clean up dev files
rm -rf "$BUNDLE_DIR/backend/venv"
rm -rf "$BUNDLE_DIR/backend/__pycache__"
rm -rf "$BUNDLE_DIR/backend"/*.db
rm -rf "$BUNDLE_DIR/backend"/*.log
rm -rf "$BUNDLE_DIR/frontend/node_modules"
rm -rf "$BUNDLE_DIR/frontend/dist"

# Create tarball
cd "$TMP_DIR"
tar -czf verba-bundle.tar.gz verba-bundle/
BUNDLE_SIZE=$(du -h verba-bundle.tar.gz | cut -f1)
cd - > /dev/null

# Create self-extracting script
cat > "$BUNDLE_NAME" << 'EOFBUNDLE'
#!/bin/bash
# Verba Self-Extracting Installer v1.0.0
# One command to install and run Verba

set -e

INSTALL_DIR="$HOME/.local/share/verba"

echo "🎙️ Verba - Offline AI Meeting Assistant"
echo "=========================================="
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

MISSING_DEPS=()

if ! command -v python3.11 &> /dev/null; then
    MISSING_DEPS+=("python3.11")
fi

if ! command -v node &> /dev/null; then
    MISSING_DEPS+=("nodejs")
fi

if ! command -v ffmpeg &> /dev/null; then
    MISSING_DEPS+=("ffmpeg")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo ""
    echo "❌ Missing dependencies: ${MISSING_DEPS[*]}"
    echo ""
    echo "📥 Install them with:"
    echo ""
    if command -v dnf &> /dev/null; then
        echo "   sudo dnf install python3.11 python3.11-devel nodejs ffmpeg-free ffmpeg-free-devel"
    elif command -v apt &> /dev/null; then
        echo "   sudo apt install python3.11 python3.11-dev python3.11-venv nodejs npm ffmpeg"
    else
        echo "   Install: ${MISSING_DEPS[*]}"
    fi
    echo ""
    echo "Then run this installer again."
    exit 1
fi

echo "   ✅ All dependencies found"
echo ""

# Extract bundle
echo "📦 Installing Verba..."
mkdir -p "$INSTALL_DIR"

# Find the start of the tarball in this script
ARCHIVE_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")

# Extract the tarball
tail -n +"$ARCHIVE_LINE" "$0" | tar -xzf - -C "$INSTALL_DIR" --strip-components=1

# Setup backend
echo "   Setting up backend..."
cd "$INSTALL_DIR/backend"
python3.11 -m venv venv
source venv/bin/activate
pip install -q -r requirements.txt 2>&1 | grep -E "(Successfully|Collecting)" || true
deactivate

# Setup frontend
echo "   Setting up frontend..."
cd "$INSTALL_DIR/frontend"
npm install --silent 2>&1 | grep -v "npm WARN" || true

# Create launcher
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/verba" << 'EOFVERBA'
#!/bin/bash
VERBA_DIR="$HOME/.local/share/verba"
cd "$VERBA_DIR"
./start_verba.sh
EOFVERBA
chmod +x "$HOME/.local/bin/verba"

# Create desktop entry
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/verba.desktop" << EOFDESKTOP
[Desktop Entry]
Version=1.0
Type=Application
Name=Verba
Comment=Offline AI Meeting Assistant  
Exec=$HOME/.local/bin/verba
Icon=audio-recorder
Terminal=true
Categories=AudioVideo;Audio;Recorder;
EOFDESKTOP

echo ""
echo "=========================================="
echo "✅ Verba installed successfully!"
echo "=========================================="
echo ""
echo "🚀 To start Verba:"
echo ""
echo "   verba"
echo ""
echo "   Or search for 'Verba' in your application menu"
echo ""
echo "📚 First time? Run system audio setup:"
echo "   cd $INSTALL_DIR && ./setup_system_audio.sh"
echo ""
echo "🌐 For network access (phone/tablet):"
echo "   cd $INSTALL_DIR && ./start_verba_network.sh"
echo ""

exit 0

__ARCHIVE_BELOW__
EOFBUNDLE

# Append the tarball to the script
cat "$TMP_DIR/verba-bundle.tar.gz" >> "$BUNDLE_NAME"

# Make executable
chmod +x "$BUNDLE_NAME"

# Get final size
FINAL_SIZE=$(du -h "$BUNDLE_NAME" | cut -f1)

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "=========================================="
echo "✅ Self-extracting bundle created!"
echo "=========================================="
echo ""
echo "📦 File: $BUNDLE_NAME"
echo "💾 Size: $FINAL_SIZE (compressed)"
echo "📦 Contents: $BUNDLE_SIZE"
echo ""
echo "🚀 Distribution:"
echo ""
echo "   Users run ONE command:"
echo "   bash $BUNDLE_NAME"
echo ""
echo "   That's it! The script:"
echo "   - Checks prerequisites"
echo "   - Extracts and installs Verba"
echo "   - Sets up Python + Node environments"
echo "   - Creates 'verba' command"
echo "   - Adds desktop entry"
echo ""
echo "💡 No git clone, no ./install.sh, just one file!"
echo ""
