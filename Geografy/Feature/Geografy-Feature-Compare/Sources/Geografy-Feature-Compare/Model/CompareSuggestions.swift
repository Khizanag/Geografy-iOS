import Foundation
import Geografy_Core_Common

/// A country worth comparing against the one already picked, and why.
struct CompareSuggestion: Identifiable, Equatable {
    enum Reason: Equatable {
        case neighbor
        case similarPopulation

        var title: String {
            switch self {
            case .neighbor: "Shares a border"
            case .similarPopulation: "Similar population"
            }
        }
    }

    let country: Country
    let reason: Reason

    var id: String { country.code }
}

enum CompareSuggestions {
    private static let neighborLimit = 3

    /// Neighbors first, then the countries closest in population, so the list is never empty.
    static func suggestions(
        for country: Country,
        among countries: [Country],
        excluding excludedCode: String? = nil,
        neighbors: [String: [String]] = CountryNeighbors.data,
        limit: Int = 5
    ) -> [CompareSuggestion] {
        let candidates = countries.filter { $0.code != country.code && $0.code != excludedCode }
        let neighborCodes = Set(neighbors[country.code] ?? [])

        let neighborSuggestions = candidates
            .filter { neighborCodes.contains($0.code) }
            .sorted { $0.population > $1.population }
            .prefix(min(neighborLimit, limit))
            .map { CompareSuggestion(country: $0, reason: .neighbor) }

        let suggestedCodes = Set(neighborSuggestions.map(\.country.code))
        let similarSuggestions = candidates
            .filter { !suggestedCodes.contains($0.code) }
            .sorted { populationDistance($0, country) < populationDistance($1, country) }
            .prefix(limit - neighborSuggestions.count)
            .map { CompareSuggestion(country: $0, reason: .similarPopulation) }

        return neighborSuggestions + similarSuggestions
    }

    /// Distance on a log scale, so 40k vs 80k counts as close as 40M vs 80M.
    private static func populationDistance(_ candidate: Country, _ country: Country) -> Double {
        abs(log(Double(max(candidate.population, 1))) - log(Double(max(country.population, 1))))
    }
}
