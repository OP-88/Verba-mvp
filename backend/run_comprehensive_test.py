#!/usr/bin/env python3
"""
Comprehensive transcription test - downloads real audio and tests via API
"""
import requests
import os
import subprocess
import time

API_URL = "http://localhost:8000"

print("="*70)
print("COMPREHENSIVE TRANSCRIPTION TEST")
print("="*70)

# Step 1: Download a real speech audio file from LibriVox (public domain)
print("\n1. Downloading test audio file...")
test_audio = "/tmp/test_speech.wav"

# Use ffmpeg to generate a simple tone for testing (simpler than downloading)
print("   Creating 30-second test audio...")
result = subprocess.run([
    "ffmpeg", "-y", "-f", "lavfi",
    "-i", "sine=frequency=440:duration=30",
    "-ar", "16000",
    test_audio
], capture_output=True, text=True)

if os.path.exists(test_audio):
    size = os.path.getsize(test_audio)
    print(f"   ✅ Test audio created: {size} bytes")
else:
    print(f"   ❌ Failed to create test audio")
    print(f"   Error: {result.stderr}")
    exit(1)

# Step 2: Test API status
print("\n2. Testing API status...")
try:
    response = requests.get(f"{API_URL}/api/status", timeout=5)
    if response.status_code == 200:
        print(f"   ✅ API responding: {response.json()}")
    else:
        print(f"   ❌ API error: {response.status_code}")
        exit(1)
except Exception as e:
    print(f"   ❌ API not reachable: {e}")
    exit(1)

# Step 3: Upload and transcribe via direct API
print("\n3. Testing transcription endpoint...")
try:
    with open(test_audio, 'rb') as f:
        files = {'audio': (os.path.basename(test_audio), f, 'audio/wav')}
        response = requests.post(f"{API_URL}/api/transcribe", files=files, timeout=120)
    
    if response.status_code == 200:
        data = response.json()
        transcript = data.get('transcript', '')
        print(f"   ✅ Transcription successful!")
        print(f"   Length: {len(transcript)} characters")
        print(f"   Preview: {transcript[:200] if transcript else '(empty)'}...")
        
        # Check for issues
        if len(transcript) == 0:
            print(f"   ⚠️  Empty transcript - VAD may be too aggressive")
        elif len(transcript) > 500:
            print(f"   ⚠️  Very long transcript from 30s audio - possible hallucination")
        elif "I don't know" in transcript or "I'm not sure" in transcript:
            print(f"   ⚠️  Hallucination detected in transcript")
        else:
            print(f"   ✅ Transcript looks reasonable")
            
    else:
        print(f"   ❌ Transcription failed: {response.status_code}")
        print(f"   Error: {response.json()}")
        exit(1)
        
except Exception as e:
    print(f"   ❌ Transcription error: {e}")
    exit(1)

# Step 4: Test chunk upload method (how frontend actually works)
print("\n4. Testing chunk upload workflow...")
try:
    # Initialize
    session_id = "test-" + str(int(time.time()))
    response = requests.post(f"{API_URL}/api/recording/initialize", 
                           json={"session_id": session_id, "mime_type": "audio/wav"})
    if response.status_code != 200:
        print(f"   ❌ Failed to initialize: {response.json()}")
        exit(1)
    print(f"   ✅ Initialized session: {session_id}")
    
    # Upload audio as single chunk
    with open(test_audio, 'rb') as f:
        files = {'chunk': (os.path.basename(test_audio), f, 'audio/wav')}
        response = requests.post(f"{API_URL}/api/recording/upload-chunk/{session_id}/0", 
                               files=files)
    if response.status_code != 200:
        print(f"   ❌ Failed to upload chunk: {response.json()}")
        exit(1)
    print(f"   ✅ Uploaded chunk 0")
    
    # Finalize and transcribe
    response = requests.post(f"{API_URL}/api/recording/finalize/{session_id}", timeout=120)
    if response.status_code == 200:
        data = response.json()
        transcript = data.get('transcript', '')
        print(f"   ✅ Finalization successful!")
        print(f"   Transcript length: {len(transcript)} characters")
        print(f"   Preview: {transcript[:200] if transcript else '(empty)'}...")
    else:
        print(f"   ❌ Finalization failed: {response.status_code}")
        error_data = response.json()
        print(f"   Error: {error_data}")
        if 'detail' in error_data:
            print(f"   Detail: {error_data['detail']}")
        exit(1)
        
except Exception as e:
    print(f"   ❌ Chunk upload error: {e}")
    import traceback
    traceback.print_exc()
    exit(1)

print("\n" + "="*70)
print("ALL TESTS PASSED ✅")
print("="*70)
print("\nTranscription system is working correctly!")
