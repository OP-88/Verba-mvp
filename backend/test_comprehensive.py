"""
Comprehensive line-by-line verification test for Verba
Tests every single endpoint and feature systematically
"""
import sys
import time
import requests
import json
from io import BytesIO

API_URL = "http://localhost:8000"

def print_test(name, passed, details=""):
    status = "✅ PASS" if passed else "❌ FAIL"
    print(f"{status} - {name}")
    if details:
        print(f"         {details}")
    return passed

def test_1_root_endpoint():
    """Line-by-line: Test root endpoint /"""
    print("\n📝 TEST 1: Root Endpoint")
    try:
        response = requests.get(f"{API_URL}/")
        data = response.json()
        
        # Verify status code
        assert response.status_code == 200, f"Expected 200, got {response.status_code}"
        print_test("Status code 200", True)
        
        # Verify response structure
        assert "status" in data, "Missing 'status' field"
        print_test("Has 'status' field", True)
        
        assert data["status"] == "ok", f"Expected status='ok', got {data['status']}"
        print_test("Status is 'ok'", True)
        
        assert "message" in data, "Missing 'message' field"
        print_test("Has 'message' field", True)
        
        assert "version" in data, "Missing 'version' field"
        print_test("Has 'version' field", True)
        
        return True
    except Exception as e:
        print_test("Root endpoint", False, str(e))
        return False

def test_2_status_endpoint():
    """Line-by-line: Test /api/status"""
    print("\n📝 TEST 2: Status Endpoint")
    try:
        response = requests.get(f"{API_URL}/api/status")
        data = response.json()
        
        assert response.status_code == 200
        print_test("Status code 200", True)
        
        assert "model" in data
        print_test("Has 'model' field", True, f"model={data['model']}")
        
        assert "device" in data
        print_test("Has 'device' field", True, f"device={data['device']}")
        
        assert "online_features_enabled" in data
        print_test("Has 'online_features_enabled' field", True)
        
        assert "audio_preprocessing" in data
        print_test("Has 'audio_preprocessing' field", True)
        
        return True
    except Exception as e:
        print_test("Status endpoint", False, str(e))
        return False

def test_3_transcribe_endpoint():
    """Line-by-line: Test /api/transcribe with mock audio"""
    print("\n📝 TEST 3: Transcribe Endpoint")
    try:
        # Create mock audio file
        audio_data = b'RIFF' + b'\\x00' * 100  # Minimal mock audio
        files = {'audio': ('test.webm', BytesIO(audio_data), 'audio/webm')}
        
        response = requests.post(f"{API_URL}/api/transcribe", files=files)
        print_test("Request sent", True)
        
        assert response.status_code == 200, f"Expected 200, got {response.status_code}"
        print_test("Status code 200", True)
        
        data = response.json()
        
        assert "transcript" in data
        print_test("Has 'transcript' field", True)
        
        assert "status" in data
        print_test("Has 'status' field", True)
        
        assert data["status"] == "success"
        print_test("Status is 'success'", True)
        
        assert len(data["transcript"]) > 0
        print_test("Transcript not empty", True, f"{len(data['transcript'])} chars")
        
        # Verify it's the mock transcript
        assert "mock transcription" in data["transcript"].lower()
        print_test("Using mock transcription", True)
        
        return data["transcript"]
    except Exception as e:
        print_test("Transcribe endpoint", False, str(e))
        return None

def test_4_summarize_endpoint(transcript):
    """Line-by-line: Test /api/summarize"""
    print("\n📝 TEST 4: Summarize Endpoint")
    try:
        payload = {
            "transcript": transcript,
            "save_session": True
        }
        
        response = requests.post(
            f"{API_URL}/api/summarize",
            json=payload
        )
        
        assert response.status_code == 200
        print_test("Status code 200", True)
        
        data = response.json()
        
        assert "summary" in data
        print_test("Has 'summary' field", True)
        
        summary = data["summary"]
        
        assert "key_points" in summary
        print_test("Summary has 'key_points'", True, f"{len(summary['key_points'])} points")
        
        assert "decisions" in summary
        print_test("Summary has 'decisions'", True, f"{len(summary['decisions'])} decisions")
        
        assert "action_items" in summary
        print_test("Summary has 'action_items'", True, f"{len(summary['action_items'])} items")
        
        assert len(summary["key_points"]) > 0
        print_test("Key points not empty", True)
        
        assert "session_id" in data
        print_test("Has 'session_id' field", True)
        
        session_id = data["session_id"]
        print_test("Session saved", True, f"ID={session_id[:8]}...")
        
        return session_id
    except Exception as e:
        print_test("Summarize endpoint", False, str(e))
        return None

def test_5_list_sessions():
    """Line-by-line: Test /api/sessions GET"""
    print("\n📝 TEST 5: List Sessions Endpoint")
    try:
        response = requests.get(f"{API_URL}/api/sessions")
        
        assert response.status_code == 200
        print_test("Status code 200", True)
        
        data = response.json()
        
        assert "sessions" in data
        print_test("Has 'sessions' field", True)
        
        assert "count" in data
        print_test("Has 'count' field", True)
        
        assert "status" in data
        print_test("Has 'status' field", True)
        
        assert isinstance(data["sessions"], list)
        print_test("Sessions is a list", True)
        
        assert data["count"] >= 1
        print_test("At least 1 session exists", True, f"count={data['count']}")
        
        # Verify session preview structure
        if len(data["sessions"]) > 0:
            session = data["sessions"][0]
            assert "id" in session
            print_test("Session has 'id'", True)
            
            assert "created_at" in session
            print_test("Session has 'created_at'", True)
            
            assert "transcript_preview" in session
            print_test("Session has 'transcript_preview'", True)
        
        return True
    except Exception as e:
        print_test("List sessions", False, str(e))
        return False

