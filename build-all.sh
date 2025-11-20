#!/bin/bash
# Master build script - builds packages for all platforms

echo "========================================"
echo "  Verba Multi-Platform Builder"
echo "  Building for Linux, Windows, macOS"
echo "========================================"
echo ""

# Detect current platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
else
    PLATFORM="unknown"
fi

echo "Current platform: $PLATFORM"
echo ""

# Build for Linux
if [ "$PLATFORM" == "linux" ]; then
    echo "🐧 Building Linux packages..."
    
    # Build DEB
    if [ -f "build-deb.sh" ]; then
        echo "Building DEB package..."
        chmod +x build-deb.sh
        ./build-deb.sh
    fi
    
    # Build RPM
    if [ -f "build-rpm.sh" ]; then
        echo "Building RPM package..."
        chmod +x build-rpm.sh
        ./build-rpm.sh
    fi
    
    echo ""
    echo "✅ Linux packages built:"
    ls -lh *.deb *.rpm 2>/dev/null || echo "No packages found"
fi

# Build for macOS
if [ "$PLATFORM" == "macos" ]; then
    echo "🍎 Building macOS package..."
    
    if [ -f "build-macos.sh" ]; then
        chmod +x build-macos.sh
        ./build-macos.sh
    fi
    
    echo ""
    echo "✅ macOS package built:"
    ls -lh *.dmg 2>/dev/null || echo "No DMG found"
fi

# Windows note
echo ""
echo "🪟 For Windows build:"
echo "   Run build-windows.ps1 on a Windows machine with Inno Setup installed"
echo "   powershell -File build-windows.ps1"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Build Summary:"
echo ""
echo "Platform-specific installers:"
echo "  🐧 Linux DEB:    verba_1.0.0_amd64.deb"
echo "  🐧 Linux RPM:    verba-1.0.0-1.fc*.x86_64.rpm"
echo "  🪟 Windows EXE:  Verba-Setup-1.0.0.exe (build on Windows)"
echo "  🍎 macOS DMG:    Verba-1.0.0.dmg (build on macOS)"
echo ""
echo "Upload to GitHub Releases for distribution!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
