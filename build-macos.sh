#!/bin/bash
# Build macOS DMG installer

set -e

VERSION="1.0.0"
APP_NAME="Verba"
DMG_NAME="Verba-${VERSION}.dmg"

echo "========================================"
echo "  Building Verba macOS DMG"
echo "  Version: $VERSION"
echo "========================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Create app bundle structure
echo "📁 Creating app bundle..."
APP_DIR="/tmp/${APP_NAME}.app"
rm -rf "$APP_DIR"

mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
mkdir -p "$APP_DIR/Contents/Application"

# Copy application files
echo "📋 Copying application files..."
rsync -av --exclude='node_modules' --exclude='venv' --exclude='.git' \
    --exclude='*.db' --exclude='*.log' --exclude='__pycache__' \
    . "$APP_DIR/Contents/Application/"

# Create launcher script
echo "🚀 Creating launcher..."
cat > "$APP_DIR/Contents/MacOS/verba" << 'LAUNCHER_EOF'
#!/bin/bash
# Verba macOS Launcher

APP_DIR="$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")/Contents/Application"
cd "$APP_DIR"

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
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    python app.py > /tmp/verba-backend.log 2>&1 &
    BACKEND_PID=$!
    deactivate
else
    osascript -e 'display dialog "Backend not set up. Run install-macos.sh first." buttons {"OK"} default button "OK"'
    exit 1
fi

# Wait for backend
sleep 5

# Start frontend
cd ../frontend
npm run dev > /tmp/verba-frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait for frontend
sleep 5

# Open browser
open http://localhost:5173

# Show notification
osascript -e 'display notification "Meeting assistant is ready!" with title "Verba"'

echo "╔════════════════════════════════════════╗"
echo "║   Verba is Running!                    ║"
echo "╠════════════════════════════════════════╣"
echo "║  Open: http://localhost:5173           ║"
echo "║                                        ║"
echo "║  Close this window to stop Verba       ║"
echo "╚════════════════════════════════════════╝"

# Keep running
wait $BACKEND_PID $FRONTEND_PID
LAUNCHER_EOF

chmod +x "$APP_DIR/Contents/MacOS/verba"

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "$APP_DIR/Contents/Info.plist" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>verba</string>
    <key>CFBundleIdentifier</key>
    <string>com.verba.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>Verba needs access to your microphone to record meetings.</string>
</dict>
</plist>
PLIST_EOF

# Create icon (if you have one)
if [ -f "frontend/src-tauri/icons/icon.icns" ]; then
    cp "frontend/src-tauri/icons/icon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
else
    echo "⚠️  No icon found, skipping..."
fi

# Create DMG
echo "💿 Creating DMG..."
DMG_TEMP="/tmp/${APP_NAME}_temp.dmg"
DMG_FINAL="${DMG_NAME}"

# Remove old DMG if exists
rm -f "$DMG_TEMP" "$DMG_FINAL"

# Create temp DMG
hdiutil create -size 500m -fs HFS+ -volname "$APP_NAME" "$DMG_TEMP"

# Mount it
MOUNT_DIR="/Volumes/$APP_NAME"
hdiutil attach "$DMG_TEMP"

# Copy app
cp -R "$APP_DIR" "$MOUNT_DIR/"

# Create Applications symlink
ln -s /Applications "$MOUNT_DIR/Applications"

# Create README
cat > "$MOUNT_DIR/README.txt" << README_EOF
Verba - Offline AI Meeting Assistant
Version $VERSION

Installation:
1. Drag Verba.app to the Applications folder
2. Open Terminal and run: cd /Applications/Verba.app/Contents/Application && ./install-macos.sh
3. Launch Verba from Applications

Requirements:
- macOS 11.0 or later
- Python 3.11+
- Node.js 18+
- ffmpeg
- Homebrew (for easy dependency installation)

For help: https://github.com/OP-88/Verba-mvp
README_EOF

# Unmount
hdiutil detach "$MOUNT_DIR"

# Convert to compressed DMG
hdiutil convert "$DMG_TEMP" -format UDZO -o "$DMG_FINAL"

# Cleanup
rm -f "$DMG_TEMP"
rm -rf "$APP_DIR"

echo ""
echo "✅ macOS DMG created!"
echo ""
echo "Package: $DMG_FINAL"
echo ""
echo "To install:"
echo "  1. Open $DMG_FINAL"
echo "  2. Drag Verba to Applications"
echo "  3. Run setup: cd /Applications/Verba.app/Contents/Application && ./install-macos.sh"
echo "  4. Launch Verba from Applications"
echo ""
