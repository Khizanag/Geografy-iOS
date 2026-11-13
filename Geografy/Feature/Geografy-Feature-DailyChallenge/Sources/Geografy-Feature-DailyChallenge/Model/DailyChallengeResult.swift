import Foundation

/// Persisted result of a completed daily challenge, stored as JSON on disk.
public struct DailyChallengeResult: Identifiable, Codable {
    /// Every challenge starts at this score and loses points for hints and wrong answers.
    public static let defaultMaxScore = 1_000

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
        maxScore: Int = defaultMaxScore,
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
    public static func dateKey(for date: Date = .now, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents(
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

    /// The start of the day a date key such as "2026-11-13" names, or nil when the key isn't one.
    public static func date(forKey key: String, calendar: Calendar = .current) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, (1...12).contains(parts[1]), (1...31).contains(parts[2]) else {
            return nil
        }
        let components = DateComponents(year: parts[0], month: parts[1], day: parts[2])
        guard let date = calendar.date(from: components),
              calendar.component(.day, from: date) == parts[2] else {
            return nil
        }
        return calendar.startOfDay(for: date)
    }
}
