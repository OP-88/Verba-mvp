#!/bin/bash
# Create Verba Release Package

VERSION="1.0.0"
RELEASE_NAME="verba-${VERSION}-linux"
RELEASE_DIR="releases/${RELEASE_NAME}"

echo "📦 Creating Verba v${VERSION} release package..."
echo ""

# Clean old releases
rm -rf releases
mkdir -p "$RELEASE_DIR"

# Copy application files
echo "   Copying application files..."
cp -r backend "$RELEASE_DIR/"
cp -r frontend "$RELEASE_DIR/"

# Copy scripts
cp start_verba.sh "$RELEASE_DIR/"
cp stop_verba.sh "$RELEASE_DIR/"
cp setup_system_audio.sh "$RELEASE_DIR/"
cp disable_system_audio.sh "$RELEASE_DIR/"
cp start_verba_network.sh "$RELEASE_DIR/"
cp install.sh "$RELEASE_DIR/"

# Copy documentation
cp README.md "$RELEASE_DIR/" 2>/dev/null || true
cp INSTALL.md "$RELEASE_DIR/"
cp NETWORK_ACCESS.md "$RELEASE_DIR/"
cp LECTURE_DEMO_GUIDE.md "$RELEASE_DIR/"
cp WARP.md "$RELEASE_DIR/" 2>/dev/null || true

# Clean up dev files
echo "   Cleaning up development files..."
rm -rf "$RELEASE_DIR/backend/venv"
rm -rf "$RELEASE_DIR/backend/__pycache__"
rm -rf "$RELEASE_DIR/backend/*.db"
rm -rf "$RELEASE_DIR/backend/*.log"
rm -rf "$RELEASE_DIR/frontend/node_modules"
rm -rf "$RELEASE_DIR/frontend/dist"
rm -rf "$RELEASE_DIR"/*.log

# Create release archive
echo "   Creating archive..."
cd releases
tar -czf "${RELEASE_NAME}.tar.gz" "${RELEASE_NAME}"
cd ..

# Get archive size
SIZE=$(du -h "releases/${RELEASE_NAME}.tar.gz" | cut -f1)

echo ""
echo "=========================================="
echo "✅ Release package created!"
echo "=========================================="
echo ""
echo "📦 Package: releases/${RELEASE_NAME}.tar.gz"
echo "💾 Size: $SIZE"
echo ""
echo "📋 Contents:"
echo "   - Backend (Python + FastAPI + Whisper AI)"
echo "   - Frontend (React + Vite)"
echo "   - Installation scripts"
echo "   - Documentation"
echo ""
echo "🚀 To distribute:"
echo "   1. Upload releases/${RELEASE_NAME}.tar.gz to GitHub Releases"
echo "   2. Users download and extract"
echo "   3. Run: ./install.sh"
echo ""
