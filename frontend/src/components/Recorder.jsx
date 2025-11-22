/**
 * Recorder component - handles audio recording and transcription
 */
import { useState, useRef } from 'react'
import { transcribeAudio } from '../api'

function Recorder({ onTranscriptComplete, onTranscribing, onError }) {
  const [isRecording, setIsRecording] = useState(false)
  const [isProcessing, setIsProcessing] = useState(false)
  const [showSourceDialog, setShowSourceDialog] = useState(false)
  const [audioDevices, setAudioDevices] = useState([])
  const [selectedSource, setSelectedSource] = useState(null) // Track selected device
  const mediaRecorderRef = useRef(null)
  const chunksRef = useRef([])

  const startRecording = async (deviceId = null) => {
    try {
      // Build constraints - use exact only for non-default devices
      let constraints
      if (deviceId && deviceId !== 'default') {
        constraints = { audio: { deviceId: { exact: deviceId } } }
      } else {
        constraints = { audio: true }
      }
      
      const stream = await navigator.mediaDevices.getUserMedia(constraints)
      
      // Use better options for MediaRecorder to ensure quality
      let options = { mimeType: 'audio/webm' }
      if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
        options.mimeType = 'audio/webm;codecs=opus'
      }
      
      const mediaRecorder = new MediaRecorder(stream, options)
      mediaRecorderRef.current = mediaRecorder
      chunksRef.current = []

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          console.log('Audio chunk received:', event.data.size, 'bytes')
          chunksRef.current.push(event.data)
        }
      }

      mediaRecorder.onstop = async () => {
        console.log('Recording stopped. Total chunks:', chunksRef.current.length)
        const audioBlob = new Blob(chunksRef.current, { type: options.mimeType })
        console.log('Final audio blob size:', audioBlob.size, 'bytes')
        
        if (audioBlob.size < 1000) {
          onError('Recording too short. Please record for at least 2-3 seconds.', 'warning')
          setIsRecording(false)
          stream.getTracks().forEach(track => track.stop())
          return
        }
        
        await handleTranscribe(audioBlob)
        
        // Stop all tracks
        stream.getTracks().forEach(track => track.stop())
      }

      // Start recording with timeslice to collect data in chunks every 100ms
      mediaRecorder.start(100)
      setIsRecording(true)
      console.log('Recording started with device:', deviceId || 'default')
    } catch (error) {
      console.error('Error starting recording:', error)
      onError('Failed to access microphone: ' + error.message)
    }
  }

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop()
      mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop())
    }
  }

  const loadAudioDevices = async () => {
    try {
      // Request permission first to get device labels
      await navigator.mediaDevices.getUserMedia({ audio: true })
        .then(stream => stream.getTracks().forEach(track => track.stop()))
      
      const devices = await navigator.mediaDevices.enumerateDevices()
      const audioInputs = devices.filter(device => device.kind === 'audioinput')
      setAudioDevices(audioInputs)
      setShowSourceDialog(true)
    } catch (err) {
      onError('Failed to load audio devices: ' + err.message)
    }
  }

  const handleDeviceSelect = async (deviceId, sourceName) => {
    setShowSourceDialog(false)
    setSelectedSource(sourceName)
    console.log('Selected audio source:', sourceName, 'Device ID:', deviceId)
    await startRecording(deviceId)
  }

  const handleTranscribe = async (audioBlob) => {
    setIsProcessing(true)
    setIsRecording(false) // Reset recording state immediately
    onTranscribing(true)

    try {
      const data = await transcribeAudio(audioBlob)
      
      if (data.warning) {
        onError(data.warning, 'info')
      }
      
      onTranscriptComplete(data.transcript)
    } catch (error) {
      onError(error.message || 'Failed to transcribe audio. Please try again.')
      onTranscribing(false)
    } finally {
      setIsProcessing(false)
    }
  }

  return (
    <>
      {/* Audio Source Selection Dialog */}
      {showSourceDialog && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-lg flex items-center justify-center z-50 animate-fade-in">
          <div className="backdrop-blur-xl bg-gradient-to-br from-purple-900/40 to-blue-900/40 rounded-3xl border-2 border-white/30 shadow-2xl p-10 max-w-lg w-full mx-4 animate-scale-in">
            <div className="text-center mb-8">
              <h3 className="text-3xl font-bold text-white mb-2">🎹️ Choose Your Audio Source</h3>
              <p className="text-gray-300 text-sm">Select where you want to record audio from</p>
            </div>
            <div className="space-y-4">
              {(() => {
                // Find the Verba system audio device
                const systemAudioDevice = audioDevices.find(d => {
                  const label = d.label?.toLowerCase() || ''
                  return (
                    (label.includes('monitor') && label.includes('verba')) ||
                    label.includes('verba_combined') ||
                    (label.includes('combined') && label.includes('audio'))
                  )
                })
                
                // Find any monitor device as fallback
                const monitorDevices = audioDevices.filter(d => {
                    const label = d.label?.toLowerCase() || ''
                    return label.includes('monitor') || label.includes('stereo mix')
                })

                // Determine which device to use for System Audio
                const systemDeviceToUse = systemAudioDevice || monitorDevices[0]
                
                // Find default microphone (exclude monitor devices)
                const micDevice = audioDevices.find(d => {
                  const label = d.label?.toLowerCase() || ''
                  return d.deviceId === 'default' && !label.includes('monitor')
                }) || audioDevices.find(d => {
                  const label = d.label?.toLowerCase() || ''
                  return !label.includes('monitor') && !label.includes('verba')
                }) || audioDevices[0]
                
                const handleSystemAudioClick = () => {
                    if (systemDeviceToUse) {
                        handleDeviceSelect(systemDeviceToUse.deviceId, 'System Audio')
                    } else {
                        // If no device found, try default but warn
                        // Or just show the setup instruction
                        onError('System audio device not found. Please run ./setup_system_audio.sh', 'warning')
                        // We can still try to record from default if they really want, or just stop here.
                        // Let's try to record from default as a fallback if they insist? 
                        // No, better to guide them to setup.
                    }
                }

                return (
                  <div className="space-y-4">
                    {!systemDeviceToUse && (
                      <p className="text-yellow-300 text-sm mb-3 text-center">
                        ℹ️ System audio not configured. Run: <code className="bg-black/30 px-2 py-1 rounded">./setup_system_audio.sh</code>
                      </p>
                    )}
                    
                    {/* System Audio Option - ALWAYS VISIBLE */}
                    <button
                      onClick={handleSystemAudioClick}
                      className="w-full px-7 py-6 rounded-2xl bg-gradient-to-br from-purple-600/30 to-blue-600/30 hover:from-purple-600/50 hover:to-blue-600/50 border-2 border-purple-400/40 hover:border-purple-300/70 transition-all duration-300 hover:scale-[1.02] hover:shadow-[0_0_30px_rgba(168,85,247,0.4)] group"
                    >
                      <div className="flex items-center space-x-5">
                        <div className="text-5xl group-hover:scale-110 transition-transform">🔊</div>
                        <div className="text-left flex-1">
                          <div className="text-white font-bold text-2xl mb-1">Computer Audio</div>
                          <div className="text-purple-200 text-base">Record videos, music, browser audio, or anything playing on your computer</div>
                          {systemDeviceToUse && <div className="text-purple-300/60 text-xs mt-1">{systemDeviceToUse.label}</div>}
                        </div>
                        <div className="opacity-0 group-hover:opacity-100 transition-all group-hover:translate-x-1">
                          <span className="text-4xl text-white">→</span>
                        </div>
                      </div>
                    </button>
                    
                    {/* Microphone Option */}
                    <button
                      onClick={() => handleDeviceSelect(micDevice?.deviceId, 'Microphone')}
                      className="w-full px-7 py-6 rounded-2xl bg-gradient-to-br from-green-600/30 to-emerald-600/30 hover:from-green-600/50 hover:to-emerald-600/50 border-2 border-green-400/40 hover:border-green-300/70 transition-all duration-300 hover:scale-[1.02] hover:shadow-[0_0_30px_rgba(34,197,94,0.4)] group"
                    >
                      <div className="flex items-center space-x-5">
                        <div className="text-5xl group-hover:scale-110 transition-transform">🎤</div>
                        <div className="text-left flex-1">
                          <div className="text-white font-bold text-2xl mb-1">Microphone</div>
                          <div className="text-green-200 text-base">Record your voice or sounds around you (meetings, lectures, conversations)</div>
                          {micDevice && <div className="text-green-300/60 text-xs mt-1">{micDevice.label}</div>}
                        </div>
                        <div className="opacity-0 group-hover:opacity-100 transition-all group-hover:translate-x-1">
                          <span className="text-4xl text-white">→</span>
                        </div>
                      </div>
                    </button>
                  </div>
                )
              })()}
            </div>
            <button
              onClick={() => setShowSourceDialog(false)}
              className="mt-6 w-full px-5 py-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/20 text-white transition-all duration-300 hover:scale-105 font-medium"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

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
              onClick={isRecording ? stopRecording : loadAudioDevices}
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
            <div className="space-y-2">
              <div className="flex items-center space-x-3 text-red-400 bg-red-500/20 px-6 py-3 rounded-full border border-red-500/30 animate-pulse">
                <div className="w-3 h-3 bg-red-500 rounded-full animate-ping"></div>
                <span className="font-semibold text-lg">Recording in progress...</span>
              </div>
              {selectedSource && (
                <div className="flex items-center justify-center space-x-2 text-sm">
                  <span className="text-gray-400">Using:</span>
                  <span className={`font-bold ${selectedSource === 'System Audio' ? 'text-purple-400' : 'text-green-400'}`}>
                    {selectedSource === 'System Audio' ? '🔊' : '🎤'} {selectedSource}
                  </span>
                </div>
              )}
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
    </>
  )
}

export default Recorder
