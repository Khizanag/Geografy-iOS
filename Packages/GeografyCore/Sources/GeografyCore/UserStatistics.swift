import Foundation

public struct UserStatistics: Sendable {
    public let totalQuizzes: Int
    public let totalCorrectAnswers: Int
    public let totalQuestions: Int
    public let perfectScores: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let countriesExplored: Int
    public let countriesVisited: Int
    public let totalXP: Int
    public let memberSince: Date

    public init(
        totalQuizzes: Int,
        totalCorrectAnswers: Int,
        totalQuestions: Int,
        perfectScores: Int,
        currentStreak: Int,
        longestStreak: Int,
        countriesExplored: Int,
        countriesVisited: Int,
        totalXP: Int,
        memberSince: Date
    ) {
        self.totalQuizzes = totalQuizzes
        self.totalCorrectAnswers = totalCorrectAnswers
        self.totalQuestions = totalQuestions
        self.perfectScores = perfectScores
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.countriesExplored = countriesExplored
        self.countriesVisited = countriesVisited
        self.totalXP = totalXP
        self.memberSince = memberSince
    }
}

// MARK: - Computed Properties
public extension UserStatistics {
    var accuracyRate: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestions)
    }

    var accuracyPercentage: Int {
        Int((accuracyRate * 100).rounded())
    }

    var formattedMemberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        return formatter.string(from: memberSince)
    }
}
