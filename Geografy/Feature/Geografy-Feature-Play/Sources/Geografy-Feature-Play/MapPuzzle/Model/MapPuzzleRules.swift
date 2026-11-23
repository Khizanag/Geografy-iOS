import Geografy_Core_Common

/// How a Map Puzzle round is sized, shared by the setup screen's facts and the game itself.
enum MapPuzzleRules {
    static let optionsPerQuestion = 4
    static let estimatedSecondsPerQuestion = 12
}

// MARK: - Round Size
extension MapPuzzleRules {
    /// A region needs enough countries to fill every option of a question.
    static func isPlayable(countryCount: Int) -> Bool {
        countryCount >= optionsPerQuestion
    }

    /// The rounds the player chose, or every country in a region with fewer; none in a region too small to play.
    static func questionCount(requested: QuestionCount, countryCount: Int) -> Int {
        guard isPlayable(countryCount: countryCount) else { return 0 }
        return min(requested.rawValue, countryCount)
    }

    /// Rounded up to whole minutes, so a short round still reads as "1 min" rather than "0 min".
    static func estimatedMinutes(forQuestionCount questionCount: Int) -> Int {
        guard questionCount > 0 else { return 0 }
        let seconds = questionCount * estimatedSecondsPerQuestion
        return (seconds + 59) / 60
    }
}
