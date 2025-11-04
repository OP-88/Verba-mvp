#!/bin/bash
# Disable System Audio Recording

echo "🛑 Disabling system audio recording..."

# Unload all loopback modules
pactl unload-module module-loopback 2>/dev/null

# Unload the virtual sink
pactl unload-module module-null-sink 2>/dev/null

echo "✅ System audio recording disabled"
echo "   (You can now use regular microphone)"
