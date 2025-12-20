#!/usr/bin/env python3
"""
Final validation - create actual speech-like audio and test
"""
import subprocess
import requests
import time
import os

API_URL = "http://localhost:8000"

print("="*70)
print("FINAL VALIDATION TEST")
print("="*70)

# Create test audio with varying characteristics
print("\n1. Creating test audio (silence + noise to simulate speech)...")

# Create a more realistic test: short burst of noise (simulates speech)
subprocess.run([
    "ffmpeg", "-y",
    "-f", "lavfi", "-i", "anoisesrc=d=5:c=white:r=16000:a=0.5",  # 5s white noise (simulates speech)
    "-f", "lavfi", "-i", "anullsrc=r=16000:d=2",  # 2s silence
    "-f", "lavfi", "-i", "anoisesrc=d=3:c=white:r=16000:a=0.5",  # 3s more noise
    "-filter_complex", "[0:a][1:a][2:a]concat=n=3:v=0:a=1",
    "/tmp/realistic_test.wav"
], capture_output=True)

print(f"   ✅ Created 10-second test audio (5s+2s+3s pattern)")

# Test via chunk upload (how frontend works)
print("\n2. Testing transcription...")
session_id = f"validation-{int(time.time())}"

try:
    # Initialize
    requests.post(f"{API_URL}/api/recording/initialize",
                 json={"session_id": session_id, "mime_type": "audio/wav"})
    
    # Upload
    with open("/tmp/realistic_test.wav", 'rb') as f:
        files = {'chunk': ('test.wav', f, 'audio/wav')}
        requests.post(f"{API_URL}/api/recording/upload-chunk/{session_id}/0", files=files)
    
    # Finalize
    response = requests.post(f"{API_URL}/api/recording/finalize/{session_id}", timeout=60)
    
    if response.status_code == 200:
        data = response.json()
        transcript = data.get('transcript', '')
        
        print(f"\n3. Results:")
        print(f"   Status: {response.status_code}")
        print(f"   Transcript length: {len(transcript)} characters")
        print(f"   Content: '{transcript[:200] if transcript else '(empty)'}...'")
        
        # Analyze result
        if len(transcript) == 0:
            print(f"\n   ⚠️  Empty - VAD might still be too aggressive")
        elif "I don't know" in transcript or "I'm not sure" in transcript:
            print(f"\n   ❌ HALLUCINATION DETECTED")
        elif len(transcript) < 50:
            print(f"\n   ✅ SHORT/EMPTY - Good (noise correctly filtered)")
        else:
            print(f"\n   ⚠️  Got {len(transcript)} chars - check for hallucinations")
            
    else:
        print(f"\n   ❌ Error: {response.status_code}")
        print(f"   {response.json()}")
        
except Exception as e:
    print(f"\n   ❌ Exception: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "="*70)
print("Test complete. Check logs with:")
print("  tail -50 /tmp/verba_final2.log | grep -A 5 'VAD'")
print("="*70)
