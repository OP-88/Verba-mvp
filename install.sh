#!/bin/bash
# Verba Installation Script
# Installs Verba as a local application

set -e

echo "🎙️ Verba Installation"
echo "===================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "❌ Please do not run this script as root"
   exit 1
fi

INSTALL_DIR="$HOME/.local/share/verba"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "📂 Installation directory: $INSTALL_DIR"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Python 3.11+
if ! command -v python3.11 &> /dev/null; then
    echo "❌ Python 3.11+ is required but not found"
    echo "   Install with: sudo dnf install python3.11"
    exit 1
fi
echo "   ✅ Python 3.11+"

# Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not found"
    echo "   Install with: sudo dnf install nodejs"
    exit 1
fi
echo "   ✅ Node.js"

# ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg is required but not found"
    echo "   Install with: sudo dnf install ffmpeg-free"
    exit 1
fi
echo "   ✅ ffmpeg"

echo ""

# Create installation directory
echo "📦 Installing Verba..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"

# Copy application files
echo "   Copying files..."
cp -r backend "$INSTALL_DIR/"
cp -r frontend "$INSTALL_DIR/"
cp start_verba.sh "$INSTALL_DIR/"
cp stop_verba.sh "$INSTALL_DIR/"
cp setup_system_audio.sh "$INSTALL_DIR/"
cp disable_system_audio.sh "$INSTALL_DIR/"
cp start_verba_network.sh "$INSTALL_DIR/" 2>/dev/null || true

# Setup Python virtual environment
echo "   Setting up Python environment..."
cd "$INSTALL_DIR/backend"
python3.11 -m venv venv
source venv/bin/activate
pip install -q -r requirements.txt
deactivate
cd - > /dev/null

# Install Node.js dependencies
echo "   Installing Node.js dependencies..."
cd "$INSTALL_DIR/frontend"
npm install --silent
cd - > /dev/null

# Create launcher script
echo "   Creating launcher..."
cat > "$BIN_DIR/verba" << 'EOF'
#!/bin/bash
VERBA_DIR="$HOME/.local/share/verba"
cd "$VERBA_DIR"
./start_verba.sh
EOF
chmod +x "$BIN_DIR/verba"

# Create desktop entry
echo "   Creating desktop entry..."
cat > "$DESKTOP_DIR/verba.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Verba
Comment=Offline-first AI meeting assistant
Exec=$BIN_DIR/verba
Icon=audio-recorder
Terminal=true
Categories=AudioVideo;Audio;Recorder;
Keywords=transcription;meeting;notes;whisper;ai;
EOF

# Make scripts executable
chmod +x "$INSTALL_DIR"/*.sh

echo ""
echo "=========================================="
echo "✅ Verba installed successfully!"
echo "=========================================="
echo ""
echo "📱 To start Verba, run:"
echo "   verba"
echo ""
echo "   Or from the application menu: Search for 'Verba'"
echo ""
echo "🔧 First-time setup:"
echo "   1. Run: cd $INSTALL_DIR && ./setup_system_audio.sh"
echo "   2. This enables recording of system audio + microphone"
echo ""
echo "📚 Documentation:"
echo "   Installation: $INSTALL_DIR"
echo "   Logs: $INSTALL_DIR/verba-*.log"
echo ""
echo "🗑️  To uninstall:"
echo "   rm -rf $INSTALL_DIR"
echo "   rm $BIN_DIR/verba"
echo "   rm $DESKTOP_DIR/verba.desktop"
echo ""
