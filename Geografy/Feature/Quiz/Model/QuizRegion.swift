import Foundation
import GeografyCore

enum QuizRegion: String, CaseIterable, Identifiable, Codable {
    case world
    case africa
    case asia
    case europe
    case northAmerica
    case southAmerica
    case oceania

    var id: String { rawValue }
}

// MARK: - Properties
extension QuizRegion: RegionSelectable {
    var displayName: String {
        switch self {
        case .world: "World"
        case .africa: "Africa"
        case .asia: "Asia"
        case .europe: "Europe"
        case .northAmerica: "N. America"
        case .southAmerica: "S. America"
        case .oceania: "Oceania"
        }
    }

    var regionIcon: String {
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
extension QuizRegion {
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
