#!/bin/bash
# Build standalone Tauri desktop app
# This creates a native app with embedded browser - NO external browser needed!

set -e

echo "========================================"
echo "  Building Verba Standalone Desktop App"
echo "  Platform: $(uname -s)"
echo "========================================"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Rust
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust not found!"
    echo "   Install from: https://rustup.rs/"
    echo "   Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi
echo "✅ Rust found: $(rustc --version)"

# Check Node.js
if ! command -v npm &> /dev/null; then
    echo "❌ Node.js not found!"
    exit 1
fi
echo "✅ Node.js found: $(node --version)"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python not found!"
    exit 1
fi
echo "✅ Python found: $(python3 --version)"

echo ""
echo "📦 Installing dependencies..."

# Install backend dependencies
echo "Setting up backend..."
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q
deactivate
cd ..

# Install frontend dependencies
echo "Setting up frontend..."
cd frontend
npm install --silent

echo ""
echo "🔨 Building standalone app..."

# Build with Tauri
npm run tauri build

echo ""
echo "✅ Build complete!"
echo ""

# Show output location
if [ "$(uname)" == "Darwin" ]; then
    echo "📦 macOS App Bundle:"
    ls -lh src-tauri/target/release/bundle/macos/*.app 2>/dev/null || echo "  (build output in src-tauri/target/release/bundle/)"
    echo ""
    echo "💿 macOS DMG:"
    ls -lh src-tauri/target/release/bundle/dmg/*.dmg 2>/dev/null || echo "  (build output in src-tauri/target/release/bundle/)"
elif [ "$(uname)" == "Linux" ]; then
    echo "📦 Linux Packages:"
    echo ""
    echo "DEB:"
    ls -lh src-tauri/target/release/bundle/deb/*.deb 2>/dev/null || echo "  (not built)"
    echo ""
    echo "RPM:"
    ls -lh src-tauri/target/release/bundle/rpm/*.rpm 2>/dev/null || echo "  (not built)"
    echo ""
    echo "AppImage:"
    ls -lh src-tauri/target/release/bundle/appimage/*.AppImage 2>/dev/null || echo "  (not built)"
else
    echo "📦 Windows Installer:"
    ls -lh src-tauri/target/release/bundle/msi/*.msi 2>/dev/null || echo "  (not built)"
fi

echo ""
echo "🎉 Standalone app ready!"
echo ""
echo "What this means:"
echo "  ✅ No browser needed - app has its own window"
echo "  ✅ Backend starts automatically when you launch"
echo "  ✅ Backend stops when you close the app"
echo "  ✅ Single executable - just double-click to run"
echo "  ✅ Installs like any other desktop app"
echo ""
echo "To test:"
echo "  cd src-tauri/target/release"
echo "  ./verba  # or open the .app/.exe/.AppImage"
echo ""
