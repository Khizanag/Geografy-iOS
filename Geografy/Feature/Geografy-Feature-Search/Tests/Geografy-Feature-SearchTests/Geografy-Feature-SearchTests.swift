import Geografy_Core_Common
@testable import Geografy_Feature_Search
import Testing

@Suite("SearchEngine")
struct SearchEngineTests {
    @Test("A blank query finds nothing")
    func blankQueryIsEmpty() {
        let results = Self.engine.results(for: "   ", scope: .all)

        #expect(results.isEmpty)
    }

    @Test("Matching ignores letter case and accents")
    func ignoresCaseAndAccents() {
        let results = Self.engine.results(for: "BOGOTA", scope: .capitals)

        #expect(results.sections.first?.rows == [.capital(country: Self.colombia, capitalName: "Bogotá")])
    }

    @Test("A prefix match ranks above a match in the middle of a name")
    func prefixRanksFirst() {
        let results = Self.engine.results(for: "ge", scope: .countries)

        #expect(results.sections.first?.rows == [.country(Self.georgia), .country(Self.germany), .country(Self.niger)])
    }

    @Test("The best prefix match becomes the top hit and leaves its section")
    func topHitIsBestPrefixMatch() {
        let results = Self.engine.results(for: "tbil", scope: .all)

        #expect(results.topHit == .capital(country: Self.georgia, capitalName: "Tbilisi"))
        #expect(results.sections.isEmpty)
    }

    @Test("A match only in the middle of a name is never a top hit")
    func middleMatchIsNotTopHit() {
        let results = Self.engine.results(for: "ige", scope: .all)

        #expect(results.topHit == nil)
        #expect(results.sections.first?.rows == [.country(Self.niger)])
    }

    @Test("A narrowed scope shows only that kind and no top hit")
    func scopeNarrowsResults() {
        let results = Self.engine.results(for: "united", scope: .organizations)

        #expect(results.topHit == nil)
        #expect(results.sections.map(\.id) == ["organizations"])
    }

    @Test("Organizations match by their short name too")
    func organizationShortName() throws {
        let nato = try #require(Organization.find("NATO"))

        let results = Self.engine.results(for: "nato", scope: .organizations)

        #expect(results.sections.first?.rows.first == .organization(nato))
    }
}

// MARK: - Fixtures
private extension SearchEngineTests {
    static let georgia = makeCountry(code: "GE", name: "Georgia", capital: "Tbilisi")
    static let germany = makeCountry(code: "DE", name: "Germany", capital: "Berlin")
    static let niger = makeCountry(code: "NE", name: "Niger", capital: "Niamey")
    static let colombia = makeCountry(code: "CO", name: "Colombia", capital: "Bogotá")

    static let engine = SearchEngine(
        countries: [germany, niger, colombia, georgia],
        organizations: Organization.all
    )

    static func makeCountry(code: String, name: String, capital: String) -> Country {
        Country(
            code: code,
            name: name,
            capital: capital,
            flagEmoji: "",
            continent: .europe,
            area: 1,
            population: 1,
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
