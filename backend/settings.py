"""
Configuration settings for Verba backend
"""
import os

# Feature flags
ONLINE_FEATURES_ENABLED = os.getenv("ONLINE_FEATURES_ENABLED", "false").lower() == "true"

# Model configuration
WHISPER_MODEL_SIZE = os.getenv("WHISPER_MODEL_SIZE", "tiny")
WHISPER_DEVICE = os.getenv("WHISPER_DEVICE", "cpu")
WHISPER_COMPUTE_TYPE = os.getenv("WHISPER_COMPUTE_TYPE", "int8")

# Database
DATABASE_PATH = os.getenv("DATABASE_PATH", "verba_sessions.db")

# Audio processing
ENABLE_AUDIO_PREPROCESSING = os.getenv("ENABLE_AUDIO_PREPROCESSING", "true").lower() == "true"

# CORS
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:5173").split(",")
