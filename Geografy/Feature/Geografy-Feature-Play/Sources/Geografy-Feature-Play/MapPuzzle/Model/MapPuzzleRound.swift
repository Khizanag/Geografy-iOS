import Geografy_Core_Common

/// One Map Puzzle round: the country the map highlights and the names offered for it. Codes, not countries, so a
/// multiplayer host can send the same rounds to the other phone.
public struct MapPuzzleRound: Codable, Equatable, Sendable {
    public let answerCode: String
    /// Every answer shown, the right one among them, in display order.
    public let optionCodes: [String]
}

// MARK: - Making Rounds
extension MapPuzzleRules {
    /// The rounds of a puzzle over `countries`, the ones drawn on its map: each asks about a different country,
    /// with names from the same region as the wrong answers.
    static func makeRounds(from countries: [Country], requested: QuestionCount) -> [MapPuzzleRound] {
        let count = questionCount(requested: requested, countryCount: countries.count)
        guard count > 0 else { return [] }
        return countries.shuffled().prefix(count).map { country in
            let others = countries.filter { $0.code != country.code }.shuffled().prefix(optionsPerQuestion - 1)
            return MapPuzzleRound(
                answerCode: country.code,
                optionCodes: (others.map(\.code) + [country.code]).shuffled()
            )
        }
    }
}
