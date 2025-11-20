# Advanced Configuration

This guide covers advanced configuration options for Verba, including model selection and performance tuning.

---

## Whisper Model Selection

Verba uses OpenAI's Whisper for transcription. By default, it uses the **'base' model** which provides excellent accuracy while being reasonably fast.

### Available Models

| Model | Size | RAM Usage | Speed | Accuracy | Best For |
|-------|------|-----------|-------|----------|----------|
| `tiny` | 39 MB | ~1 GB | Very Fast | Good | Quick transcriptions, clear audio |
| `base` | 74 MB | ~2 GB | Fast | **Excellent** | **Default - Best balance** ⭐ |
| `small` | 244 MB | ~3 GB | Medium | Great | Multi-accent, longer recordings |
| `medium` | 769 MB | ~5 GB | Slower | Superior | Professional transcription |
| `large` | 1550 MB | ~10 GB | Slowest | Best | Maximum accuracy needed |

### Changing the Model

Set the `WHISPER_MODEL_SIZE` environment variable before starting Verba:

**Linux/macOS:**
```bash
export WHISPER_MODEL_SIZE=small
./start_verba.sh
```

**Windows (PowerShell):**
```powershell
$env:WHISPER_MODEL_SIZE="small"
python backend/app.py
```

**Permanent Configuration:**

Create a `.env` file in the project root:
```bash
WHISPER_MODEL_SIZE=small
WHISPER_DEVICE=cpu
WHISPER_COMPUTE_TYPE=int8
```

---

## Long Recording Optimization

Verba is optimized for long recordings (3-4 hours) with these features:

### Voice Activity Detection (VAD)
Automatically removes silence and non-speech segments:
- Reduces processing time
- Improves accuracy
- Handles pauses gracefully

### Chunking
Audio is processed in segments with context preservation:
- Previous segments inform next segments
- Maintains conversational flow
- Handles speaker changes

### Memory Management
- Models loaded once and cached
- Efficient memory usage
- Garbage collection optimized

---

## Accuracy Tuning

### For Multiple Accents
The default configuration handles accents well:
- `language=None` - Auto-detects language
- `beam_size=5` - Explores multiple transcription paths
- `best_of=5` - Selects best of 5 candidates
- `temperature=0` - Deterministic (no randomness)

### For Technical/Professional Content
Consider upgrading to `small` or `medium` model:
```bash
export WHISPER_MODEL_SIZE=medium
```

### For Noisy Environments
Audio preprocessing helps:
- Automatic volume normalization
- 16kHz resampling
- Mono conversion
- Noise reduction via VAD

---

## Performance Benchmarks

Based on Intel Core i5 (4 cores) / AMD Ryzen 5 equivalent:

| Model | 1 hour audio | 3 hour audio | RAM Peak |
|-------|-------------|--------------|----------|
| tiny | ~5-10 min | ~15-30 min | 1 GB |
| **base** | **~10-20 min** | **~30-60 min** | **2 GB** ⭐ |
| small | ~20-40 min | ~60-120 min | 3 GB |
| medium | ~40-80 min | ~2-4 hours | 5 GB |
| large | ~80-160 min | ~4-8 hours | 10 GB |

**Note:** GPU acceleration available but requires CUDA-compatible GPU.

---

## GPU Acceleration (Optional)

For significantly faster transcription:

### Requirements
- NVIDIA GPU with CUDA support
- CUDA Toolkit installed
- cuDNN library

### Setup
```bash
# Install CUDA version of faster-whisper
pip uninstall faster-whisper
pip install faster-whisper[cuda]

# Configure to use GPU
export WHISPER_DEVICE=cuda
export WHISPER_COMPUTE_TYPE=float16
```

**Performance gain:** 5-10x faster transcription!

---

## Audio Quality Tips

### For Best Results
1. **Use a good microphone** - Clear audio = better transcription
2. **Minimize background noise** - Close windows, turn off fans
3. **Speak clearly** - Don't rush, enunciate
4. **Use system audio for videos** - Better quality than re-recording
5. **Test short clips first** - Verify quality before long recordings

### Supported Formats
- WebM (default from browser)
- WAV (best quality)
- MP3 (widely supported)
- M4A, OGG, FLAC (all supported)

---

## Troubleshooting

### Transcription Too Slow
- Use smaller model (base → tiny)
- Enable GPU acceleration
- Close other applications
- Check CPU usage

### Accuracy Issues
- Upgrade model (base → small or medium)
- Check audio quality
- Ensure microphone permissions granted
- Test with shorter, clearer audio first

### Out of Memory Errors
- Use smaller model
- Close other applications
- Restart Verba
- Check system RAM

### Empty Transcriptions
- Check audio file isn't silent
- Verify microphone working
- Try adjusting VAD threshold
- Check console logs for errors

---

## Custom VAD Parameters

For advanced users, VAD parameters can be tuned in `backend/transcriber.py`:

```python
vad_parameters=dict(
    threshold=0.5,              # Speech detection sensitivity (0.0-1.0)
    min_speech_duration_ms=250, # Minimum speech segment length
    max_speech_duration_s=float('inf'),  # Maximum segment length
    min_silence_duration_ms=2000,  # Silence gap to split segments
    window_size_samples=1024,    # Analysis window size
    speech_pad_ms=400           # Padding around speech segments
)
```

**Adjust for:**
- Noisy environments: Increase `threshold` to 0.6-0.7
- Quiet speakers: Decrease `threshold` to 0.3-0.4
- Long pauses: Increase `min_silence_duration_ms`

---

## Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `WHISPER_MODEL_SIZE` | `base` | Model to use (tiny/base/small/medium/large) |
| `WHISPER_DEVICE` | `cpu` | Device (cpu/cuda) |
| `WHISPER_COMPUTE_TYPE` | `int8` | Precision (int8/float16/float32) |
| `ENABLE_AUDIO_PREPROCESSING` | `true` | Enable audio preprocessing |
| `DATABASE_PATH` | `verba_sessions.db` | SQLite database path |
| `ALLOW_LOCAL_NETWORK` | `true` | Allow network access |

---

## Contact & Support

- **Issues:** https://github.com/OP-88/Verba-mvp/issues
- **Discussions:** https://github.com/OP-88/Verba-mvp/discussions
- **Documentation:** See main [README.md](README.md)

---

**Happy transcribing! 🎤**
