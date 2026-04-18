import Foundation
@testable import Geografy_Core_Quiz
import Testing

@MainActor
struct QuizSessionTests {
    @Test("New session is idle with zero counters")
    func newSessionIsIdle() {
        let session = makeSession(totalQuestions: 5)
        #expect(session.state == .idle)
        #expect(session.score == 0)
        #expect(session.streak == 0)
        #expect(session.bestStreak == 0)
        #expect(session.correctCount == 0)
        #expect(session.wrongCount == 0)
        #expect(session.skippedCount == 0)
        #expect(session.xpEarned == 0)
        #expect(session.questionIndex == 0)
    }

    @Test("start() transitions to .presenting and stamps startedAt")
    func startTransitionsToPresenting() {
        let session = makeSession(totalQuestions: 3)
        session.start()
        #expect(session.state == .presenting)
        #expect(session.startedAt != nil)
    }

    @Test("correct answer increments score, streak, bestStreak, correctCount, xpEarned")
    func correctAnswerUpdatesCounters() {
        let session = makeSession(totalQuestions: 3, xpPerCorrect: 10)
        session.start()
        session.submitAnswer(isCorrect: true)
        #expect(session.score == 10)
        #expect(session.streak == 1)
        #expect(session.bestStreak == 1)
        #expect(session.correctCount == 1)
        #expect(session.xpEarned == 10)
        if case .answered(let outcome) = session.state {
            if case .correct(let xp, let multiplier) = outcome {
                #expect(xp == 10)
                #expect(multiplier == 1)
            } else {
                Issue.record("Expected .correct outcome, got \(outcome)")
            }
        } else {
            Issue.record("Expected .answered, got \(session.state)")
        }
    }

    @Test("wrong answer resets streak but preserves bestStreak")
    func wrongAnswerResetsStreakPreservesBest() {
        let session = makeSession(totalQuestions: 3)
        session.start()
        session.submitAnswer(isCorrect: true)
        session.advance()
        session.submitAnswer(isCorrect: true)
        #expect(session.bestStreak == 2)
        session.advance()
        session.submitAnswer(isCorrect: false)
        #expect(session.streak == 0)
        #expect(session.bestStreak == 2)
        #expect(session.wrongCount == 1)
    }

    @Test("streakBonusEvery triggers a 2x multiplier on the Nth correct answer")
    func streakMultiplierKicksIn() {
        let session = makeSession(totalQuestions: 5, xpPerCorrect: 10, streakBonusEvery: 3)
        session.start()
        session.submitAnswer(isCorrect: true); session.advance()
        session.submitAnswer(isCorrect: true); session.advance()
        session.submitAnswer(isCorrect: true) // third correct → multiplier kicks in
        #expect(session.score == 40) // 10 + 10 + 20
        if case .answered(.correct(_, let multiplier)) = session.state {
            #expect(multiplier == 2)
        } else {
            Issue.record("Expected .correct with 2x multiplier")
        }
    }

    @Test("advance() completes session after the final question")
    func advanceCompletesAfterFinalQuestion() {
        let session = makeSession(totalQuestions: 2)
        session.start()
        session.submitAnswer(isCorrect: true)
        session.advance()
        #expect(session.state == .presenting)
        session.submitAnswer(isCorrect: true)
        session.advance()
        if case .complete(let summary) = session.state {
            #expect(summary.completed)
            #expect(summary.correct == 2)
            #expect(summary.wrong == 0)
            #expect(summary.totalQuestions == 2)
        } else {
            Issue.record("Expected .complete, got \(session.state)")
        }
    }

    @Test("losing all lives ends the session as incomplete")
    func losingLivesEndsSession() {
        let session = makeSession(totalQuestions: 10, initialLives: 2)
        session.start()
        session.submitAnswer(isCorrect: false); session.advance()
        session.submitAnswer(isCorrect: false); session.advance()
        if case .complete(let summary) = session.state {
            #expect(!summary.completed)
            #expect(summary.wrong == 2)
        } else {
            Issue.record("Expected .complete after lives exhausted, got \(session.state)")
        }
    }

    @Test("skip() counts as skipped and resets streak but does not consume a life")
    func skipBehaviour() {
        let session = makeSession(totalQuestions: 3, initialLives: 3)
        session.start()
        session.submitAnswer(isCorrect: true)
        session.advance()
        session.skip()
        #expect(session.skippedCount == 1)
        #expect(session.streak == 0)
        #expect(session.livesRemaining == 3)
    }

    @Test("timeout() counts as wrong and consumes a life if lives enabled")
    func timeoutBehaviour() {
        let session = makeSession(totalQuestions: 3, initialLives: 3)
        session.start()
        session.timeout()
        #expect(session.wrongCount == 1)
        #expect(session.livesRemaining == 2)
        if case .answered(.timeout) = session.state {
            // pass
        } else {
            Issue.record("Expected .timeout outcome")
        }
    }

    @Test("reset() restores all counters and idle state")
    func resetClearsState() {
        let session = makeSession(totalQuestions: 3, initialLives: 2)
        session.start()
        session.submitAnswer(isCorrect: true)
        session.advance()
        session.submitAnswer(isCorrect: false)
        session.reset()
        #expect(session.state == .idle)
        #expect(session.score == 0)
        #expect(session.streak == 0)
        #expect(session.bestStreak == 0)
        #expect(session.correctCount == 0)
        #expect(session.wrongCount == 0)
        #expect(session.livesRemaining == 2)
        #expect(session.startedAt == nil)
    }

    @Test("submitAnswer is a no-op unless state is .presenting")
    func submitAnswerGuardedByState() {
        let session = makeSession(totalQuestions: 3)
        session.submitAnswer(isCorrect: true)
        #expect(session.score == 0, "submit in .idle should not score")
    }

    @Test("ResultSummary derives accuracy and average time per question")
    func summaryDerivations() {
        let summary = QuizResultSummary(
            score: 100,
            correct: 8,
            wrong: 2,
            skipped: 0,
            bestStreak: 5,
            totalQuestions: 10,
            elapsed: 20,
            xpEarned: 100,
            completed: true
        )
        #expect(summary.accuracy == 0.8)
        #expect(summary.averageTimePerQuestion == 2.0)
    }
}

// MARK: - Helpers
private extension QuizSessionTests {
    func makeSession(
        totalQuestions: Int,
        initialLives: Int = 0,
        xpPerCorrect: Int = 10,
        streakBonusEvery: Int = 3,
        timePerQuestion: TimeInterval? = nil
    ) -> QuizSession {
        QuizSession(
            configuration: .init(
                totalQuestions: totalQuestions,
                initialLives: initialLives,
                xpPerCorrect: xpPerCorrect,
                streakBonusEvery: streakBonusEvery,
                timePerQuestion: timePerQuestion
            )
        )
    }
}
