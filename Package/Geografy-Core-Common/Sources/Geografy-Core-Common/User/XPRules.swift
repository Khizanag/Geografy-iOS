import Foundation

/// How much XP each activity earns, in one place, so learning pays the same wherever it happens. Every game pays a
/// little for taking part and more for doing well, on the scale of a quiz: 15 to 60 XP a round.
public enum XPRules {
    // MARK: - Quizzes
    public static func quiz(difficulty: QuizDifficulty, accuracy: Double, isTyping: Bool) -> Int {
        let (base, maxBonus) = switch difficulty {
        case .easy: (15, 10)
        case .medium: (25, 15)
        case .hard: (40, 20)
        }
        let multiplier = isTyping ? 1.5 : 1.0
        return Int(Double(base + Int(clamped(accuracy) * Double(maxBonus))) * multiplier)
    }

    public static func quizSource(for difficulty: QuizDifficulty) -> XPSource {
        switch difficulty {
        case .easy: .quizCompletedEasy
        case .medium: .quizCompletedMedium
        case .hard: .quizCompletedHard
        }
    }

    /// Up to 100 for the share named; finishing adds 50 and a speed bonus, so giving up at once earns nothing.
    public static func speedRun(completionRate: Double, elapsedSeconds: TimeInterval) -> Int {
        let named = Int(clamped(completionRate) * 100)
        guard completionRate >= 1 else { return named }
        let speedBonus = switch elapsedSeconds {
        case ..<60: 100
        case ..<120: 60
        case ..<300: 30
        case ..<600: 15
        default: 5
        }
        return named + 50 + speedBonus
    }

    public static func multiplayer(won: Bool) -> Int {
        won ? 25 : 10
    }

    // MARK: - Games
    /// 25 for finishing today's challenge, up to 25 more for the score.
    public static func dailyChallenge(score: Int, maxScore: Int) -> Int {
        25 + Int(fraction(score, of: maxScore) * 25)
    }

    /// 2 a round for playing, up to 2 more for accuracy.
    public static func pinDrop(rounds: Int, averageAccuracy: Double) -> Int {
        rounds * 2 + Int((Double(rounds * 2) * clamped(averageAccuracy)).rounded())
    }

    /// 2 a question for playing, 2 more for each right answer.
    public static func mapPuzzle(questions: Int, correct: Int) -> Int {
        questions * 2 + max(correct, 0) * 2
    }

    /// 2 a card, up to 40 for a session.
    public static func flashcardSession(cardsReviewed: Int) -> Int {
        min(max(cardsReviewed, 0) * 2, 40)
    }

    public static let lessonCompleted = 15

    /// 3 a word found, 10 more for finding them all without revealing the rest.
    public static func wordSearch(wordsFound: Int, foundAll: Bool) -> Int {
        max(wordsFound, 0) * 3 + (foundAll ? 10 : 0)
    }

    // MARK: - Exploring
    public static let countryExplored = 5

    /// Travel rewards marking countries, not travelling, so only the first few count; otherwise marking the
    /// whole world would jump several levels at once.
    public static func travel(_ status: TravelStatus, alreadyRewarded: Int) -> Int {
        switch status {
        case .visited: alreadyRewarded < 25 ? 20 : 0
        case .wantToVisit: alreadyRewarded < 20 ? 5 : 0
        }
    }
}

// MARK: - Helpers
private extension XPRules {
    static func clamped(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func fraction(_ value: Int, of total: Int) -> Double {
        guard total > 0 else { return 0 }
        return clamped(Double(value) / Double(total))
    }
}
