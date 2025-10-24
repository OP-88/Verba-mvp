"""
Verba MVP Backend - FastAPI server for audio transcription and summarization
"""
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import tempfile
import os
from pathlib import Path

from transcriber import transcribe_audio
from summarizer import summarize_transcript

app = FastAPI(title="Verba MVP API", version="1.0.0")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    """Health check endpoint"""
    return {"status": "ok", "message": "Verba MVP API is running"}


@app.post("/transcribe")
async def transcribe(audio: UploadFile = File(...)):
    """
    Transcribe audio file using Whisper
    Accepts: audio/webm, audio/wav, audio/mp3, etc.
    Returns: JSON with transcript text
    """
    try:
        # Save uploaded file temporarily
        suffix = Path(audio.filename).suffix or ".webm"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_file:
            content = await audio.read()
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        # Transcribe
        transcript = transcribe_audio(tmp_path)
        
        # Clean up
        os.unlink(tmp_path)
        
        return JSONResponse({
            "transcript": transcript,
            "status": "success"
        })
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")


@app.post("/summarize")
async def summarize(data: dict):
    """
    Summarize a transcript into structured notes
    Expects: {"transcript": "..."}
    Returns: JSON with summary sections
    """
    try:
        transcript = data.get("transcript", "")
        if not transcript:
            raise HTTPException(status_code=400, detail="No transcript provided")
        
        summary = summarize_transcript(transcript)
        
        return JSONResponse({
            "summary": summary,
            "status": "success"
        })
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Summarization failed: {str(e)}")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
