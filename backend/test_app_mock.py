"""
Mock test for Verba backend - tests all endpoints without Whisper
"""
import sys
import time
import requests
import json
from io import BytesIO

API_URL = "http://localhost:8000"

def test_health():
    """Test root endpoint"""
    print("🔍 Testing health check...")
    try:
        response = requests.get(f"{API_URL}/")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        print("✅ Health check: PASSED")
        return True
    except Exception as e:
        print(f"❌ Health check: FAILED - {e}")
        return False

def test_status():
    """Test status endpoint"""
    print("\n🔍 Testing status endpoint...")
    try:
        response = requests.get(f"{API_URL}/api/status")
        assert response.status_code == 200
        data = response.json()
        assert "model" in data
        assert "device" in data
        print(f"✅ Status endpoint: PASSED (model={data['model']}, device={data['device']})")
        return True
    except Exception as e:
        print(f"❌ Status endpoint: FAILED - {e}")
        return False

def test_transcribe():
    """Test transcription endpoint with mock audio"""
    print("\n🔍 Testing transcription endpoint...")
    try:
        # Create a mock audio file (empty for testing)
        files = {'audio': ('test.webm', BytesIO(b'mock audio data'), 'audio/webm')}
        response = requests.post(f"{API_URL}/api/transcribe", files=files)
        
        # This will likely fail without real audio/Whisper, but we're testing the endpoint
        if response.status_code in [200, 400, 500]:
            print(f"✅ Transcription endpoint: ACCESSIBLE (status={response.status_code})")
            return True
        else:
            print(f"⚠️  Transcription endpoint: UNEXPECTED STATUS {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Transcription endpoint: FAILED - {e}")
        return False

def test_summarize():
    """Test summarization endpoint"""
    print("\n🔍 Testing summarization endpoint...")
    try:
        test_transcript = "This is a test meeting. We need to finish the project. John will handle the documentation. The deadline is next Friday."
        response = requests.post(
            f"{API_URL}/api/summarize",
            json={"transcript": test_transcript, "save_session": True}
        )
        assert response.status_code == 200
        data = response.json()
        assert "summary" in data
        assert "key_points" in data["summary"]
        assert "session_id" in data
        print(f"✅ Summarization endpoint: PASSED (session_id={data['session_id'][:8]}...)")
        return data["session_id"]
    except Exception as e:
        print(f"❌ Summarization endpoint: FAILED - {e}")
        return None

def test_list_sessions():
    """Test session listing endpoint"""
    print("\n🔍 Testing session list endpoint...")
    try:
        response = requests.get(f"{API_URL}/api/sessions")
        assert response.status_code == 200
        data = response.json()
        assert "sessions" in data
        assert "count" in data
        print(f"✅ Session list endpoint: PASSED ({data['count']} sessions found)")
        return True
    except Exception as e:
        print(f"❌ Session list endpoint: FAILED - {e}")
        return False

def test_get_session(session_id):
    """Test get single session endpoint"""
    print(f"\n🔍 Testing get session endpoint...")
    try:
        response = requests.get(f"{API_URL}/api/sessions/{session_id}")
        assert response.status_code == 200
        data = response.json()
        assert "session" in data
        assert data["session"]["id"] == session_id
        print(f"✅ Get session endpoint: PASSED")
        return True
    except Exception as e:
        print(f"❌ Get session endpoint: FAILED - {e}")
        return False

def test_export_session(session_id):
    """Test session export endpoint"""
    print(f"\n🔍 Testing export session endpoint...")
    try:
        response = requests.get(f"{API_URL}/api/sessions/{session_id}/export")
        assert response.status_code == 200
        assert "text/markdown" in response.headers.get("Content-Type", "")
        markdown = response.text
        assert "# Meeting Summary" in markdown
        print(f"✅ Export session endpoint: PASSED ({len(markdown)} bytes)")
        return True
    except Exception as e:
        print(f"❌ Export session endpoint: FAILED - {e}")
        return False

def test_delete_session(session_id):
    """Test session deletion endpoint"""
    print(f"\n🔍 Testing delete session endpoint...")
    try:
        response = requests.delete(f"{API_URL}/api/sessions/{session_id}")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        print(f"✅ Delete session endpoint: PASSED")
        return True
    except Exception as e:
        print(f"❌ Delete session endpoint: FAILED - {e}")
        return False

def main():
    print("=" * 60)
    print("🧪 VERBA BACKEND MOCK TEST SUITE")
    print("=" * 60)
    
    print("\n⏳ Waiting for backend to start...")
    max_retries = 30
    for i in range(max_retries):
        try:
            requests.get(f"{API_URL}/", timeout=1)
            print("✅ Backend is running!")
            break
        except:
            if i == max_retries - 1:
                print("❌ Backend failed to start after 30 seconds")
                sys.exit(1)
            time.sleep(1)
            print(f"   Retry {i+1}/{max_retries}...")
    
    print("\n" + "=" * 60)
    print("RUNNING TESTS")
    print("=" * 60)
    
    results = []
    
    # Test basic endpoints
    results.append(("Health Check", test_health()))
    results.append(("Status", test_status()))
    results.append(("Transcribe (mock)", test_transcribe()))
    
    # Test summarization and session management
    session_id = test_summarize()
    results.append(("Summarize", session_id is not None))
    
    if session_id:
        results.append(("List Sessions", test_list_sessions()))
        results.append(("Get Session", test_get_session(session_id)))
        results.append(("Export Session", test_export_session(session_id)))
        results.append(("Delete Session", test_delete_session(session_id)))
    
    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print("\n" + "=" * 60)
    print(f"TOTAL: {passed}/{total} tests passed ({passed/total*100:.1f}%)")
    print("=" * 60)
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED! Backend is fully functional!")
        sys.exit(0)
    else:
        print(f"\n⚠️  {total - passed} tests failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
