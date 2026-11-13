import Geografy_Core_Common
import Geografy_Core_Service
@testable import Geografy_Feature_DistanceCalculator
import Testing

@Suite("DistanceSuggestions")
struct DistanceSuggestionsTests {
    @Test("Nearby capitals come closest first")
    func nearestFirst() {
        let suggestions = makeSuggestions(nearbyLimit: 3)

        #expect(suggestions.nearby.map(\.id) == ["AA", "BB", "CC"])
        #expect(suggestions.nearby.map(\.distanceKm) == suggestions.nearby.map(\.distanceKm).sorted())
    }

    @Test("Far-away capitals come farthest first, apart from the nearby ones")
    func farthestFirst() {
        let suggestions = makeSuggestions(nearbyLimit: 3, farAwayLimit: 2)

        #expect(suggestions.farAway.map(\.id) == ["FF", "EE"])
    }

    @Test("Neighbors are marked as sharing a border")
    func marksNeighbors() {
        let suggestions = makeSuggestions(neighbors: ["OO": ["BB"]], nearbyLimit: 3)

        #expect(suggestions.nearby.filter(\.sharesBorder).map(\.id) == ["BB"])
    }

    @Test("Never suggests the country itself, the excluded one, or one without a capital on record")
    func skipsUnusable() {
        let suggestions = makeSuggestions(excluding: "AA", nearbyLimit: 10, farAwayLimit: 10)
        let codes = (suggestions.nearby + suggestions.farAway).map(\.id)

        #expect(!codes.contains("OO"))
        #expect(!codes.contains("AA"))
        #expect(!codes.contains("XX"))
    }

    @Test("A short list never repeats a country in both sections")
    func noOverlap() {
        let suggestions = makeSuggestions(nearbyLimit: 4, farAwayLimit: 4)

        #expect(suggestions.nearby.map(\.id) == ["AA", "BB", "CC", "DD"])
        #expect(suggestions.farAway.map(\.id) == ["FF", "EE"])
    }

    @Test("A country without a capital on record gets no suggestions")
    func unknownOrigin() {
        let suggestions = DistanceSuggestions(
            for: Self.makeCountry("XX"),
            among: Self.countries,
            coordinate: Self.coordinate
        )

        #expect(suggestions.nearby.isEmpty)
        #expect(suggestions.farAway.isEmpty)
    }
}

// MARK: - Fixtures
private extension DistanceSuggestionsTests {
    /// Capitals strung along the equator, so distance grows with longitude.
    static let longitudes: [String: Double] = [
        "OO": 0,
        "AA": 1,
        "BB": 2,
        "CC": 5,
        "DD": 10,
        "EE": 40,
        "FF": 90,
    ]

    static let countries = ["OO", "AA", "BB", "CC", "DD", "EE", "FF", "XX"].map(makeCountry)

    static func coordinate(_ code: String) -> CapitalCoordinateService.Coordinate? {
        longitudes[code].map { CapitalCoordinateService.Coordinate(latitude: 0, longitude: $0) }
    }

    func makeSuggestions(
        excluding excludedCode: String? = nil,
        neighbors: [String: [String]] = [:],
        nearbyLimit: Int = 4,
        farAwayLimit: Int = 2
    ) -> DistanceSuggestions {
        DistanceSuggestions(
            for: Self.makeCountry("OO"),
            among: Self.countries,
            excluding: excludedCode,
            neighbors: neighbors,
            coordinate: Self.coordinate,
            nearbyLimit: nearbyLimit,
            farAwayLimit: farAwayLimit
        )
    }

    static func makeCountry(_ code: String) -> Country {
        Country(
            code: code,
            name: code,
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
            organizations: []
        )
    }
}
