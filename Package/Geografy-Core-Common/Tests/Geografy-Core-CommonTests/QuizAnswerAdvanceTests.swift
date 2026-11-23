@testable import Geografy_Core_Common
import Testing

@Suite("Quiz answer advance")
struct QuizAnswerAdvanceTests {
    @Test("Each choice moves on after the answers it should", arguments: [
        (QuizAnswerAdvance.always, true, true),
        (.always, false, true),
        (.afterCorrect, true, true),
        (.afterCorrect, false, false),
        (.never, true, false),
        (.never, false, false)
    ])
    func movesOn(advance: QuizAnswerAdvance, isCorrect: Bool, expected: Bool) {
        #expect(advance.movesOn(afterCorrectAnswer: isCorrect) == expected)
    }
}
