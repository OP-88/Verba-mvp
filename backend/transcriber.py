"""
Audio transcription using faster-whisper (Whisper tiny model)
"""
from faster_whisper import WhisperModel
import os

# Initialize model globally (loaded once)
MODEL_SIZE = "tiny"
MODEL = None


def get_model():
    """Lazy load the Whisper model"""
    global MODEL
    if MODEL is None:
        MODEL = WhisperModel(MODEL_SIZE, device="cpu", compute_type="int8")
    return MODEL


def transcribe_audio(audio_path: str) -> str:
    """
    Transcribe audio file to text using Whisper tiny model
    
    Args:
        audio_path: Path to audio file
    
    Returns:
        Transcribed text as a single string
    """
    if not os.path.exists(audio_path):
        raise FileNotFoundError(f"Audio file not found: {audio_path}")
    
    model = get_model()
    
    # Transcribe with faster-whisper
    segments, info = model.transcribe(audio_path, beam_size=5)
    
    # Combine all segments into a single transcript
    transcript_parts = []
    for segment in segments:
        transcript_parts.append(segment.text.strip())
    
    transcript = " ".join(transcript_parts)
    
    return transcript
