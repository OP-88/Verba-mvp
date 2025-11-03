"""
Audio transcription using faster-whisper (Whisper tiny model)
Includes audio preprocessing for better transcription quality
Falls back to mock transcription if faster-whisper is not available
"""
try:
    from faster_whisper import WhisperModel
    WHISPER_AVAILABLE = True
except ImportError:
    WHISPER_AVAILABLE = False
    print("WARNING: faster-whisper not available. Using mock transcription for testing.")

try:
    from pydub import AudioSegment
    from pydub.effects import normalize
    PYDUB_AVAILABLE = True
except ImportError:
    PYDUB_AVAILABLE = False
    print("WARNING: pydub not available. Audio preprocessing disabled.")

import os
import tempfile

# Initialize model globally (loaded once)
MODEL_SIZE = "tiny"
MODEL = None


def get_model():
    """Lazy load the Whisper model"""
    global MODEL
    if not WHISPER_AVAILABLE:
        return None
    if MODEL is None:
        MODEL = WhisperModel(MODEL_SIZE, device="cpu", compute_type="int8")
    return MODEL


def preprocess_audio(audio_path: str) -> str:
    """
    Preprocess audio for better transcription:
    - Normalize volume
    - Convert to 16kHz mono WAV
    
    Args:
        audio_path: Path to original audio file
    
    Returns:
        Path to preprocessed audio file
    """
    if not PYDUB_AVAILABLE:
        return audio_path
        
    try:
        # Load audio
        audio = AudioSegment.from_file(audio_path)
        
        # Convert to mono if stereo
        if audio.channels > 1:
            audio = audio.set_channels(1)
        
        # Resample to 16kHz (optimal for Whisper)
        audio = audio.set_frame_rate(16000)
        
        # Normalize volume
        audio = normalize(audio)
        
        # Save to temporary WAV file
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
        audio.export(temp_file.name, format="wav")
        
        return temp_file.name
    except Exception as e:
        # If preprocessing fails, return original file
        print(f"Audio preprocessing failed: {e}. Using original file.")
        return audio_path


def transcribe_audio(audio_path: str, preprocess: bool = True) -> str:
    """
    Transcribe audio file to text using Whisper tiny model
    Falls back to mock transcription if Whisper is not available
    
    Args:
        audio_path: Path to audio file
        preprocess: Whether to preprocess audio before transcription
    
    Returns:
        Transcribed text as a single string
    """
    if not os.path.exists(audio_path):
        raise FileNotFoundError(f"Audio file not found: {audio_path}")
    
    # Fallback to mock transcription if Whisper not available
    if not WHISPER_AVAILABLE:
        print(f"Using mock transcription for: {audio_path}")
        return "This is a mock transcription for testing purposes. The meeting discussed project timelines and resource allocation. We need to complete the documentation by next Friday. John will be responsible for the technical specifications."
    
    processed_path = audio_path
    temp_file_created = False
    
    try:
        # Preprocess audio if enabled
        if preprocess:
            processed_path = preprocess_audio(audio_path)
            temp_file_created = (processed_path != audio_path)
        
        model = get_model()
        
        # Transcribe with faster-whisper
        segments, info = model.transcribe(processed_path, beam_size=5)
        
        # Combine all segments into a single transcript
        transcript_parts = []
        for segment in segments:
            transcript_parts.append(segment.text.strip())
        
        transcript = " ".join(transcript_parts)
        
        return transcript
    
    finally:
        # Clean up temporary preprocessed file
        if temp_file_created and os.path.exists(processed_path):
            try:
                os.unlink(processed_path)
            except:
                pass
