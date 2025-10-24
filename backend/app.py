"""
Verba Backend - FastAPI server for audio transcription, summarization, and session management
"""
from fastapi import FastAPI, File, UploadFile, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, PlainTextResponse
from pydantic import BaseModel
import uvicorn
import tempfile
import os
from pathlib import Path
from datetime import datetime
import logging

# Import our modules
from transcriber import transcribe_audio
from summarizer import summarize_transcript
from storage import storage
import settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Verba API", version="0.2.0", description="Offline-first meeting assistant")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Request/Response models
class SummarizeRequest(BaseModel):
    """Request body for summarization endpoint"""
    transcript: str
    save_session: bool = True


class ErrorResponse(BaseModel):
    """Standard error response"""
    error: str
    detail: str = ""


# Root endpoints
@app.get("/")
def root():
    """Health check endpoint"""
    return {
        "status": "ok",
        "message": "Verba API is running",
        "version": "0.2.0"
    }


@app.get("/api/status")
def get_status():
    """
    Get system status and configuration
    Returns information about offline/online mode, model, device
    """
    return {
        "online_features_enabled": settings.ONLINE_FEATURES_ENABLED,
        "model": settings.WHISPER_MODEL_SIZE,
        "device": settings.WHISPER_DEVICE,
        "audio_preprocessing": settings.ENABLE_AUDIO_PREPROCESSING
    }


# Transcription endpoint
@app.post("/api/transcribe")
async def transcribe(audio: UploadFile = File(...)):
    """
    Transcribe audio file using Whisper
    Accepts: audio/webm, audio/wav, audio/mp3, etc.
    Returns: JSON with transcript text
    """
    tmp_path = None
    
    try:
        # Validate file
        if not audio.filename:
            return JSONResponse(
                status_code=400,
                content={"error": "No audio file provided"}
            )
        
        # Save uploaded file temporarily
        suffix = Path(audio.filename).suffix or ".webm"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_file:
            content = await audio.read()
            
            if len(content) == 0:
                return JSONResponse(
                    status_code=400,
                    content={"error": "Audio file is empty"}
                )
            
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        logger.info(f"Transcribing audio file: {audio.filename} ({len(content)} bytes)")
        
        # Transcribe with preprocessing
        transcript = transcribe_audio(tmp_path, preprocess=settings.ENABLE_AUDIO_PREPROCESSING)
        
        if not transcript or len(transcript.strip()) == 0:
            return JSONResponse(
                status_code=200,
                content={
                    "transcript": "",
                    "warning": "No speech detected in audio",
                    "status": "success"
                }
            )
        
        logger.info(f"Transcription successful: {len(transcript)} characters")
        
        return JSONResponse({
            "transcript": transcript,
            "status": "success"
        })
    
    except FileNotFoundError as e:
        logger.error(f"File not found: {e}")
        return JSONResponse(
            status_code=500,
            content={"error": "Audio file could not be processed", "detail": str(e)}
        )
    
    except Exception as e:
        logger.error(f"Transcription error: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "error": "Transcription failed. Please try recording again.",
                "detail": str(e)
            }
        )
    
    finally:
        # Clean up temporary file
        if tmp_path and os.path.exists(tmp_path):
            try:
                os.unlink(tmp_path)
            except Exception as e:
                logger.warning(f"Could not delete temp file: {e}")


# Summarization endpoint
@app.post("/api/summarize")
async def summarize(request: SummarizeRequest):
    """
    Summarize a transcript into structured notes
    Optionally saves as a session
    """
    try:
        if not request.transcript or len(request.transcript.strip()) == 0:
            return JSONResponse(
                status_code=400,
                content={"error": "No transcript provided"}
            )
        
        logger.info(f"Summarizing transcript: {len(request.transcript)} characters")
        
        # Generate summary
        summary = summarize_transcript(request.transcript)
        
        # Save as session if requested
        session_id = None
        if request.save_session:
            try:
                session_id = storage.create_session(request.transcript, summary)
                logger.info(f"Session saved: {session_id}")
            except Exception as e:
                logger.error(f"Failed to save session: {e}")
                # Don't fail the request if storage fails
        
        response = {
            "summary": summary,
            "status": "success"
        }
        
        if session_id:
            response["session_id"] = session_id
        
        return JSONResponse(response)
    
    except Exception as e:
        logger.error(f"Summarization error: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "error": "Failed to generate summary. Please try again.",
                "detail": str(e)
            }
        )


