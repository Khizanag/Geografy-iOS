import Geografy_Core_Common
@testable import Geografy_Feature_Quiz
import Testing

@Suite("SpeedRunNameIndex")
struct SpeedRunNameIndexTests {
    static let index = SpeedRunNameIndex(
        countries: [
            makeCountry("CI", "Côte d'Ivoire"),
            makeCountry("US", "United States"),
            makeCountry("FR", "France"),
        ]
    )

    @Test("Official names match without case or diacritics")
    func officialNames() {
        #expect(Self.index.codes(named: SpeedRunNameIndex.normalize("FRANCE")) == ["FR"])
        #expect(Self.index.codes(named: SpeedRunNameIndex.normalize("Côte d'Ivoire")) == ["CI"])
        #expect(Self.index.codes(named: SpeedRunNameIndex.normalize("cote d'ivoire")) == ["CI"])
    }

    @Test("Alternate names resolve to their country", arguments: ["usa", "america", "u.s.", "united states"])
    func alternateNames(name: String) {
        #expect(Self.index.codes(named: SpeedRunNameIndex.normalize(name)) == ["US"])
    }

    @Test("Ivory Coast resolves through its alternate name")
    func ivoryCoast() {
        #expect(Self.index.codes(named: "ivory coast") == ["CI"])
    }

    @Test("Unknown and partial names match nothing", arguments: ["", "fra", "atlantis"])
    func unknownNames(name: String) {
        #expect(Self.index.codes(named: name).isEmpty)
    }

    @Test("Alternate names of countries missing from the list match nothing")
    func missingCountryAlternates() {
        #expect(Self.index.codes(named: "uk").isEmpty)
    }

    static func makeCountry(_ code: String, _ name: String) -> Country {
        Country(
            code: code,
            name: name,
            capital: "",
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
            organizations: [],
        )
    }
}
