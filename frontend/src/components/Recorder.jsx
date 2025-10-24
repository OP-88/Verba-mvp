import { useState, useRef } from 'react'

function Recorder({ onTranscriptComplete, onTranscribing, apiUrl }) {
  const [isRecording, setIsRecording] = useState(false)
  const [isProcessing, setIsProcessing] = useState(false)
  const mediaRecorderRef = useRef(null)
  const chunksRef = useRef([])

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      const mediaRecorder = new MediaRecorder(stream)
      mediaRecorderRef.current = mediaRecorder
      chunksRef.current = []

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          chunksRef.current.push(event.data)
        }
      }

      mediaRecorder.onstop = async () => {
        const audioBlob = new Blob(chunksRef.current, { type: 'audio/webm' })
        await transcribeAudio(audioBlob)
        
        // Stop all tracks
        stream.getTracks().forEach(track => track.stop())
      }

      mediaRecorder.start()
      setIsRecording(true)
    } catch (error) {
      console.error('Error starting recording:', error)
      alert('Failed to access microphone. Please check permissions.')
    }
  }

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop()
      setIsRecording(false)
    }
  }

  const transcribeAudio = async (audioBlob) => {
    setIsProcessing(true)
    onTranscribing(true)

    try {
      const formData = new FormData()
      formData.append('audio', audioBlob, 'recording.webm')

      const response = await fetch(`${apiUrl}/transcribe`, {
        method: 'POST',
        body: formData,
      })

      const data = await response.json()
      onTranscriptComplete(data.transcript)
    } catch (error) {
      console.error('Transcription failed:', error)
      alert('Failed to transcribe audio. Please try again.')
      onTranscribing(false)
    } finally {
      setIsProcessing(false)
    }
  }

  return (
    <div className="relative group">
      {/* Glassmorphism Card */}
      <div className="backdrop-blur-xl bg-white/10 rounded-3xl border border-white/20 shadow-2xl p-8 transition-all duration-300 hover:bg-white/15">
        <div className="flex flex-col items-center space-y-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-white mb-3 tracking-wide">
              🎤 Record Audio
            </h2>
            <p className="text-gray-300 text-sm">
              Click the button to start recording your meeting
            </p>
          </div>

          {/* Recording Button with Glow Effect */}
          <div className="relative">
            {isRecording && (
              <div className="absolute inset-0 bg-red-500/50 rounded-full blur-2xl animate-pulse"></div>
            )}
            {!isRecording && !isProcessing && (
              <div className="absolute inset-0 bg-gradient-to-r from-purple-500/50 via-pink-500/50 to-blue-500/50 rounded-full blur-xl animate-pulse"></div>
            )}
            
            <button
              onClick={isRecording ? stopRecording : startRecording}
              disabled={isProcessing}
              className={`
                relative w-40 h-40 rounded-full font-bold text-white text-xl
                transition-all duration-500 shadow-2xl
                ${isRecording 
                  ? 'bg-gradient-to-br from-red-500 to-pink-600 hover:from-red-600 hover:to-pink-700 scale-110' 
                  : 'bg-gradient-to-br from-purple-500 via-pink-500 to-blue-500 hover:from-purple-600 hover:via-pink-600 hover:to-blue-600'
                }
                ${isProcessing ? 'opacity-50 cursor-not-allowed scale-95' : 'hover:scale-110'}
                border-4 border-white/30
              `}
            >
              <span className="drop-shadow-lg">
                {isProcessing ? (
                  <div className="flex flex-col items-center">
                    <svg className="animate-spin h-8 w-8 mb-2" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span className="text-sm">Processing</span>
                  </div>
                ) : isRecording ? (
                  <div className="flex flex-col items-center">
                    <div className="w-8 h-8 bg-white rounded-sm mb-2 animate-pulse"></div>
                    <span>STOP</span>
                  </div>
                ) : (
                  <div className="flex flex-col items-center">
                    <div className="w-8 h-8 bg-white rounded-full mb-2"></div>
                    <span>RECORD</span>
                  </div>
                )}
              </span>
            </button>
          </div>

          {/* Status Messages */}
          {isRecording && (
            <div className="flex items-center space-x-3 text-red-400 bg-red-500/20 px-6 py-3 rounded-full border border-red-500/30 animate-pulse">
              <div className="w-3 h-3 bg-red-500 rounded-full animate-ping"></div>
              <span className="font-semibold text-lg">Recording in progress...</span>
            </div>
          )}

          {isProcessing && (
            <div className="flex items-center space-x-3 text-blue-400 bg-blue-500/20 px-6 py-3 rounded-full border border-blue-500/30">
              <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span className="font-semibold">Transcribing with Whisper AI...</span>
            </div>
          )}

          {!isRecording && !isProcessing && (
            <p className="text-gray-400 text-sm italic">
              ✨ Your audio stays private and never leaves your device
            </p>
          )}
        </div>
      </div>
    </div>
  )
}

export default Recorder
