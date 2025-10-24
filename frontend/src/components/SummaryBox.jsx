/**
 * SummaryBox component - displays structured meeting summary with export option
 */
function SummaryBox({ summary, onExport, canExport = true }) {
  return (
    <div className="relative group">
      {/* Glassmorphism Card */}
      <div className="backdrop-blur-xl bg-white/10 rounded-3xl border border-white/20 shadow-2xl p-8 transition-all duration-300 hover:bg-white/15">
        <div className="mb-8">
          <h2 className="text-4xl font-bold text-white mb-2 flex items-center gap-3">
            <span className="text-5xl">✨</span>
            Meeting Summary
          </h2>
          <div className="h-1 w-32 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500 rounded-full"></div>
        </div>

        <div className="space-y-6">
          {/* Key Points */}
          <div className="relative group/card">
            <div className="absolute -inset-0.5 bg-gradient-to-r from-purple-500 to-indigo-500 rounded-2xl blur opacity-30 group-hover/card:opacity-50 transition-opacity"></div>
            <div className="relative bg-slate-900/60 backdrop-blur-sm rounded-2xl p-6 border border-purple-500/30">
              <h3 className="text-2xl font-bold text-purple-300 mb-4 flex items-center gap-2">
                <span className="text-3xl">📌</span>
                Key Points
              </h3>
              <ul className="space-y-3">
                {summary.key_points.map((point, index) => (
                  <li key={index} className="flex items-start gap-3 group/item">
                    <span className="flex-shrink-0 w-6 h-6 bg-gradient-to-br from-purple-500 to-indigo-500 rounded-full flex items-center justify-center text-white text-xs font-bold mt-0.5">
                      {index + 1}
                    </span>
                    <span className="text-gray-200 leading-relaxed flex-1 group-hover/item:text-white transition-colors">
                      {point}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* Decisions */}
          {summary.decisions.length > 0 && (
            <div className="relative group/card">
              <div className="absolute -inset-0.5 bg-gradient-to-r from-green-500 to-emerald-500 rounded-2xl blur opacity-30 group-hover/card:opacity-50 transition-opacity"></div>
              <div className="relative bg-slate-900/60 backdrop-blur-sm rounded-2xl p-6 border border-green-500/30">
                <h3 className="text-2xl font-bold text-green-300 mb-4 flex items-center gap-2">
                  <span className="text-3xl">✅</span>
                  Decisions Made
                </h3>
                <ul className="space-y-3">
                  {summary.decisions.map((decision, index) => (
                    <li key={index} className="flex items-start gap-3 group/item">
                      <span className="flex-shrink-0 w-6 h-6 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center text-white text-xs font-bold mt-0.5">
                        {index + 1}
                      </span>
                      <span className="text-gray-200 leading-relaxed flex-1 group-hover/item:text-white transition-colors">
                        {decision}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}

          {/* Action Items */}
          {summary.action_items.length > 0 && (
            <div className="relative group/card">
              <div className="absolute -inset-0.5 bg-gradient-to-r from-orange-500 to-pink-500 rounded-2xl blur opacity-30 group-hover/card:opacity-50 transition-opacity"></div>
              <div className="relative bg-slate-900/60 backdrop-blur-sm rounded-2xl p-6 border border-orange-500/30">
                <h3 className="text-2xl font-bold text-orange-300 mb-4 flex items-center gap-2">
                  <span className="text-3xl">🎯</span>
                  Action Items
                </h3>
                <ul className="space-y-3">
                  {summary.action_items.map((item, index) => (
                    <li key={index} className="flex items-start gap-3 group/item">
                      <span className="flex-shrink-0 w-6 h-6 bg-gradient-to-br from-orange-500 to-pink-500 rounded-full flex items-center justify-center text-white text-xs font-bold mt-0.5">
                        {index + 1}
                      </span>
                      <span className="text-gray-200 leading-relaxed flex-1 group-hover/item:text-white transition-colors">
                        {item}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </div>

        {/* Export Button */}
        <div className="mt-8 flex justify-center">
          <button 
            onClick={onExport}
            disabled={!canExport}
            className="group/export px-8 py-4 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500 text-white rounded-2xl font-bold text-lg
                     hover:from-purple-600 hover:via-pink-600 hover:to-blue-600 transition-all duration-300 shadow-xl hover:shadow-2xl hover:scale-105
                     disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100
                     flex items-center gap-3"
          >
            <svg className="w-6 h-6 group-hover/export:rotate-12 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Export as Markdown
          </button>
        </div>
      </div>
    </div>
  )
}

export default SummaryBox
