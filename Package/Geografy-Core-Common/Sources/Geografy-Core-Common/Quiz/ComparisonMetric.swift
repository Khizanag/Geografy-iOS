import Foundation

public enum ComparisonMetric: String, CaseIterable, Identifiable, Codable, Sendable {
    case population = "Population"
    case area = "Area"
    case gdpPerCapita = "GDP per Capita"
    case populationDensity = "Density"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .population: "person.3.fill"
        case .area: "map.fill"
        case .gdpPerCapita: "dollarsign.circle.fill"
        case .populationDensity: "person.crop.square"
        }
    }

    public var questionText: String {
        switch self {
        case .population: "Which country has the largest population?"
        case .area: "Which country has the largest area?"
        case .gdpPerCapita: "Which country has the highest GDP per capita?"
        case .populationDensity: "Which country has the highest population density?"
        }
    }

    public func value(for country: Country) -> Double {
        switch self {
        case .population: Double(country.population)
        case .area: country.area
        case .gdpPerCapita: country.gdpPerCapita ?? 0
        case .populationDensity: country.populationDensity
        }
    }
}
