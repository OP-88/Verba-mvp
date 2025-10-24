import { useState } from 'react'
import Recorder from './components/Recorder'
import TranscriptBox from './components/TranscriptBox'
import SummaryBox from './components/SummaryBox'

function App() {
  const [transcript, setTranscript] = useState('')
  const [summary, setSummary] = useState(null)
  const [isTranscribing, setIsTranscribing] = useState(false)
  const [isSummarizing, setIsSummarizing] = useState(false)

  const handleTranscriptComplete = (text) => {
    setTranscript(text)
    setIsTranscribing(false)
  }

  const handleSummarize = async () => {
    if (!transcript) return

    setIsSummarizing(true)
    try {
      const response = await fetch('http://localhost:8000/summarize', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ transcript }),
      })

      const data = await response.json()
      setSummary(data.summary)
    } catch (error) {
      console.error('Summarization failed:', error)
      alert('Failed to generate summary. Please try again.')
    } finally {
      setIsSummarizing(false)
    }
  }

  const handleReset = () => {
    setTranscript('')
    setSummary(null)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        {/* Header */}
        <header className="text-center mb-8">
          <h1 className="text-5xl font-bold text-indigo-900 mb-2">Verba</h1>
          <p className="text-gray-600 text-lg">
            Offline-first meeting assistant. Private. Fast. Yours.
          </p>
          <p className="text-gray-500 text-sm mt-1">
            Built for classrooms, meetings, and lectures
          </p>
        </header>

        {/* Main Content */}
        <div className="space-y-6">
          {/* Recorder */}
          <Recorder
            onTranscriptComplete={handleTranscriptComplete}
            onTranscribing={setIsTranscribing}
          />

          {/* Transcript */}
          {transcript && (
            <TranscriptBox
              transcript={transcript}
              onSummarize={handleSummarize}
              onReset={handleReset}
              isSummarizing={isSummarizing}
              isTranscribing={isTranscribing}
            />
          )}

          {/* Summary */}
          {summary && <SummaryBox summary={summary} />}
        </div>

        {/* Footer */}
        <footer className="text-center mt-12 text-gray-500 text-sm">
          <p>No cloud. No tracking. Everything runs locally.</p>
        </footer>
      </div>
    </div>
  )
}

export default App
