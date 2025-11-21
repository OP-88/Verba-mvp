/**
 * Header component - displays app title and system status
 */
import { useEffect, useState } from 'react'
import { getStatus } from '../api'

function Header() {
  const [status, setStatus] = useState(null)
  const [backendDown, setBackendDown] = useState(false)

  useEffect(() => {
    let attempts = 0
    const maxAttempts = 20 // ~10s total with 500ms delay

    const ping = () => {
      attempts += 1
      getStatus()
        .then(data => {
          setStatus(data)
          setBackendDown(false)
        })
        .catch(() => {
          // Don't show failure immediately; retry a few times in case backend is still starting
          if (attempts < maxAttempts) {
            setTimeout(ping, 500)
          } else {
            setStatus({ online_features_enabled: false, model: 'tiny', device: 'cpu' })
            setBackendDown(true)
          }
        })
    }

    ping()
  }, [])

  const isOnline = status?.online_features_enabled

  // Show warning banner if backend is down
  if (backendDown) {
    return (
      <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-slate-900/80 border-b border-white/10">
        <div className="bg-red-500/20 border-b border-red-500/30 px-6 py-3">
          <div className="flex items-center gap-3 text-red-300">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="text-sm font-semibold">
              Backend server is unavailable. Please check your API configuration.
            </span>
          </div>
        </div>
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <h1 className="text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-400 to-blue-400">
                Verba
              </h1>
              <span className="text-gray-400 text-sm hidden sm:inline">
                Offline-first meeting assistant
              </span>
            </div>
          </div>
        </div>
      </header>
    )
  }

  return (
    <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-slate-900/80 border-b border-white/10">
      <div className="container mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <div className="flex items-center gap-4">
            <h1 className="text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-400 to-blue-400">
              Verba
            </h1>
            <span className="text-gray-400 text-sm hidden sm:inline">
              Offline-first meeting assistant
            </span>
          </div>

          {/* Status Badge */}
          {status && (
            <div className="flex items-center gap-3">
              <div className={`
                px-4 py-2 rounded-full text-sm font-semibold
                border backdrop-blur-sm transition-all
                ${isOnline 
                  ? 'bg-green-500/20 text-green-300 border-green-500/30' 
                  : 'bg-purple-500/20 text-purple-300 border-purple-500/30'
                }
              `}>
                <div className="flex items-center gap-2">
                  <div className={`w-2 h-2 rounded-full ${isOnline ? 'bg-green-400' : 'bg-purple-400'} animate-pulse`}></div>
                  <span>{isOnline ? 'Enhanced Mode' : 'Offline Mode'}</span>
                </div>
              </div>

              {/* Model info (hidden on mobile) */}
              <div className="hidden md:flex items-center gap-2 text-gray-400 text-xs">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
                </svg>
                <span>{status.model} / {status.device}</span>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  )
}

export default Header
