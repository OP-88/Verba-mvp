/**
 * SessionHistory component - displays list of past sessions in a collapsible sidebar
 */
import { useState, useEffect } from 'react'
import { listSessions, getSession } from '../api'

function SessionHistory({ onSessionSelect, isOpen, onToggle }) {
  const [sessions, setSessions] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    loadSessions()
  }, [])

  const loadSessions = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await listSessions()
      setSessions(data.sessions || [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSessionClick = async (sessionId) => {
    try {
      const data = await getSession(sessionId)
      onSessionSelect(data.session)
    } catch (err) {
      setError(err.message)
    }
  }

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now - date
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMs / 3600000)
    const diffDays = Math.floor(diffMs / 86400000)

    if (diffMins < 60) {
      return `${diffMins}m ago`
    } else if (diffHours < 24) {
      return `${diffHours}h ago`
    } else if (diffDays < 7) {
      return `${diffDays}d ago`
    } else {
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    }
  }

  return (
    <>
      {/* Mobile toggle button */}
      <button
        onClick={onToggle}
        className="fixed top-20 left-4 z-40 md:hidden p-3 bg-purple-500/20 backdrop-blur-sm rounded-xl border border-purple-500/30 text-purple-300"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      {/* Sidebar */}
      <div className={`
        fixed top-20 left-0 h-[calc(100vh-5rem)] w-80 z-30
        backdrop-blur-xl bg-slate-900/90 border-r border-white/10
        transform transition-transform duration-300
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        md:translate-x-0
        overflow-y-auto
      `}>
        <div className="p-6">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-white flex items-center gap-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Past Sessions
            </h2>
            <button
              onClick={loadSessions}
              className="p-2 hover:bg-white/10 rounded-lg transition-colors"
              title="Refresh"
            >
              <svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </button>
          </div>

          {/* Loading state */}
          {loading && (
            <div className="text-center py-8">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-purple-500 border-t-transparent"></div>
              <p className="text-gray-400 text-sm mt-2">Loading sessions...</p>
            </div>
          )}

          {/* Error state */}
          {error && (
            <div className="bg-red-500/20 border border-red-500/30 rounded-xl p-4 text-red-300 text-sm">
              {error}
            </div>
          )}

          {/* Empty state */}
          {!loading && !error && sessions.length === 0 && (
            <div className="text-center py-8">
              <div className="text-gray-500 text-5xl mb-3">📭</div>
              <p className="text-gray-400 text-sm">No sessions yet</p>
              <p className="text-gray-500 text-xs mt-1">Record and summarize to save sessions</p>
            </div>
          )}

          {/* Sessions list */}
          {!loading && !error && sessions.length > 0 && (
            <div className="space-y-2">
              {sessions.map((session) => (
                <button
                  key={session.id}
                  onClick={() => handleSessionClick(session.id)}
                  className="w-full text-left p-4 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-purple-500/30 transition-all group"
                >
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <span className="text-xs text-gray-400">
                      {formatDate(session.created_at)}
                    </span>
                    <svg className="w-4 h-4 text-gray-500 group-hover:text-purple-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                  <p className="text-sm text-gray-300 line-clamp-2 leading-relaxed">
                    {session.transcript_preview}
                  </p>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Overlay for mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-20 md:hidden"
          onClick={onToggle}
        ></div>
      )}
    </>
  )
}

export default SessionHistory
