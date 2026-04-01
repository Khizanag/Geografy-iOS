import Foundation

/// Persisted result of a completed daily challenge, stored as JSON on disk.
public struct DailyChallengeResult: Identifiable, Codable {
    public let id: String
    public let userID: String
    public let dateKey: String
    public let challengeType: String
    public let score: Int
    public let maxScore: Int
    public let completedAt: Date
    public let timeSpentSeconds: Double

    public var accuracy: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore)
    }

    public init(
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
    public static func dateKey(for date: Date = .now) -> String {
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
