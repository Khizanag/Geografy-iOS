import Geografy_Core_Common
@testable import Geografy_Feature_Country
import Testing

@MainActor
@Suite("CountryListing")
struct CountryListingTests {
    @Test("Search matches names, capitals, and currencies")
    func searchMatchesNameCapitalAndCurrency() {
        #expect(Self.listing(searchText: "fra").sorted.map(\.code) == ["FR"])
        #expect(Self.listing(searchText: "tokyo").sorted.map(\.code) == ["JP"])
        #expect(Self.listing(searchText: "yen").sorted.map(\.code) == ["JP"])
    }

    @Test("The continent filter keeps only that continent")
    func continentFilter() {
        let listing = Self.listing(continentFilter: .europe)

        #expect(listing.sorted.map(\.code) == ["FR", "DE"])
    }

    @Test("Sorting follows the field and direction")
    func sorting() {
        #expect(Self.listing(sortBy: .population, sortAscending: false).sorted.map(\.code) == ["JP", "DE", "FR"])
        #expect(Self.listing(sortBy: .name).sorted.map(\.code) == ["FR", "DE", "JP"])
    }

    @Test("Grouping by continent gives sorted section keys")
    func groupingByContinent() {
        let listing = Self.listing(groupBy: .continent)
        let expectedKeys = [Country.Continent.asia.displayName, Country.Continent.europe.displayName].sorted()

        #expect(listing.sectionKeys == expectedKeys)
        #expect(listing.sections.map(\.countries.count).reduce(0, +) == 3)
    }

    @Test("No grouping gives no sections")
    func noGrouping() {
        #expect(Self.listing().sections.isEmpty)
    }

    @Test("The state rebuilds the listing only when an input changes")
    func stateReusesListing() {
        let state = CountryListState()
        let first = state.listing(of: Self.countries)
        #expect(state.listing(of: Self.countries).query == first.query)

        state.sortAscending = false

        #expect(state.listing(of: Self.countries).sorted.map(\.code) == ["JP", "DE", "FR"])
    }
}

// MARK: - Fixtures
private extension CountryListingTests {
    static let countries = [
        makeCountry("FR", "France", capital: "Paris", currency: "Euro", continent: .europe, population: 68),
        makeCountry("JP", "Japan", capital: "Tokyo", currency: "Yen", continent: .asia, population: 125),
        makeCountry("DE", "Germany", capital: "Berlin", currency: "Euro", continent: .europe, population: 84),
    ]

    static func listing(
        searchText: String = "",
        continentFilter: Country.Continent? = nil,
        sortBy: SortOption = .name,
        sortAscending: Bool = true,
        groupBy: GroupOption = .none
    ) -> CountryListing {
        let query = CountryListing.Query(
            countryCount: countries.count,
            searchText: searchText,
            continentFilter: continentFilter,
            sortBy: sortBy,
            sortAscending: sortAscending,
            groupBy: groupBy
        )
        return CountryListing(countries: countries, query: query)
    }

    static func makeCountry(
        _ code: String,
        _ name: String,
        capital: String,
        currency: String,
        continent: Country.Continent,
        population: Int
    ) -> Country {
        Country(
            code: code,
            name: name,
            capital: capital,
            flagEmoji: "",
            continent: continent,
            area: 1,
            population: population,
            populationDensity: 1,
            currency: Country.Currency(name: currency, code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}
