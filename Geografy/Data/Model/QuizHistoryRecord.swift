import Foundation
import SwiftData

@Model
final class QuizHistoryRecord {
    var id: String
    var userID: String
    var quizType: String
    var difficulty: String
    var region: String
    var correctCount: Int
    var totalCount: Int
    var totalTimeSeconds: Double
    var xpEarned: Int
    var completedAt: Date

    var accuracy: Double { Double(correctCount) / Double(totalCount) }

    init(
        id: String = UUID().uuidString,
        userID: String,
        quizType: String,
        difficulty: String,
        region: String,
        correctCount: Int,
        totalCount: Int,
        totalTimeSeconds: Double,
        xpEarned: Int,
        completedAt: Date = .now
    ) {
        self.id = id
        self.userID = userID
        self.quizType = quizType
        self.difficulty = difficulty
        self.region = region
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.totalTimeSeconds = totalTimeSeconds
        self.xpEarned = xpEarned
        self.completedAt = completedAt
    }
}
