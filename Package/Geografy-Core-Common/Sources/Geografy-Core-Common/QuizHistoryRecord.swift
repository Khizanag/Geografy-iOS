import Foundation
import SwiftData

@Model
public final class QuizHistoryRecord {
    public var id: String
    public var userID: String
    public var quizType: String
    public var difficulty: String
    public var region: String
    public var correctCount: Int
    public var totalCount: Int
    public var totalTimeSeconds: Double
    public var xpEarned: Int
    public var completedAt: Date

    public var accuracy: Double { Double(correctCount) / Double(totalCount) }

    public init(
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
