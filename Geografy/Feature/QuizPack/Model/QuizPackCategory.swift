import SwiftUI

enum QuizPackCategory: String, CaseIterable, Identifiable {
    case capitals
    case flags
    case population
    case geography
    case currency
    case government
    case organizations

    var id: String { rawValue }
}

// MARK: - Display

extension QuizPackCategory {
    var displayName: String {
        switch self {
        case .capitals: "Capitals"
        case .flags: "Flags"
        case .population: "Population"
        case .geography: "Geography"
        case .currency: "Currency"
        case .government: "Government"
        case .organizations: "Organizations"
        }
    }

    var icon: String {
        switch self {
        case .capitals: "building.columns.fill"
        case .flags: "flag.fill"
        case .population: "person.3.fill"
        case .geography: "map.fill"
        case .currency: "banknote.fill"
        case .government: "scroll.fill"
        case .organizations: "globe"
        }
    }

    var emoji: String {
        switch self {
        case .capitals: "🏛️"
        case .flags: "🚩"
        case .population: "👥"
        case .geography: "🗺️"
        case .currency: "💰"
        case .government: "⚖️"
        case .organizations: "🌐"
        }
    }

    var gradientColors: (Color, Color) {
        switch self {
        case .capitals:
            (Color(hex: "1A237E"), Color(hex: "3949AB"))
        case .flags:
            (Color(hex: "B71C1C"), Color(hex: "D32F2F"))
        case .population:
            (Color(hex: "004D40"), Color(hex: "00695C"))
        case .geography:
            (Color(hex: "1B5E20"), Color(hex: "388E3C"))
        case .currency:
            (Color(hex: "E65100"), Color(hex: "FF8F00"))
        case .government:
            (Color(hex: "4A148C"), Color(hex: "7B1FA2"))
        case .organizations:
            (Color(hex: "01579B"), Color(hex: "0277BD"))
        }
    }
}
