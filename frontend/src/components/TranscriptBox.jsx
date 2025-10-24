function TranscriptBox({ transcript, onSummarize, onReset, isSummarizing, isTranscribing }) {
  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-semibold text-gray-800">Transcript</h2>
        <div className="flex space-x-2">
          <button
            onClick={onSummarize}
            disabled={isSummarizing || isTranscribing}
            className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 
                     disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {isSummarizing ? 'Summarizing...' : 'Summarize'}
          </button>
          <button
            onClick={onReset}
            disabled={isSummarizing || isTranscribing}
            className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 
                     disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            Reset
          </button>
        </div>
      </div>

      <div className="bg-gray-50 rounded-lg p-4 max-h-96 overflow-y-auto">
        <p className="text-gray-800 whitespace-pre-wrap leading-relaxed">
          {transcript}
        </p>
      </div>

      <div className="mt-4 text-sm text-gray-500">
        {transcript.split(' ').length} words • {transcript.length} characters
      </div>
    </div>
  )
}

export default TranscriptBox
