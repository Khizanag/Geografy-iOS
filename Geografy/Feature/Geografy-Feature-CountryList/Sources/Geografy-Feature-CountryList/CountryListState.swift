import Geografy_Core_Common
import Observation

/// The countries list's search, sort, grouping, and display choices. It lives outside the screen,
/// so a host that rebuilds the screen, such as Explore switching segments, keeps them.
@Observable
@MainActor
public final class CountryListState {
    // MARK: - Properties
    var searchText = ""
    var debouncedSearchText = ""
    var groupBy: GroupOption = .none
    var sortBy: SortOption = .name
    var sortAscending = true
    var continentFilter: Country.Continent?
    var expandedSections: Set<String> = []
    var hasSeededSections = false
    var showFlag = true
    var showCapital = true
    var showArea = true
    var showPopulation = true

    @ObservationIgnored private var listingMemo: CountryListing?

    // MARK: - Init
    public init() {}

    // MARK: - Listing
    /// The filtered, sorted, and grouped countries, rebuilt only when an input changes.
    func listing(of countries: [Country]) -> CountryListing {
        let query = CountryListing.Query(
            countryCount: countries.count,
            searchText: debouncedSearchText,
            continentFilter: continentFilter,
            sortBy: sortBy,
            sortAscending: sortAscending,
            groupBy: groupBy
        )
        if let listingMemo, listingMemo.query == query {
            return listingMemo
        }
        let listing = CountryListing(countries: countries, query: query)
        listingMemo = listing
        return listing
    }
}

// MARK: - Listing
/// What the countries list shows for one set of choices.
struct CountryListing {
    struct Query: Equatable {
        let countryCount: Int
        let searchText: String
        let continentFilter: Country.Continent?
        let sortBy: SortOption
        let sortAscending: Bool
        let groupBy: GroupOption
    }

    struct Section {
        let key: String
        let countries: [Country]
    }

    let query: Query
    let sorted: [Country]
    let sections: [Section]
    let sectionKeys: [String]

    init(countries: [Country], query: Query) {
        let sorted = Self.filtered(countries, query: query).sorted { lhs, rhs in
            let result = Self.compare(lhs, rhs, by: query.sortBy)
            return query.sortAscending ? result : !result
        }
        let sections = Self.grouped(sorted, by: query.groupBy)
        self.query = query
        self.sorted = sorted
        self.sections = sections
        self.sectionKeys = sections.map(\.key)
    }
}

// MARK: - Helpers
private extension CountryListing {
    static func filtered(_ countries: [Country], query: Query) -> [Country] {
        var countries = countries

        if let continentFilter = query.continentFilter {
            countries = countries.filter { $0.continent == continentFilter }
        }

        if !query.searchText.isEmpty {
            let search = query.searchText.lowercased()
            countries = countries.filter {
                $0.name.lowercased().contains(search) ||
                $0.allCapitals.contains { $0.name.lowercased().contains(search) } ||
                $0.currency.name.lowercased().contains(search)
            }
        }

        return countries
    }

    static func compare(_ lhs: Country, _ rhs: Country, by sortBy: SortOption) -> Bool {
        switch sortBy {
        case .name: lhs.name < rhs.name
        case .population: lhs.population < rhs.population
        case .area: lhs.area < rhs.area
        case .gdp: (lhs.gdp ?? 0) < (rhs.gdp ?? 0)
        }
    }

    static func grouped(_ sorted: [Country], by groupBy: GroupOption) -> [Section] {
        let grouped: [String: [Country]] = switch groupBy {
        case .none:
            [:]
        case .firstLetter:
            Dictionary(grouping: sorted) { String($0.name.prefix(1)).uppercased() }
        case .continent:
            Dictionary(grouping: sorted) { $0.continent.displayName }
        case .government:
            Dictionary(grouping: sorted) { $0.formOfGovernment }
        }

        return grouped
            .map { Section(key: $0.key, countries: $0.value) }
            .sorted(by: \.key)
    }
}
