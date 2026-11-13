/// How a Map Puzzle round is sized, shared by the setup screen's facts and the game itself.
enum MapPuzzleRules {
    static let questionsPerRound = 10
    static let optionsPerQuestion = 4
    static let estimatedSecondsPerQuestion = 12
}

// MARK: - Round Size
extension MapPuzzleRules {
    /// A region needs enough countries to fill every option of a question.
    static func isPlayable(countryCount: Int) -> Bool {
        countryCount >= optionsPerQuestion
    }

    static func questionCount(forCountryCount countryCount: Int) -> Int {
        guard isPlayable(countryCount: countryCount) else { return 0 }
        return min(questionsPerRound, countryCount)
    }

    /// Rounded up to whole minutes, so a short round still reads as "1 min" rather than "0 min".
    static func estimatedMinutes(forQuestionCount questionCount: Int) -> Int {
        guard questionCount > 0 else { return 0 }
        let seconds = questionCount * estimatedSecondsPerQuestion
        return (seconds + 59) / 60
    }
}
