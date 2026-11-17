import Foundation
@testable import Geografy_Core_Common
import Testing

@Suite("XP rules")
struct XPRulesTests {
    @Test("Quiz XP is unchanged by the move into XPRules", arguments: [
        (QuizDifficulty.easy, 1.0, false, 25),
        (.medium, 0.0, false, 25),
        (.hard, 0.5, true, 75),
    ])
    func quiz(difficulty: QuizDifficulty, accuracy: Double, isTyping: Bool, expected: Int) {
        #expect(XPRules.quiz(difficulty: difficulty, accuracy: accuracy, isTyping: isTyping) == expected)
    }

    @Test("Speed Run pays for countries named, and the bonuses only for finishing")
    func speedRun() {
        #expect(XPRules.speedRun(completionRate: 1, elapsedSeconds: 50) == 250)
        #expect(XPRules.speedRun(completionRate: 0.5, elapsedSeconds: 700) == 50)
        #expect(XPRules.speedRun(completionRate: 0, elapsedSeconds: 5) == 0)
    }

    @Test("The Daily Challenge pays 25 to finish and up to 25 more for the score")
    func dailyChallenge() {
        #expect(XPRules.dailyChallenge(score: 0, maxScore: 1_000) == 25)
        #expect(XPRules.dailyChallenge(score: 1_000, maxScore: 1_000) == 50)
        #expect(XPRules.dailyChallenge(score: 500, maxScore: 0) == 25)
    }

    @Test("Games pay for taking part and more for doing well")
    func games() {
        #expect(XPRules.pinDrop(rounds: 10, averageAccuracy: 0) == 20)
        #expect(XPRules.pinDrop(rounds: 10, averageAccuracy: 1) == 40)
        #expect(XPRules.mapPuzzle(questions: 10, correct: 7) == 34)
        #expect(XPRules.wordSearch(wordsFound: 8, foundAll: true) == 34)
        #expect(XPRules.wordSearch(wordsFound: 3, foundAll: false) == 9)
    }

    @Test("A flashcard session pays 2 a card, up to 40")
    func flashcards() {
        #expect(XPRules.flashcardSession(cardsReviewed: 5) == 10)
        #expect(XPRules.flashcardSession(cardsReviewed: 197) == 40)
    }

    @Test("Only the first visited and wished-for countries pay")
    func travelIsCapped() {
        #expect(XPRules.travel(.visited, alreadyRewarded: 24) == 20)
        #expect(XPRules.travel(.visited, alreadyRewarded: 25) == 0)
        #expect(XPRules.travel(.wantToVisit, alreadyRewarded: 19) == 5)
        #expect(XPRules.travel(.wantToVisit, alreadyRewarded: 20) == 0)
    }
}