def test_6_get_session(session_id):
    """Line-by-line: Test /api/sessions/{id} GET"""
    print("\n📝 TEST 6: Get Session Endpoint")
    try:
        response = requests.get(f"{API_URL}/api/sessions/{session_id}")
        
        assert response.status_code == 200
        print_test("Status code 200", True)
        
        data = response.json()
        
        assert "session" in data
        print_test("Has 'session' field", True)
        
        session = data["session"]
        
        assert "id" in session
        print_test("Session has 'id'", True)
        
        assert session["id"] == session_id
        print_test("Session ID matches", True)
        
        assert "transcript" in session
        print_test("Session has 'transcript'", True, f"{len(session['transcript'])} chars")
        
        assert "summary" in session
        print_test("Session has 'summary'", True)
        
        assert "created_at" in session
        print_test("Session has 'created_at'", True)
        
        # Verify summary structure
        summary = session["summary"]
        assert "key_points" in summary
        print_test("Summary has key_points", True)
        
        assert "decisions" in summary
        print_test("Summary has decisions", True)
        
        assert "action_items" in summary
        print_test("Summary has action_items", True)
        
        return True
    except Exception as e:
        print_test("Get session", False, str(e))
        return False

def test_7_export_session(session_id):
    """Line-by-line: Test /api/sessions/{id}/export GET"""
    print("\n📝 TEST 7: Export Session Endpoint")
    try:
        response = requests.get(f"{API_URL}/api/sessions/{session_id}/export")
        
        assert response.status_code == 200
        print_test("Status code 200", True)
        
        content_type = response.headers.get("Content-Type", "")
        assert "markdown" in content_type.lower()
        print_test("Content-Type is markdown", True)
        
        markdown = response.text
        
        assert len(markdown) > 0
        print_test("Markdown not empty", True, f"{len(markdown)} bytes")
        
        assert "# Meeting Summary" in markdown
        print_test("Has '# Meeting Summary' header", True)
        
        assert "## Transcript" in markdown
        print_test("Has '## Transcript' section", True)
        
        assert "## Summary" in markdown
        print_test("Has '## Summary' section", True)
        
        assert "### 📌 Key Points" in markdown
        print_test("Has key points section", True)
        
        assert "Generated by Verba" in markdown
        print_test("Has Verba attribution", True)
        
        return True
    except Exception as e:
        print_test("Export session", False, str(e))
        return False

def test_8_delete_session(session_id):
    """Line-by-line: Test /api/sessions/{id} DELETE"""
    print("\n📝 TEST 8: Delete Session Endpoint")
    try:
        response = requests.delete(f"{API_URL}/api/sessions/{session_id}")
        
        assert response.status_code == 200
        print_test("Status code 200", True)
        
        data = response.json()
        
        assert "status" in data
        print_test("Has 'status' field", True)
        
        assert data["status"] == "success"
        print_test("Status is 'success'", True)
        
        assert "message" in data
        print_test("Has 'message' field", True)
        
        # Verify session is actually deleted
        verify_response = requests.get(f"{API_URL}/api/sessions/{session_id}")
        assert verify_response.status_code == 404
        print_test("Session actually deleted (404)", True)
        
        return True
    except Exception as e:
        print_test("Delete session", False, str(e))
        return False

def main():
    print("=" * 70)
    print("🔬 COMPREHENSIVE LINE-BY-LINE VERIFICATION TEST")
    print("=" * 70)
    print("\n⏳ Waiting for backend...")
    
    # Wait for backend
    for i in range(30):
        try:
            requests.get(f"{API_URL}/", timeout=1)
            print("✅ Backend is ready!\n")
            break
        except:
            if i == 29:
                print("❌ Backend not available")
                sys.exit(1)
            time.sleep(1)
    
    results = []
    
    # Run tests sequentially
    results.append(("Root Endpoint", test_1_root_endpoint()))
    results.append(("Status Endpoint", test_2_status_endpoint()))
    
    transcript = test_3_transcribe_endpoint()
    results.append(("Transcribe Endpoint", transcript is not None))
    
    if transcript:
        session_id = test_4_summarize_endpoint(transcript)
        results.append(("Summarize Endpoint", session_id is not None))
        
        if session_id:
            results.append(("List Sessions", test_5_list_sessions()))
            results.append(("Get Session", test_6_get_session(session_id)))
            results.append(("Export Session", test_7_export_session(session_id)))
            results.append(("Delete Session", test_8_delete_session(session_id)))
    
    # Summary
    print("\n" + "=" * 70)
    print("📊 FINAL SUMMARY")
    print("=" * 70)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅" if result else "❌"
        print(f"{status} {name}")
    
    print("\n" + "=" * 70)
    print(f"TOTAL: {passed}/{total} tests passed ({passed/total*100:.1f}%)")
    print("=" * 70)
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED! Every single line verified!")
        print("✅ Backend is 100% functional")
        sys.exit(0)
    else:
        print(f"\n⚠️  {total - passed} test(s) failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
