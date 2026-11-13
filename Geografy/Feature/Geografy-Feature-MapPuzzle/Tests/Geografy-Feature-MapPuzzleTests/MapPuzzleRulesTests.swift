@testable import Geografy_Feature_MapPuzzle
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

    @Test("A round asks up to ten questions, and none in a region too small to play", arguments: [
        (0, 0),
        (3, 0),
        (4, 4),
        (10, 10),
        (54, 10),
    ])
    func questionCount(countryCount: Int, expected: Int) {
        #expect(MapPuzzleRules.questionCount(forCountryCount: countryCount) == expected)
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
