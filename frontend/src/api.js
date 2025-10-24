/**
 * API helper module - centralizes all backend API calls
 */

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

/**
 * Get system status
 */
export async function getStatus() {
  const response = await fetch(`${API_URL}/api/status`)
  if (!response.ok) {
    throw new Error('Failed to fetch status')
  }
  return response.json()
}

/**
 * Transcribe audio file
 * @param {Blob} audioBlob - Audio file to transcribe
 * @returns {Promise<{transcript: string, status: string}>}
 */
export async function transcribeAudio(audioBlob) {
  const formData = new FormData()
  formData.append('audio', audioBlob, 'recording.webm')

  const response = await fetch(`${API_URL}/api/transcribe`, {
    method: 'POST',
    body: formData,
  })

  const data = await response.json()

  if (!response.ok) {
    throw new Error(data.error || 'Transcription failed')
  }

  return data
}

/**
 * Summarize transcript
 * @param {string} transcript - Transcript text
 * @param {boolean} saveSession - Whether to save as session
 * @returns {Promise<{summary: object, session_id?: string, status: string}>}
 */
export async function summarizeTranscript(transcript, saveSession = true) {
  const response = await fetch(`${API_URL}/api/summarize`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ transcript, save_session: saveSession }),
  })

  const data = await response.json()

  if (!response.ok) {
    throw new Error(data.error || 'Summarization failed')
  }

  return data
}

/**
 * Get list of sessions
 * @returns {Promise<{sessions: Array, count: number}>}
 */
export async function listSessions() {
  const response = await fetch(`${API_URL}/api/sessions`)
  
  if (!response.ok) {
    throw new Error('Failed to load sessions')
  }

  return response.json()
}

/**
 * Get single session by ID
 * @param {string} sessionId - Session ID
 * @returns {Promise<{session: object}>}
 */
export async function getSession(sessionId) {
  const response = await fetch(`${API_URL}/api/sessions/${sessionId}`)
  
  const data = await response.json()

  if (!response.ok) {
    throw new Error(data.error || 'Failed to load session')
  }

  return data
}

/**
 * Export session as Markdown
 * @param {string} sessionId - Session ID
 * @returns {Promise<Blob>}
 */
export async function exportSession(sessionId) {
  const response = await fetch(`${API_URL}/api/sessions/${sessionId}/export`)
  
  if (!response.ok) {
    throw new Error('Failed to export session')
  }

  return response.blob()
}

/**
 * Delete session
 * @param {string} sessionId - Session ID
 * @returns {Promise<{message: string}>}
 */
export async function deleteSession(sessionId) {
  const response = await fetch(`${API_URL}/api/sessions/${sessionId}`, {
    method: 'DELETE',
  })
  
  const data = await response.json()

  if (!response.ok) {
    throw new Error(data.error || 'Failed to delete session')
  }

  return data
}
