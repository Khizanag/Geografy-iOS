import Geografy_Core_Common
import Geografy_Core_Navigation
@testable import Geografy_Feature_QuizLibrary
import Testing

@Suite("Quiz Library")
struct QuizLibraryTests {
    static let countries: [Country] = [
        makeCountry("FR", "France", "Paris", .europe),
        makeCountry("DE", "Germany", "Berlin", .europe),
        makeCountry("JP", "Japan", "Tokyo", .asia),
        makeCountry("BR", "Brazil", "Brasília", .southAmerica),
        makeCountry("KE", "Kenya", "Nairobi", .africa),
        makeCountry("US", "United States", "Washington, D.C.", .northAmerica),
        makeCountry("AU", "Australia", "Canberra", .oceania),
    ]

    @Test("Every tab has a title")
    func tabTitles() {
        for tab in QuizLibraryTab.allCases {
            #expect(!tab.title.isEmpty)
        }
    }

    @Test("Pack IDs are unique")
    func uniquePackIDs() {
        let packs = QuizPackService.makeAllPacks(countries: Self.countries)

        #expect(Set(packs.map(\.id)).count == packs.count)
    }

    @Test("Every prerequisite points at an existing pack")
    func prerequisitesResolve() {
        let packs = QuizPackService.makeAllPacks(countries: Self.countries)
        let ids = Set(packs.map(\.id))

        for prerequisite in packs.compactMap(\.prerequisitePackID) {
            #expect(ids.contains(prerequisite))
        }
    }
}

// MARK: - Helpers
private extension QuizLibraryTests {
    static func makeCountry(
        _ code: String,
        _ name: String,
        _ capital: String,
        _ continent: Country.Continent
    ) -> Country {
        Country(
            code: code,
            name: name,
            capital: capital,
            flagEmoji: "",
            continent: continent,
            area: 1,
            population: 1_000_000,
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
