function SummaryBox({ summary }) {
  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <h2 className="text-2xl font-semibold text-gray-800 mb-4">
        Meeting Summary
      </h2>

      <div className="space-y-6">
        {/* Key Points */}
        <div>
          <h3 className="text-lg font-semibold text-indigo-800 mb-2 flex items-center">
            <span className="mr-2">📌</span>
            Key Points
          </h3>
          <ul className="list-disc list-inside space-y-1 text-gray-700">
            {summary.key_points.map((point, index) => (
              <li key={index} className="leading-relaxed">{point}</li>
            ))}
          </ul>
        </div>

        {/* Decisions */}
        {summary.decisions.length > 0 && (
          <div>
            <h3 className="text-lg font-semibold text-green-800 mb-2 flex items-center">
              <span className="mr-2">✅</span>
              Decisions
            </h3>
            <ul className="list-disc list-inside space-y-1 text-gray-700">
              {summary.decisions.map((decision, index) => (
                <li key={index} className="leading-relaxed">{decision}</li>
              ))}
            </ul>
          </div>
        )}

        {/* Action Items */}
        {summary.action_items.length > 0 && (
          <div>
            <h3 className="text-lg font-semibold text-orange-800 mb-2 flex items-center">
              <span className="mr-2">🎯</span>
              Action Items
            </h3>
            <ul className="list-disc list-inside space-y-1 text-gray-700">
              {summary.action_items.map((item, index) => (
                <li key={index} className="leading-relaxed">{item}</li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  )
}

export default SummaryBox
