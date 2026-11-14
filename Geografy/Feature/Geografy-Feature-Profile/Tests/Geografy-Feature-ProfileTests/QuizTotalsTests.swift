#if !os(tvOS)
import Geografy_Core_Common
@testable import Geografy_Feature_Profile
import Testing

@Suite("QuizTotals")
struct QuizTotalsTests {
    @Test("Totals add up answers, questions, and perfect scores")
    func addsUpHistory() {
        let totals = QuizTotals(
            userID: "me",
            quizzes: [
                Self.makeRecord(correct: 10, total: 10),
                Self.makeRecord(correct: 7, total: 10),
                Self.makeRecord(correct: 5, total: 5),
            ]
        )

        #expect(totals.userID == "me")
        #expect(totals.quizCount == 3)
        #expect(totals.correctAnswers == 22)
        #expect(totals.questions == 25)
        #expect(totals.perfectScores == 2)
    }

    @Test("No history gives zero totals")
    func emptyHistory() {
        let totals = QuizTotals(userID: "me", quizzes: [])

        #expect(totals.quizCount == 0)
        #expect(totals.correctAnswers == 0)
        #expect(totals.perfectScores == 0)
    }
}

// MARK: - Fixtures
private extension QuizTotalsTests {
    static func makeRecord(correct: Int, total: Int) -> QuizHistoryRecord {
        QuizHistoryRecord(
            userID: "me",
            quizType: "flags",
            difficulty: "easy",
            region: "world",
            correctCount: correct,
            totalCount: total,
            totalTimeSeconds: 60,
            xpEarned: 10
        )
    }
}
#endif
