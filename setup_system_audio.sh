#!/bin/bash
# Setup System Audio Recording for Verba (Linux/PulseAudio)

echo "🎵 Setting up system audio recording..."
echo ""

# Check if PulseAudio is running
if ! pactl info > /dev/null 2>&1; then
    echo "❌ PulseAudio is not running. Starting..."
    pulseaudio --start
    sleep 2
fi

echo "✅ PulseAudio is running"
echo ""

# Create a virtual sink that combines mic + system audio
echo "🔧 Creating virtual audio sink..."

# Load the null sink (virtual audio output)
SINK_NAME="verba_combined"
pactl load-module module-null-sink sink_name=$SINK_NAME sink_properties=device.description="Verba_Combined_Audio" 2>/dev/null

# Get the default sink (system audio output) monitor source
DEFAULT_SINK=$(pactl get-default-sink)
SYSTEM_AUDIO_SOURCE="${DEFAULT_SINK}.monitor"

echo "   Default sink: $DEFAULT_SINK"
echo "   System audio source: $SYSTEM_AUDIO_SOURCE"
echo "   Microphone source: @DEFAULT_SOURCE@"
echo ""

# Load loopback from system audio output to virtual sink
echo "   Loading system audio loopback..."
pactl load-module module-loopback source=$SYSTEM_AUDIO_SOURCE sink=$SINK_NAME latency_msec=1 2>/dev/null

# Load loopback from microphone to virtual sink
echo "   Loading microphone loopback..."
pactl load-module module-loopback source=@DEFAULT_SOURCE@ sink=$SINK_NAME latency_msec=1 2>/dev/null

echo ""
echo "=========================================="
echo "✅ System audio recording is now enabled!"
echo "=========================================="
echo ""
echo "📋 Instructions for Chrome/Firefox:"
echo ""
echo "1. In Verba, click the RECORD button"
echo "2. When browser asks for microphone:"
echo "   - Look for 'Monitor of Verba_Combined_Audio' or 'Verba_Combined_Audio'"
echo "   - Select that device instead of your regular microphone"
echo "3. Now it will record BOTH system audio + your microphone!"
echo ""
echo "🔊 What's captured:"
echo "   ✅ Your microphone"
echo "   ✅ System sounds (videos, music, apps)"
echo "   ✅ Browser audio"
echo ""
echo "🛑 To disable later, run: ./disable_system_audio.sh"
echo ""
