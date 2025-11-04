#!/bin/bash
# Create Verba AppImage - Portable Single-File Application

set -e

VERSION="1.0.0"
APP_NAME="Verba"
ARCH="x86_64"

echo "📦 Creating Verba AppImage..."
echo ""

# Install appimagetool if not available
if ! command -v appimagetool &> /dev/null; then
    echo "📥 Downloading appimagetool..."
    wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O /tmp/appimagetool
    chmod +x /tmp/appimagetool
    APPIMAGETOOL="/tmp/appimagetool"
else
    APPIMAGETOOL="appimagetool"
fi

# Create AppDir structure
APP_DIR="${APP_NAME}.AppDir"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"/{usr/bin,usr/lib,usr/share/applications,usr/share/icons/hicolor/256x256/apps}

echo "   Creating AppDir structure..."

# Copy application files
cp -r backend "$APP_DIR/usr/lib/verba-backend"
cp -r frontend "$APP_DIR/usr/lib/verba-frontend"
cp start_verba.sh "$APP_DIR/usr/lib/"
cp stop_verba.sh "$APP_DIR/usr/lib/"
cp setup_system_audio.sh "$APP_DIR/usr/lib/"
cp disable_system_audio.sh "$APP_DIR/usr/lib/"

# Create Python virtual environment with embedded Python
echo "   Setting up embedded Python environment..."
cd "$APP_DIR/usr/lib/verba-backend"
python3.11 -m venv --copies venv
source venv/bin/activate
pip install -q -r requirements.txt
deactivate
cd - > /dev/null

# Install Node.js dependencies
echo "   Installing Node.js dependencies..."
cd "$APP_DIR/usr/lib/verba-frontend"
npm install --silent
npm run build
cd - > /dev/null

# Create launcher script
echo "   Creating launcher..."
cat > "$APP_DIR/usr/bin/verba-launch" << 'EOFLAUNCH'
#!/bin/bash
# Verba AppImage Launcher

export APPDIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
export VERBA_DIR="$APPDIR/usr/lib"

cd "$VERBA_DIR"

# Start backend
export PATH="$APPDIR/usr/bin:$PATH"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"

# Activate Python venv
source "$VERBA_DIR/verba-backend/venv/bin/activate"

# Start backend in background
python "$VERBA_DIR/verba-backend/app.py" > /tmp/verba-backend.log 2>&1 &
BACKEND_PID=$!

# Wait for backend to be ready
sleep 3

# Start frontend with built-in server
cd "$VERBA_DIR/verba-frontend"
npx vite preview --port 5173 --host > /tmp/verba-frontend.log 2>&1 &
FRONTEND_PID=$!

# Open browser
sleep 2
xdg-open http://localhost:5173 2>/dev/null &

echo "Verba is running!"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo "Open: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop"

# Wait for interrupt
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0" INT TERM
wait
EOFLAUNCH

chmod +x "$APP_DIR/usr/bin/verba-launch"

# Create AppRun
cat > "$APP_DIR/AppRun" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "$0")")"
exec "$APPDIR/usr/bin/verba-launch" "$@"
EOF
chmod +x "$APP_DIR/AppRun"

# Create desktop entry
cat > "$APP_DIR/verba.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Verba
Comment=Offline AI Meeting Assistant
Exec=verba-launch
Icon=verba
Categories=AudioVideo;Audio;Recorder;
Terminal=true
EOF

# Copy to applications directory too
cp "$APP_DIR/verba.desktop" "$APP_DIR/usr/share/applications/"

# Create icon (simple text-based for now)
echo "   Creating icon..."
cat > "$APP_DIR/usr/share/icons/hicolor/256x256/apps/verba.png" << 'ICONEOF'
# Placeholder - in real app, use actual PNG
ICONEOF

# Symlink for icon
ln -sf usr/share/icons/hicolor/256x256/apps/verba.png "$APP_DIR/verba.png"
ln -sf verba.desktop "$APP_DIR/.DirIcon"

echo "   Building AppImage..."
$APPIMAGETOOL "$APP_DIR" "Verba-${VERSION}-${ARCH}.AppImage" 2>&1 | grep -v "WARNING"

# Make executable
chmod +x "Verba-${VERSION}-${ARCH}.AppImage"

# Get size
SIZE=$(du -h "Verba-${VERSION}-${ARCH}.AppImage" | cut -f1)

echo ""
echo "=========================================="
echo "✅ AppImage created!"
echo "=========================================="
echo ""
echo "📦 File: Verba-${VERSION}-${ARCH}.AppImage"
echo "💾 Size: $SIZE"
echo ""
echo "🚀 To use:"
echo "   1. Download Verba-${VERSION}-${ARCH}.AppImage"
echo "   2. chmod +x Verba-${VERSION}-${ARCH}.AppImage"
echo "   3. ./Verba-${VERSION}-${ARCH}.AppImage"
echo ""
echo "   That's it! No installation needed."
echo ""
