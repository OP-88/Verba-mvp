# Verba - Quick Demo Guide for Lecture

## 🎯 What You Have Running

✅ **Verba is LIVE at**: http://localhost:5173  
✅ **System audio recording**: ENABLED  
✅ **Real Whisper AI**: READY (not mock!)

---

## 🎤 How to Record Your Lecture

### Step 1: Start Recording
1. Click the big **RECORD** button in Verba
2. Browser will ask for microphone permission

### Step 2: Select Audio Source
**IMPORTANT:** When browser asks for microphone, you'll see multiple options:

**For System Audio + Mic (recommended for lecture):**
- Select: **"Monitor of Verba_Combined_Audio"** or **"Verba_Combined_Audio"**
- This captures:
  - ✅ Your voice
  - ✅ Any videos you play
  - ✅ System sounds
  - ✅ Background audio

**For Microphone Only:**
- Select: Your default microphone
- This captures only your voice

### Step 3: Record
- Speak naturally
- Present your slides
- Play any videos/audio
- Everything is being captured!

### Step 4: Stop & Transcribe
1. Click **STOP** when done
2. Wait 5-15 seconds for transcription
3. Click **SUMMARIZE** to get AI-generated notes

### Step 5: Export
- Click **Export as Markdown** to download notes
- Share with students!

---

## 🎬 Demo Flow for Students

**Show them:**

1. **"Watch this - I'll record this entire lecture"**
   - Click RECORD
   - Teach for a few minutes
   - Click STOP

2. **"AI is transcribing right now..."**
   - Wait for transcription to appear
   - Show the accuracy

3. **"Now let's get the summary"**
   - Click SUMMARIZE
   - Show key points, decisions, action items

4. **"And I can export this for you"**
   - Click Export
   - Show the formatted Markdown

5. **"Everything stays on my laptop - no cloud"**
   - Point out "Offline Mode" badge
   - Emphasize privacy

---

## 🔧 Quick Fixes During Lecture

### If microphone doesn't work:
```bash
# In terminal, run:
./setup_system_audio.sh
```

### If you need to restart:
```bash
./stop_verba.sh
./start_verba.sh
```

### If you want just microphone (not system audio):
```bash
./disable_system_audio.sh
```

---

## 💡 Cool Things to Mention

1. **Privacy**: "Everything runs locally, no cloud"
2. **Offline**: "Works without internet after setup"
3. **Free**: "Open source, no subscription"
4. **Fast**: "Uses Whisper AI - same tech as ChatGPT's voice"
5. **Practical**: "I'll use this for all lectures this semester"

---

## 📊 Session History

- Left sidebar shows **Past Sessions**
- Click any session to reload it
- Students can see you have multiple recordings

---

## 🎓 Use Cases to Mention

- **Lectures**: Record and share notes
- **Meetings**: Automatic meeting minutes
- **Interviews**: Transcribe research interviews
- **Study Groups**: Capture discussion points
- **Office Hours**: Keep record of student questions

---

## 🚨 Emergency Backup

If something breaks during demo:

1. **Refresh the browser**: F5
2. **Restart Verba**: `./stop_verba.sh && ./start_verba.sh`
3. **Fall back to showing**: The Past Sessions (already have 2 recordings!)

---

## 📱 After Lecture

**Students will ask:**
- "Where can I get this?" → GitHub: https://github.com/OP-88/Verba-mvp
- "Does it work on Windows?" → Yes! (show TAURI_DESKTOP_APP.md)
- "Is it free?" → Yes, open source!
- "Can I use it for exams?" → Check your university policy

---

## ✨ Pro Tips

1. **Test recording first** (30 seconds) before the actual lecture
2. **Keep Verba tab open** during recording
3. **Don't close browser** while recording
4. **Save important recordings** (they persist in database)

---

## 🎉 You're Ready!

- Verba is running: ✅
- System audio enabled: ✅
- Past sessions showing: ✅
- Real transcription working: ✅

**Good luck with your lecture!** 🚀

---

*Quick access: http://localhost:5173*
