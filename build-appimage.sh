#!/bin/bash
# Build Verba as a standalone AppImage for Linux
# This creates a single executable file that includes everything

set -e

echo "========================================"
echo "  Verba AppImage Builder"
echo "  Creating standalone Linux desktop app"
echo "========================================"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -f "frontend/package.json" ]; then
    echo "Error: Must be run from Verba project root"
    exit 1
fi

# Install AppImage tools if not present
echo "📦 Checking AppImage tools..."
if ! command -v appimagetool &> /dev/null; then
    echo "Downloading appimagetool..."
    wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O /tmp/appimagetool
    chmod +x /tmp/appimagetool
    APPIMAGETOOL="/tmp/appimagetool"
else
    APPIMAGETOOL="appimagetool"
fi

# Create AppDir structure
echo "📁 Creating AppDir structure..."
APPDIR="Verba.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# Copy application files
echo "📋 Copying application files..."
cp -r backend "$APPDIR/usr/lib/verba-backend"
cp -r frontend "$APPDIR/usr/lib/verba-frontend"
cp start_verba.sh "$APPDIR/usr/lib/start_verba.sh"

# Create launcher script
echo "🚀 Creating launcher..."
cat > "$APPDIR/usr/bin/verba" << 'EOF'
#!/bin/bash
# Verba AppImage Launcher

APPDIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
cd "$APPDIR/usr/lib"

# Start backend
cd verba-backend
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    python app.py &
    BACKEND_PID=$!
else
    echo "Error: Backend virtual environment not found"
    exit 1
fi

# Wait for backend to start
sleep 3

# Start frontend
cd ../verba-frontend
npm run dev &
FRONTEND_PID=$!

# Open browser
sleep 2
xdg-open http://localhost:5173 &

# Wait for user to close
echo "Verba is running! Close this window to stop."
echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:5173"
wait $FRONTEND_PID $BACKEND_PID
EOF

chmod +x "$APPDIR/usr/bin/verba"

# Create desktop entry
cat > "$APPDIR/usr/share/applications/verba.desktop" << EOF
[Desktop Entry]
Name=Verba
Comment=Offline AI Meeting Assistant
Exec=verba
Icon=verba
Type=Application
Categories=Office;AudioVideo;Recorder;
Terminal=false
StartupNotify=true
EOF

# Create AppRun
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$APPDIR/usr/bin:$PATH"
exec "$APPDIR/usr/bin/verba" "$@"
EOF

chmod +x "$APPDIR/AppRun"

# Create icon (placeholder - you should add a real icon)
echo "🎨 Creating icon..."
if [ -f "frontend/src-tauri/icons/128x128.png" ]; then
    cp "frontend/src-tauri/icons/128x128.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/verba.png"
    cp "frontend/src-tauri/icons/128x128.png" "$APPDIR/verba.png"
else
    # Create a simple placeholder icon
    convert -size 256x256 xc:#6366F1 -pointsize 120 -fill white -gravity center -annotate +0+0 "V" "$APPDIR/verba.png"
fi

# Link .desktop file to AppDir root
ln -s usr/share/applications/verba.desktop "$APPDIR/verba.desktop"

# Build AppImage
echo "🔨 Building AppImage..."
"$APPIMAGETOOL" "$APPDIR" Verba-x86_64.AppImage

echo ""
echo "✅ AppImage created: Verba-x86_64.AppImage"
echo ""
echo "To use it:"
echo "  chmod +x Verba-x86_64.AppImage"
echo "  ./Verba-x86_64.AppImage"
echo ""
