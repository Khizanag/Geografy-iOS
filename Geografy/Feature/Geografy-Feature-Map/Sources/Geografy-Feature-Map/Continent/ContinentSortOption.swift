import Geografy_Core_Common

/// How a continent's countries are listed.
enum ContinentSortOption: String, CaseIterable {
    case name = "Name"
    case population = "Population"
    case area = "Area"
    case gdp = "GDP"

    var icon: String {
        switch self {
        case .name: "textformat"
        case .population: "person.3"
        case .area: "map"
        case .gdp: "chart.bar"
        }
    }

    /// Names A to Z; every other option largest first, with a country missing GDP data last.
    func sorted(_ countries: [Country]) -> [Country] {
        countries.sorted { lhs, rhs in
            switch self {
            case .name: lhs.name < rhs.name
            case .population: lhs.population > rhs.population
            case .area: lhs.area > rhs.area
            case .gdp: (lhs.gdpPerCapita ?? 0) > (rhs.gdpPerCapita ?? 0)
            }
        }
    }
}
