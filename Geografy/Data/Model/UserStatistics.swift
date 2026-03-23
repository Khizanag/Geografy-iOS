import Foundation

struct UserStatistics {
    let totalQuizzes: Int
    let totalCorrectAnswers: Int
    let totalQuestions: Int
    let perfectScores: Int
    let currentStreak: Int
    let longestStreak: Int
    let countriesExplored: Int
    let countriesVisited: Int
    let totalXP: Int
    let memberSince: Date
}

// MARK: - Computed Properties

extension UserStatistics {
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
