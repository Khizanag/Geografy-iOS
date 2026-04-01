import Foundation

public enum WorldRecordCategory: String, Sendable, CaseIterable {
    case area
    case population
    case populationDensity
    case neighbors
    case nameLength
    case languages
    case gdpPerCapita

    public var displayName: String {
        switch self {
        case .area: "Land Area"
        case .population: "Population"
        case .populationDensity: "Population Density"
        case .neighbors: "Borders"
        case .nameLength: "Name Length"
        case .languages: "Official Languages"
        case .gdpPerCapita: "GDP per Capita"
        }
    }

    public var icon: String {
        switch self {
        case .area: "map.fill"
        case .population: "person.3.fill"
        case .populationDensity: "person.2.fill"
        case .neighbors: "network"
        case .nameLength: "textformat.abc"
        case .languages: "globe"
        case .gdpPerCapita: "dollarsign.circle.fill"
        }
    }
}
