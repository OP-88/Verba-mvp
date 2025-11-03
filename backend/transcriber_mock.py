"""
Mock transcriber for testing - simulates Whisper without dependencies
"""
import os

def transcribe_audio(audio_path: str, preprocess: bool = True) -> str:
    """
    Mock transcription - returns a sample transcript
    
    Args:
        audio_path: Path to audio file
        preprocess: Whether to preprocess audio (ignored in mock)
    
    Returns:
        Mock transcribed text
    """
    if not os.path.exists(audio_path):
        raise FileNotFoundError(f"Audio file not found: {audio_path}")
    
    # Return a mock transcript
    return "This is a mock transcription for testing purposes. The meeting discussed project timelines and resource allocation. We need to complete the documentation by next Friday. John will be responsible for the technical specifications."
