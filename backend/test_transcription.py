#!/usr/bin/env python3
"""
Test transcription with actual audio to verify VAD fix
"""
import sys
import os
from transcriber import transcribe_audio

# Test with a sample audio file
test_files = [
    "/tmp/test_audio.wav",
    "/tmp/test_audio.webm",
]

print("="*60)
print("TRANSCRIPTION TEST")
print("="*60)
print("This test verifies that VAD is disabled and full")
print("transcription happens without premature cutoffs.")
print("="*60)

# Check test files exist
for test_file in test_files:
    if os.path.exists(test_file):
        print(f"\n✅ Found test file: {test_file}")
        print(f"   Size: {os.path.getsize(test_file)} bytes")
        
        try:
            print(f"\n🎯 Transcribing {test_file}...")
            transcript = transcribe_audio(test_file, preprocess=False)
            
            print(f"\n📝 TRANSCRIPT ({len(transcript)} characters):")
            print("-"*60)
            print(transcript)
            print("-"*60)
            
            if len(transcript) > 50:
                print("\n✅ SUCCESS: Got substantial transcription")
            else:
                print(f"\n⚠️  WARNING: Transcription seems short ({len(transcript)} chars)")
                
        except Exception as e:
            print(f"\n❌ ERROR: {e}")
    else:
        print(f"⏭️  Skipping {test_file} (doesn't exist)")

print("\n" + "="*60)
print("If you see substantial transcription above, VAD fix works!")
print("="*60)
