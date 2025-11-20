#!/bin/bash
# Verba Desktop Installer
# Installs Verba as a desktop application with launcher icon

set -e

echo "========================================"
echo "  Verba Desktop Installer"
echo "  One-Click Linux Desktop App"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/share/verba"
DESKTOP_FILE="$HOME/.local/share/applications/verba.desktop"
ICON_FILE="$HOME/.local/share/icons/hicolor/256x256/apps/verba.png"

echo -e "${CYAN}📦 Installing dependencies...${NC}"

# Detect package manager and install deps
if command -v dnf &> /dev/null; then
    # Fedora/RHEL
    echo "Detected Fedora/RHEL - using DNF"
    sudo dnf install -y python3.11 python3.11-devel nodejs ffmpeg-free ffmpeg-free-devel 2>/dev/null || true
elif command -v apt &> /dev/null; then
    # Debian/Ubuntu  
    echo "Detected Debian/Ubuntu - using APT"
    sudo apt install -y python3.11 python3.11-dev python3.11-venv nodejs npm ffmpeg 2>/dev/null || true
elif command -v pacman &> /dev/null; then
    # Arch
    echo "Detected Arch - using Pacman"
    sudo pacman -S --noconfirm python nodejs npm ffmpeg 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  Could not detect package manager. Please install manually:${NC}"
    echo "  - Python 3.11+"
    echo "  - Node.js 18+"
    echo "  - ffmpeg"
    read -p "Press Enter once dependencies are installed..."
fi

echo ""
echo -e "${CYAN}📥 Installing Verba...${NC}"

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$ICON_FILE")"

# Copy current directory to install location
echo "Copying files to $INSTALL_DIR..."
rsync -av --exclude='node_modules' --exclude='venv' --exclude='.git' --exclude='*.db' \
    . "$INSTALL_DIR/" || cp -r . "$INSTALL_DIR/"

cd "$INSTALL_DIR"

# Run installation
echo -e "${CYAN}🔧 Setting up backend...${NC}"
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q
deactivate
cd ..

echo -e "${CYAN}🔧 Setting up frontend...${NC}"
cd frontend
npm install --silent
cd ..

# Create launcher script
echo -e "${CYAN}🚀 Creating launcher...${NC}"
cat > "$INSTALL_DIR/verba-launcher.sh" << 'LAUNCHER_EOF'
#!/bin/bash
# Verba Launcher Script

VERBA_DIR="$HOME/.local/share/verba"
cd "$VERBA_DIR"

# Function to cleanup on exit
cleanup() {
    echo "Stopping Verba..."
    pkill -f "python.*app.py" 2>/dev/null
    pkill -f "node.*vite" 2>/dev/null
    exit 0
}

trap cleanup EXIT INT TERM

# Start backend
cd backend
source venv/bin/activate
python app.py > /tmp/verba-backend.log 2>&1 &
BACKEND_PID=$!
deactivate

# Wait for backend
echo "Starting Verba backend..."
sleep 5

# Start frontend
cd ../frontend
npm run dev > /tmp/verba-frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait for frontend
echo "Starting Verba frontend..."
sleep 5

# Open browser
xdg-open http://localhost:5173 2>/dev/null &

# Show notification
notify-send "Verba" "Meeting assistant is ready!" -i audio-recorder 2>/dev/null

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Verba is Running!                    ║"
echo "╠════════════════════════════════════════╣"
echo "║  Open: http://localhost:5173           ║"
echo "║                                        ║"
echo "║  Close this window to stop Verba       ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Keep running
wait $BACKEND_PID $FRONTEND_PID
LAUNCHER_EOF

chmod +x "$INSTALL_DIR/verba-launcher.sh"

# Create desktop entry
echo -e "${CYAN}🖥️  Creating desktop entry...${NC}"
cat > "$DESKTOP_FILE" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Verba
Comment=Offline AI Meeting Assistant - 100% Private
Exec=$INSTALL_DIR/verba-launcher.sh
Icon=verba
Terminal=true
Categories=Office;AudioVideo;Recorder;Audio;
Keywords=meeting;transcription;AI;whisper;notes;
StartupNotify=true
DESKTOP_EOF

chmod +x "$DESKTOP_FILE"

# Create icon
echo -e "${CYAN}🎨 Creating application icon...${NC}"
if [ -f "$INSTALL_DIR/frontend/src-tauri/icons/128x128.png" ]; then
    cp "$INSTALL_DIR/frontend/src-tauri/icons/128x128.png" "$ICON_FILE"
else
    # Create a simple SVG icon and convert to PNG
    cat > /tmp/verba-icon.svg << 'SVG_EOF'
<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg">
  <rect width="256" height="256" rx="40" fill="#6366F1"/>
  <circle cx="128" cy="100" r="40" fill="white"/>
  <rect x="108" y="140" width="40" height="80" rx="20" fill="white"/>
  <circle cx="88" cy="180" r="15" fill="white" opacity="0.7"/>
  <circle cx="168" cy="180" r="15" fill="white" opacity="0.7"/>
</svg>
SVG_EOF
    
    if command -v convert &> /dev/null; then
        convert /tmp/verba-icon.svg "$ICON_FILE"
    elif command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w 256 -h 256 /tmp/verba-icon.svg -o "$ICON_FILE"
    else
        # Fallback: use a simple colored square
        convert -size 256x256 xc:#6366F1 -pointsize 120 -fill white -gravity center \
            -annotate +0+0 "V" "$ICON_FILE" 2>/dev/null || true
    fi
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Create command line launcher
echo -e "${CYAN}💻 Creating command line launcher...${NC}"
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/verba" << BIN_EOF
#!/bin/bash
exec "$INSTALL_DIR/verba-launcher.sh" "\$@"
BIN_EOF
chmod +x "$HOME/.local/bin/verba"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo -e "${YELLOW}⚠️  Added ~/.local/bin to PATH in .bashrc${NC}"
    echo -e "${YELLOW}   Run 'source ~/.bashrc' or restart terminal${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}To launch Verba:${NC}"
echo ""
echo "  1️⃣  Find 'Verba' in your application menu"
echo "  2️⃣  Or run from terminal: verba"
echo "  3️⃣  Or click: $DESKTOP_FILE"
echo ""
echo -e "${CYAN}Installed to:${NC} $INSTALL_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
