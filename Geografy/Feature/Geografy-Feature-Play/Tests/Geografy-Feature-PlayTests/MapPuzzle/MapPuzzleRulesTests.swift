import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

@Suite("MapPuzzleRules")
struct MapPuzzleRulesTests {
    @Test("A region is playable only with enough countries for every option", arguments: [
        (0, false),
        (3, false),
        (4, true),
        (54, true),
    ])
    func playable(countryCount: Int, expected: Bool) {
        #expect(MapPuzzleRules.isPlayable(countryCount: countryCount) == expected)
    }

    @Test("A round asks the chosen number, capped by the region, and none in a region too small", arguments: [
        (QuestionCount.ten, 0, 0),
        (.ten, 3, 0),
        (.ten, 4, 4),
        (.ten, 54, 10),
        (.five, 54, 5),
        (.fifty, 54, 50),
        (.fifty, 12, 12),
    ])
    func questionCount(requested: QuestionCount, countryCount: Int, expected: Int) {
        #expect(MapPuzzleRules.questionCount(requested: requested, countryCount: countryCount) == expected)
    }

    @Test("The time estimate rounds up to whole minutes", arguments: [
        (0, 0),
        (1, 1),
        (5, 1),
        (10, 2),
    ])
    func estimatedMinutes(questionCount: Int, expected: Int) {
        #expect(MapPuzzleRules.estimatedMinutes(forQuestionCount: questionCount) == expected)
    }
}