# Session management endpoints
@app.get("/api/sessions")
def list_sessions():
    """
    Get list of all saved sessions (with preview)
    Returns most recent first
    """
    try:
        sessions = storage.list_sessions()
        return {
            "sessions": sessions,
            "count": len(sessions),
            "status": "success"
        }
    except Exception as e:
        logger.error(f"Failed to list sessions: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "error": "Failed to load session history",
                "detail": str(e)
            }
        )


@app.get("/api/sessions/{session_id}")
def get_session(session_id: str):
    """
    Get full session data by ID
    Includes complete transcript and summary
    """
    try:
        session = storage.get_session(session_id)
        
        if not session:
            return JSONResponse(
                status_code=404,
                content={"error": "Session not found"}
            )
        
        return {
            "session": session,
            "status": "success"
        }
    except Exception as e:
        logger.error(f"Failed to get session {session_id}: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "error": "Failed to load session",
                "detail": str(e)
            }
        )


@app.get("/api/sessions/{session_id}/export")
def export_session(session_id: str):
    """
    Export session as Markdown file
    Returns formatted markdown string
    """
    try:
        session = storage.get_session(session_id)
        
        if not session:
            return JSONResponse(
                status_code=404,
                content={"error": "Session not found"}
            )
        
        # Format as Markdown
        created_date = datetime.fromisoformat(session['created_at']).strftime("%B %d, %Y at %I:%M %p")
        
        markdown = f"""# Meeting Summary

**Date:** {created_date}

---

## Transcript

{session['transcript']}

---

## Summary

### 📌 Key Points

"""
        
        for i, point in enumerate(session['summary']['key_points'], 1):
            markdown += f"{i}. {point}\n"
        
        if session['summary']['decisions']:
            markdown += "\n### ✅ Decisions Made\n\n"
            for i, decision in enumerate(session['summary']['decisions'], 1):
                markdown += f"{i}. {decision}\n"
        
        if session['summary']['action_items']:
            markdown += "\n### 🎯 Action Items\n\n"
            for i, item in enumerate(session['summary']['action_items'], 1):
                markdown += f"{i}. {item}\n"
        
        markdown += "\n---\n\n*Generated by Verba - Offline-first meeting assistant*\n"
        
        return PlainTextResponse(
            content=markdown,
            media_type="text/markdown",
            headers={
                "Content-Disposition": f"attachment; filename=verba-session-{session_id[:8]}.md"
            }
        )
    
    except Exception as e:
        logger.error(f"Failed to export session {session_id}: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "error": "Failed to export session",
                "detail": str(e)
            }
        )


@app.delete("/api/sessions/{session_id}")
def delete_session(session_id: str):
    """
    Delete a session by ID
    """
    try:
        deleted = storage.delete_session(session_id)
        
        if not deleted:
            return JSONResponse(
                status_code=404,
                content={"error": "Session not found"}
            )
        
        return {
            "message": "Session deleted successfully",
            "status": "success"
        }
    except Exception as e:
        logger.error(f"Failed to delete session {session_id}: {e}")
        return JSONResponse(
            status_code=500,
            content={
                "error": "Failed to delete session",
                "detail": str(e)
            }
        )


if __name__ == "__main__":
    logger.info("Starting Verba API server...")
    logger.info(f"Online features: {'enabled' if settings.ONLINE_FEATURES_ENABLED else 'disabled'}")
    logger.info(f"Whisper model: {settings.WHISPER_MODEL_SIZE} on {settings.WHISPER_DEVICE}")
    
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
