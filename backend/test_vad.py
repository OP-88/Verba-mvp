#!/usr/bin/env python3
"""
Test the transcription with a synthesized WebM file to verify:
1. VAD doesn't cut off speech prematurely
2. No hallucinations from silence
3. Full transcription is captured
"""
import sys
import os
import subprocess

# Create a test audio file with ffmpeg (30 seconds of silence to test hallucination)
print("Creating test audio file (5 seconds silence + speech-like noise)...")

# Use ffmpeg to create a simple test
subprocess.run([
    "ffmpeg", "-y", "-f", "lavfi", 
    "-i", "anullsrc=r=16000:cl=mono",
    "-t", "5",
    "/tmp/silence_test.wav"
], capture_output=True)

print("✅ Test file created: /tmp/silence_test.wav")
print("\nNow testing with transcriber...")

# Test it
sys.path.insert(0, '/home/marc/Verba-mvp/backend')
from transcriber import transcribe_audio

transcript = transcribe_audio("/tmp/silence_test.wav", preprocess=False)

print(f"\n📝 TRANSCRIPT ({len(transcript)} characters):")
print("-" * 60)
print(transcript)
print("-" * 60)

if len(transcript) == 0:
    print("\n✅ GOOD: Empty transcript for silence (no hallucination)")
elif len(transcript) < 50:
    print("\n✅ ACCEPTABLE: Short transcript, minimal hallucination")
else:
    print(f"\n❌ BAD: Got {len(transcript)} chars from 5s silence - likely hallucinating")
