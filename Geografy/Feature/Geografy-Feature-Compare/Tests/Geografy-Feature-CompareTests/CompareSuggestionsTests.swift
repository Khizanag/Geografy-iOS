import Geografy_Core_Common
@testable import Geografy_Feature_Compare
import Testing

@Suite("CompareSuggestions")
struct CompareSuggestionsTests {
    @Test("Neighbors come first, largest first")
    func neighborsFirst() {
        let suggestions = CompareSuggestions.suggestions(
            for: Self.andorra,
            among: Self.all,
            neighbors: ["AD": ["ES", "FR"]]
        )

        #expect(suggestions.prefix(2).map(\.country.code) == ["FR", "ES"])
        #expect(suggestions.prefix(2).allSatisfy { $0.reason == .neighbor })
    }

    @Test("The rest are the countries closest in population")
    func fillsWithSimilarPopulation() {
        let suggestions = CompareSuggestions.suggestions(
            for: Self.andorra,
            among: Self.all,
            neighbors: ["AD": ["FR"]],
            limit: 3
        )

        #expect(suggestions.map(\.country.code) == ["FR", "LI", "MC"])
        #expect(suggestions.dropFirst().allSatisfy { $0.reason == .similarPopulation })
    }

    @Test("Never suggests the country itself or the excluded one")
    func skipsSelfAndExcluded() {
        let suggestions = CompareSuggestions.suggestions(
            for: Self.andorra,
            among: Self.all,
            excluding: "MC",
            neighbors: [:]
        )

        #expect(!suggestions.contains { $0.country.code == "AD" })
        #expect(!suggestions.contains { $0.country.code == "MC" })
    }

    @Test("An island gets only similar-population suggestions")
    func islandHasNoNeighbors() {
        let suggestions = CompareSuggestions.suggestions(
            for: Self.andorra,
            among: Self.all,
            neighbors: ["AD": []],
            limit: 2
        )

        #expect(suggestions.map(\.country.code) == ["LI", "MC"])
        #expect(suggestions.allSatisfy { $0.reason == .similarPopulation })
    }
}

// MARK: - Fixtures
private extension CompareSuggestionsTests {
    static let andorra = makeCountry(code: "AD", population: 80_000)
    static let all = [
        andorra,
        makeCountry(code: "FR", population: 68_000_000),
        makeCountry(code: "ES", population: 48_000_000),
        makeCountry(code: "MC", population: 39_000),
        makeCountry(code: "LI", population: 39_500),
        makeCountry(code: "CN", population: 1_400_000_000)
    ]

    static func makeCountry(code: String, population: Int) -> Country {
        Country(
            code: code,
            name: code,
            capital: "",
            flagEmoji: "",
            continent: .europe,
            area: 1,
            population: population,
            populationDensity: 1,
            currency: Country.Currency(name: "", code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}
