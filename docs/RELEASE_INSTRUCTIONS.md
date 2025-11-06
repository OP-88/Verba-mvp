# Creating a GitHub Release

## Steps to Create v1.0.0 Release

### 1. Build the Installer

```bash
cd /home/marc/dev/Verba-mvp
./scripts/create_bundle.sh
```

This creates: `verba-1.0.0-installer.sh` (1.2MB)

### 2. Create GitHub Release

1. Go to: https://github.com/OP-88/Verba-mvp/releases/new

2. **Tag**: `v1.0.0`

3. **Title**: `Verba v1.0.0 - Initial Release`

4. **Description**: Copy from RELEASE_NOTES.md or use:

```markdown
# Verba v1.0.0 - Offline AI Meeting Assistant

## 🎉 Initial Release

**100% Private. 100% Offline. 100% Yours.**

### ✨ Features

- 🎙️ **Real-time Transcription** - OpenAI Whisper AI running locally
- 🔊 **System Audio Capture** - Record videos, music, browser audio  
- 📝 **Smart Summarization** - Extract key points, decisions, action items
- 💾 **Session History** - All meetings saved locally in SQLite
- 📱 **Multi-Device Access** - Use from phone/tablet on local network
- 🔒 **100% Private** - No cloud, no tracking, data never leaves your device
- 📤 **Markdown Export** - Download professional meeting notes

### 📦 Installation

**Linux (One-Click):**
```bash
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/verba-1.0.0-installer.sh
bash verba-1.0.0-installer.sh
verba
```

**Other Platforms:** See [Installation Guide](https://github.com/OP-88/Verba-mvp#-installation)

### 🔧 System Requirements

- Python 3.11+
- Node.js 18+
- ffmpeg
- 2GB RAM minimum

### 📚 Documentation

- [Installation Guide](https://github.com/OP-88/Verba-mvp/blob/main/INSTALL.md)
- [Windows Setup](https://github.com/OP-88/Verba-mvp/blob/main/INSTALL_WINDOWS.md)
- [Network Access](https://github.com/OP-88/Verba-mvp/blob/main/NETWORK_ACCESS.md)

### 🐛 Known Issues

None reported yet! Please file issues at: https://github.com/OP-88/Verba-mvp/issues

### ⭐ Support

If you find Verba useful, please star the repository!
```

5. **Upload Files**: 
   - Drag and drop `verba-1.0.0-installer.sh`

6. Click **"Publish release"**

### 3. Verify Download Link

After publishing, the download link will be:
```
https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/verba-1.0.0-installer.sh
```

This matches the link in README.md!

### 4. Test the Release

```bash
# Download
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/verba-1.0.0-installer.sh

# Run
bash verba-1.0.0-installer.sh

# Should install and create 'verba' command
verba
```

## Future Releases

For future versions (e.g., v1.1.0):

1. Update version in:
   - `scripts/create_bundle.sh` (VERSION variable)
   - `RELEASE_NOTES.md`
   - README.md download links

2. Create installer: `./scripts/create_bundle.sh`

3. Create GitHub release with new tag

4. Upload new installer file

## Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] RELEASE_NOTES.md updated
- [ ] Version numbers updated
- [ ] Installer created with `create_bundle.sh`
- [ ] GitHub release created
- [ ] Download link tested
- [ ] README.md download links correct
