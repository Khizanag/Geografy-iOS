import Foundation

/// Terminal state of a quiz session. Value semantics so it can be passed safely
/// across actor boundaries (Game Center submission, analytics, share sheet).
public struct QuizResultSummary: Sendable, Equatable {
    public let score: Int
    public let correct: Int
    public let wrong: Int
    public let skipped: Int
    public let bestStreak: Int
    public let totalQuestions: Int
    public let elapsed: TimeInterval
    public let xpEarned: Int
    /// True when the player reached the final question; false if they bailed or lost all lives.
    public let completed: Bool

    public init(
        score: Int,
        correct: Int,
        wrong: Int,
        skipped: Int,
        bestStreak: Int,
        totalQuestions: Int,
        elapsed: TimeInterval,
        xpEarned: Int,
        completed: Bool
    ) {
        self.score = score
        self.correct = correct
        self.wrong = wrong
        self.skipped = skipped
        self.bestStreak = bestStreak
        self.totalQuestions = totalQuestions
        self.elapsed = elapsed
        self.xpEarned = xpEarned
        self.completed = completed
    }

    /// Percentage accuracy of attempted questions (wrong + correct). 0–1.
    public var accuracy: Double {
        let attempted = correct + wrong
        guard attempted > 0 else { return 0 }
        return Double(correct) / Double(attempted)
    }

    /// Average seconds per attempted question.
    public var averageTimePerQuestion: TimeInterval {
        let attempted = correct + wrong + skipped
        guard attempted > 0 else { return 0 }
        return elapsed / Double(attempted)
    }
}
