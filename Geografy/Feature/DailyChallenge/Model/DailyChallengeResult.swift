import Foundation

/// Persisted result of a completed daily challenge, stored as JSON on disk.
struct DailyChallengeResult: Identifiable, Codable {
    let id: String
    let userID: String
    let dateKey: String
    let challengeType: String
    let score: Int
    let maxScore: Int
    let completedAt: Date
    let timeSpentSeconds: Double

    var accuracy: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore)
    }

    init(
        id: String = UUID().uuidString,
        userID: String,
        dateKey: String,
        challengeType: String,
        score: Int,
        maxScore: Int = 1000,
        completedAt: Date = .now,
        timeSpentSeconds: Double
    ) {
        self.id = id
        self.userID = userID
        self.dateKey = dateKey
        self.challengeType = challengeType
        self.score = score
        self.maxScore = maxScore
        self.completedAt = completedAt
        self.timeSpentSeconds = timeSpentSeconds
    }
}

// MARK: - Date Key
extension DailyChallengeResult {
    static func dateKey(for date: Date = .now) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
