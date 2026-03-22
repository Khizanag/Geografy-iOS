import Foundation

enum QuizRegion: String, CaseIterable, Identifiable {
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

extension QuizRegion: SelectableType {
    var displayName: String {
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

    var icon: String {
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

    var emoji: String {
        switch self {
        case .world: "🌍"
        case .africa: "🌍"
        case .asia: "🌏"
        case .europe: "🌍"
        case .northAmerica: "🌎"
        case .southAmerica: "🌎"
        case .oceania: "🌏"
        }
    }

    var description: String {
        switch self {
        case .world: "All 197 countries"
        case .africa: "54 countries"
        case .asia: "48 countries"
        case .europe: "44 countries"
        case .northAmerica: "23 countries"
        case .southAmerica: "12 countries"
        case .oceania: "14 countries"
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
