import Geografy_Core_Common
@testable import Geografy_Feature_CurrencyConverter
import Testing

@Suite("CurrencyCatalog")
struct CurrencyCatalogTests {
    @Test("One entry per currency, sorted by code, countries most populous first")
    func groupsByCurrency() {
        let entries = CurrencyCatalog.entries(from: Self.countries)

        #expect(entries.map(\.code) == ["CHF", "EUR", "JPY", "USD", "XOF"])
        #expect(entries.first { $0.code == "EUR" }?.countryNames == ["Germany", "France", "Andorra"])
    }

    @Test("Countries without a currency code are skipped")
    func skipsEmptyCodes() {
        let entries = CurrencyCatalog.entries(from: [Self.makeCountry("AQ", "Antarctica", currency: "")])

        #expect(entries.isEmpty)
    }

    @Test(
        "Flag is the issuer's, the EU's for the euro, else the most populous user's",
        arguments: [
            ("USD", ["EC", "US"], "US"),
            ("CHF", ["CH", "LI"], "CH"),
            ("EUR", ["DE", "FR"], "EU"),
            ("XOF", ["CI", "SN"], "CI"),
        ]
    )
    func flagCode(currency: String, countryCodes: [String], expected: String) {
        #expect(CurrencyCatalog.flagCode(for: currency, countryCodes: countryCodes) == expected)
    }

    @Test("Usage names the country, or counts them when shared")
    func usageSummary() {
        let entries = CurrencyCatalog.entries(from: Self.countries)

        #expect(entries.first { $0.code == "JPY" }?.usageSummary == "Japan")
        #expect(entries.first { $0.code == "EUR" }?.usageSummary == "3 countries")
    }

    @Test("Major currencies keep their order and skip the excluded one")
    func majorExcluding() {
        let entries = CurrencyCatalog.entries(from: Self.countries)

        let major = CurrencyCatalog.major(in: entries, excluding: "EUR", limit: 3)

        #expect(major.map(\.code) == ["USD", "JPY", "CHF"])
    }
}

// MARK: - Fixtures
extension CurrencyCatalogTests {
    static let countries = [
        makeCountry("US", "United States", currency: "USD", population: 330_000_000),
        makeCountry("EC", "Ecuador", currency: "USD", population: 18_000_000),
        makeCountry("DE", "Germany", currency: "EUR", population: 84_000_000),
        makeCountry("FR", "France", currency: "EUR", population: 68_000_000),
        makeCountry("AD", "Andorra", currency: "EUR", population: 80_000),
        makeCountry("JP", "Japan", currency: "JPY", population: 125_000_000),
        makeCountry("CH", "Switzerland", currency: "CHF", population: 8_800_000),
        makeCountry("SN", "Senegal", currency: "XOF", population: 18_000_000),
        makeCountry("CI", "Ivory Coast", currency: "XOF", population: 28_000_000),
    ]

    static func makeCountry(_ code: String, _ name: String, currency: String, population: Int = 1) -> Country {
        Country(
            code: code,
            name: name,
            capital: "",
            flagEmoji: "",
            continent: .europe,
            area: 1,
            population: population,
            populationDensity: 1,
            currency: Country.Currency(name: "\(currency) name", code: currency),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}
