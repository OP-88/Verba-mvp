# Verba MVP - Frontend

React + Vite frontend for the Verba meeting assistant.

## Features

- **Audio recording**: Browser-based microphone recording using MediaRecorder API
- **Real-time UI**: Visual feedback for recording, transcription, and summarization
- **Clean design**: Built with TailwindCSS for modern, responsive UI
- **Offline-first**: All communication with local backend, no external services

## Requirements

- Node.js 18+ (or compatible)
- npm or yarn

## Installation

```bash
# Install dependencies
npm install
```

## Running

```bash
# Development server (with hot reload)
npm run dev
```

The frontend will be available at `http://localhost:5173`

## Building

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
frontend/
├── index.html              # HTML entry point
├── vite.config.js          # Vite configuration
├── tailwind.config.js      # TailwindCSS configuration
├── postcss.config.js       # PostCSS configuration
├── package.json            # Dependencies
└── src/
    ├── main.jsx            # React entry point
    ├── App.jsx             # Main app component
    ├── index.css           # Global styles + Tailwind imports
    └── components/
        ├── Recorder.jsx        # Audio recording component
        ├── TranscriptBox.jsx   # Transcript display
        └── SummaryBox.jsx      # Summary display
```

## How It Works

1. **Recorder.jsx**: 
   - Uses browser's `getUserMedia()` to access microphone
   - Records audio in WebM format
   - Sends audio to backend `/transcribe` endpoint
   - Displays transcript when complete

2. **TranscriptBox.jsx**:
   - Shows the transcribed text
   - Provides "Summarize" button to generate notes
   - Shows word/character count

3. **SummaryBox.jsx**:
   - Displays structured meeting notes
   - Shows key points, decisions, and action items
   - Clean, scannable format

## API Integration

Frontend communicates with backend at `http://localhost:8000`:

- `POST /transcribe`: Upload audio file for transcription
- `POST /summarize`: Send transcript to get structured summary

## Browser Requirements

- Modern browser with MediaRecorder API support (Chrome, Firefox, Edge, Safari 14.1+)
- Microphone permissions must be granted
