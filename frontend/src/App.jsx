import { useState } from 'react'
import Recorder from './components/Recorder'
import TranscriptBox from './components/TranscriptBox'
import SummaryBox from './components/SummaryBox'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

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
      const response = await fetch(`${API_URL}/summarize`, {
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
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 relative overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-1/2 -left-1/2 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute top-1/2 -right-1/2 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl animate-pulse delay-700"></div>
        <div className="absolute -bottom-1/2 left-1/3 w-96 h-96 bg-pink-500/20 rounded-full blur-3xl animate-pulse delay-1000"></div>
      </div>

      {/* Content */}
      <div className="relative z-10 container mx-auto px-4 py-12 max-w-5xl">
        {/* Header */}
        <header className="text-center mb-16 animate-fade-in">
          <div className="inline-block mb-4">
            <div className="relative">
              <h1 className="text-7xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-400 to-blue-400 mb-4 tracking-tight">
                Verba
              </h1>
              <div className="absolute -inset-1 bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 rounded-lg blur opacity-25 animate-pulse"></div>
            </div>
          </div>
          <p className="text-gray-300 text-xl font-light mb-2">
            <span className="text-purple-400 font-semibold">Private.</span>{' '}
            <span className="text-pink-400 font-semibold">Offline-first.</span>{' '}
            <span className="text-blue-400 font-semibold">Yours.</span>
          </p>
          <p className="text-gray-400 text-sm">
            ✨ Built for classrooms, meetings, and lectures ✨
          </p>
        </header>

        {/* Main Content */}
        <div className="space-y-8">
          {/* Recorder */}
          <div className="transform transition-all duration-500 hover:scale-[1.02]">
            <Recorder
              onTranscriptComplete={handleTranscriptComplete}
              onTranscribing={setIsTranscribing}
              apiUrl={API_URL}
            />
          </div>

          {/* Transcript */}
          {transcript && (
            <div className="transform transition-all duration-500 animate-slide-up">
              <TranscriptBox
                transcript={transcript}
                onSummarize={handleSummarize}
                onReset={handleReset}
                isSummarizing={isSummarizing}
                isTranscribing={isTranscribing}
              />
            </div>
          )}

          {/* Summary */}
          {summary && (
            <div className="transform transition-all duration-500 animate-slide-up">
              <SummaryBox summary={summary} />
            </div>
          )}
        </div>

        {/* Footer */}
        <footer className="text-center mt-16 space-y-4">
          <div className="inline-flex items-center space-x-2 text-gray-400 text-sm">
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
            </svg>
            <span>No cloud • No tracking • Everything runs locally</span>
          </div>
          <p className="text-gray-500 text-xs">Built with ❤️ for privacy and local-first software</p>
        </footer>
      </div>
    </div>
  )
}

export default App
