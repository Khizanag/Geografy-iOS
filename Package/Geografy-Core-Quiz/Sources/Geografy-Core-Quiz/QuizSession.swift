import Foundation
import Observation

/// Session state machine shared across every quiz-style feature.
///
/// The kernel is intentionally **model-agnostic** — it does not know how a
/// question looks. Each feature keeps its own `Question` type and simply
/// reports `isCorrect` via ``submitAnswer(isCorrect:)``. That keeps the
/// kernel small while unifying score, streak, lives, and timer handling.
@MainActor
@Observable
public final class QuizSession {
    public enum State: Sendable, Equatable {
        case idle
        case presenting
        case answered(outcome: AnswerOutcome)
        case complete(summary: QuizResultSummary)
    }

    public enum AnswerOutcome: Sendable, Equatable {
        case correct(xpEarned: Int, streakMultiplier: Double)
        case incorrect
        case skipped
        case timeout
    }

    public struct Configuration: Sendable {
        public var totalQuestions: Int
        /// 0 disables lives; game ends on third wrong for 3, etc.
        public var initialLives: Int
        public var xpPerCorrect: Int
        /// Every Nth consecutive correct answer multiplies XP by 2.
        public var streakBonusEvery: Int
        /// nil = untimed; otherwise the session marks the question as timed out.
        public var timePerQuestion: TimeInterval?

        public init(
            totalQuestions: Int,
            initialLives: Int = 0,
            xpPerCorrect: Int = 10,
            streakBonusEvery: Int = 3,
            timePerQuestion: TimeInterval? = nil
        ) {
            self.totalQuestions = totalQuestions
            self.initialLives = initialLives
            self.xpPerCorrect = xpPerCorrect
            self.streakBonusEvery = streakBonusEvery
            self.timePerQuestion = timePerQuestion
        }
    }

    public let configuration: Configuration

    public private(set) var state: State = .idle
    public private(set) var score: Int = 0
    public private(set) var streak: Int = 0
    public private(set) var bestStreak: Int = 0
    public private(set) var correctCount: Int = 0
    public private(set) var wrongCount: Int = 0
    public private(set) var skippedCount: Int = 0
    public private(set) var xpEarned: Int = 0
    public private(set) var questionIndex: Int = 0
    public private(set) var livesRemaining: Int
    public private(set) var startedAt: Date?

    public init(configuration: Configuration) {
        self.configuration = configuration
        self.livesRemaining = configuration.initialLives
    }
}

// MARK: - Lifecycle
public extension QuizSession {
    /// Begin the session and present the first question.
    func start() {
        reset()
        state = .presenting
        startedAt = Date()
    }

    /// Register an answer. The session updates score / streak / lives and
    /// transitions to ``State/answered(outcome:)`` — the caller is expected to
    /// render feedback and then call ``advance()``.
    func submitAnswer(isCorrect: Bool) {
        guard case .presenting = state else { return }
        if isCorrect {
            streak += 1
            bestStreak = max(bestStreak, streak)
            correctCount += 1
            let multiplier = streakMultiplier(for: streak)
            let xp = Int(Double(configuration.xpPerCorrect) * multiplier)
            xpEarned += xp
            score += xp
            state = .answered(outcome: .correct(xpEarned: xp, streakMultiplier: multiplier))
        } else {
            streak = 0
            wrongCount += 1
            if configuration.initialLives > 0 {
                livesRemaining = max(0, livesRemaining - 1)
            }
            state = .answered(outcome: .incorrect)
        }
    }

    /// Skip the current question without submitting. Counts as wrong for totals
    /// but does not consume a life.
    func skip() {
        guard case .presenting = state else { return }
        streak = 0
        skippedCount += 1
        state = .answered(outcome: .skipped)
    }

    /// Record a timeout. Counts as wrong and consumes a life if enabled.
    func timeout() {
        guard case .presenting = state else { return }
        streak = 0
        wrongCount += 1
        if configuration.initialLives > 0 {
            livesRemaining = max(0, livesRemaining - 1)
        }
        state = .answered(outcome: .timeout)
    }

    /// Move to the next question — or finish the session when exhausted or
    /// out of lives.
    func advance() {
        guard case .answered = state else { return }
        questionIndex += 1
        if configuration.initialLives > 0, livesRemaining == 0 {
            finish(completed: false)
            return
        }
        if questionIndex >= configuration.totalQuestions {
            finish(completed: true)
            return
        }
        state = .presenting
    }

    /// Complete the session early (user exits, or by ``advance()``).
    func finish(completed: Bool) {
        state = .complete(summary: currentSummary(completed: completed))
    }

    /// Reset all counters so the same session instance can be re-used.
    func reset() {
        state = .idle
        score = 0
        streak = 0
        bestStreak = 0
        correctCount = 0
        wrongCount = 0
        skippedCount = 0
        xpEarned = 0
        questionIndex = 0
        livesRemaining = configuration.initialLives
        startedAt = nil
    }
}

// MARK: - Helpers
private extension QuizSession {
    func streakMultiplier(for streak: Int) -> Double {
        guard configuration.streakBonusEvery > 0 else { return 1 }
        return streak > 0 && streak.isMultiple(of: configuration.streakBonusEvery) ? 2 : 1
    }

    func currentSummary(completed: Bool) -> QuizResultSummary {
        QuizResultSummary(
            score: score,
            correct: correctCount,
            wrong: wrongCount,
            skipped: skippedCount,
            bestStreak: bestStreak,
            totalQuestions: configuration.totalQuestions,
            elapsed: startedAt.map { Date().timeIntervalSince($0) } ?? 0,
            xpEarned: xpEarned,
            completed: completed
        )
    }
}
