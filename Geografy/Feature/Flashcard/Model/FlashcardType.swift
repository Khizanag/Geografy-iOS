import Foundation

enum FlashcardType: String, CaseIterable, Identifiable, Codable {
    case countryToCapital
    case flagToCountry
    case capitalToCountry
    case countryToFlag

    var id: String { rawValue }
}

// MARK: - Display

extension FlashcardType: SelectableType {
    var displayName: String {
        switch self {
        case .countryToCapital: "Country -> Capital"
        case .flagToCountry: "Flag -> Country"
        case .capitalToCountry: "Capital -> Country"
        case .countryToFlag: "Country -> Flag"
        }
    }

    var icon: String {
        switch self {
        case .countryToCapital: "building.columns.fill"
        case .flagToCountry: "flag.fill"
        case .capitalToCountry: "globe"
        case .countryToFlag: "flag.2.crossed.fill"
        }
    }

    var emoji: String {
        switch self {
        case .countryToCapital: "🏛️"
        case .flagToCountry: "🚩"
        case .capitalToCountry: "🌍"
        case .countryToFlag: "🏴"
        }
    }

    var promptLabel: String {
        switch self {
        case .countryToCapital: "What is the capital?"
        case .flagToCountry: "Which country?"
        case .capitalToCountry: "Which country has this capital?"
        case .countryToFlag: "What does the flag look like?"
        }
    }
}
