import CoreGraphics
import Geografy_Core_Common
@testable import Geografy_Feature_Map
import Testing

@Suite("Continent viewport")
struct ContinentViewportTests {
    @Test("Every continent the map filters to has an area to zoom to", arguments: [
        "Europe", "North America", "Oceania", "Asia", "Africa", "South America",
    ])
    func everyContinentHasArea(continent: String) throws {
        let rect = try #require(ContinentViewport.rect(for: continent))
        #expect(rect.width > 0)
        #expect(rect.height > 0)
    }

    @Test("A filter that isn't a continent zooms nowhere")
    func unknownFilter() {
        #expect(ContinentViewport.rect(for: "Atlantis") == nil)
    }

    @Test("Europe's area sits east of North America's")
    func continentsAreWhereTheyBelong() throws {
        let europe = try #require(ContinentViewport.rect(for: "Europe"))
        let northAmerica = try #require(ContinentViewport.rect(for: "North America"))
        #expect(europe.midX > northAmerica.midX)
    }
}

@Suite("Continent sort")
struct ContinentSortOptionTests {
    private let countries = [
        Self.country("Chile", population: 19, area: 756, gdpPerCapita: 15),
        Self.country("Austria", population: 9, area: 84, gdpPerCapita: 53),
        Self.country("Brazil", population: 216, area: 8_516, gdpPerCapita: nil),
    ]

    @Test("Names sort A to Z")
    func byName() {
        #expect(ContinentSortOption.name.sorted(countries).map(\.name) == ["Austria", "Brazil", "Chile"])
    }

    @Test("Population and area sort largest first")
    func bySize() {
        #expect(ContinentSortOption.population.sorted(countries).map(\.name) == ["Brazil", "Chile", "Austria"])
        #expect(ContinentSortOption.area.sorted(countries).map(\.name) == ["Brazil", "Chile", "Austria"])
    }

    @Test("GDP sorts richest first, with a country missing data last")
    func byGDP() {
        #expect(ContinentSortOption.gdp.sorted(countries).map(\.name) == ["Austria", "Chile", "Brazil"])
    }
}

// MARK: - Fixtures
private extension ContinentSortOptionTests {
    static func country(_ name: String, population: Int, area: Double, gdpPerCapita: Double?) -> Country {
        Country(
            code: String(name.prefix(2)).uppercased(),
            name: name,
            capital: "",
            flagEmoji: "",
            continent: .europe,
            area: area,
            population: population,
            populationDensity: 1,
            currency: Country.Currency(name: "", code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: gdpPerCapita,
            gdpPPP: nil,
            organizations: [],
        )
    }
}
