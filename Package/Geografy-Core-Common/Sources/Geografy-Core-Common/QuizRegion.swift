import Foundation

public enum QuizRegion: String, CaseIterable, Identifiable, Codable, Sendable {
    case world
    case africa
    case asia
    case europe
    case northAmerica
    case southAmerica
    case oceania

    public var id: String { rawValue }
}

// MARK: - Properties
extension QuizRegion: RegionSelectable {
    public var displayName: String {
        switch self {
        case .world: "World"
        case .africa: "Africa"
        case .asia: "Asia"
        case .europe: "Europe"
        case .northAmerica: "North America"
        case .southAmerica: "South America"
        case .oceania: "Oceania"
        }
    }

    public var regionIcon: String {
        switch self {
        case .world: "globe"
        case .africa: "globe.europe.africa"
        case .asia: "globe.asia.australia"
        case .europe: "globe.europe.africa"
        case .northAmerica: "globe.americas"
        case .southAmerica: "globe.americas"
        case .oceania: "globe.asia.australia"
        }
    }
}

// MARK: - Filtering
public extension QuizRegion {
    func filter(_ countries: [Country]) -> [Country] {
        switch self {
        case .world:
            countries
        case .africa:
            countries.filter { $0.continent == .africa }
        case .asia:
            countries.filter { $0.continent == .asia }
        case .europe:
            countries.filter { $0.continent == .europe }
        case .northAmerica:
            countries.filter { $0.continent == .northAmerica }
        case .southAmerica:
            countries.filter { $0.continent == .southAmerica }
        case .oceania:
            countries.filter { $0.continent == .oceania }
        }
    }
}
