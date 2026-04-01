import Foundation

public enum FlashcardType: String, CaseIterable, Identifiable, Codable, Sendable {
    case countryToCapital
    case flagToCountry
    case capitalToCountry
    case countryToFlag

    public var id: String { rawValue }
}

// MARK: - Display
extension FlashcardType: SelectableType {
    public var displayName: String {
        switch self {
        case .countryToCapital: "Country -> Capital"
        case .flagToCountry: "Flag -> Country"
        case .capitalToCountry: "Capital -> Country"
        case .countryToFlag: "Country -> Flag"
        }
    }

    public var icon: String {
        switch self {
        case .countryToCapital: "building.columns.fill"
        case .flagToCountry: "flag.fill"
        case .capitalToCountry: "globe"
        case .countryToFlag: "flag.2.crossed.fill"
        }
    }

    public var emoji: String {
        switch self {
        case .countryToCapital: "🏛️"
        case .flagToCountry: "🚩"
        case .capitalToCountry: "🌍"
        case .countryToFlag: "🏴"
        }
    }

    public var description: String {
        switch self {
        case .countryToCapital: "Guess the capital city"
        case .flagToCountry: "Identify country by flag"
        case .capitalToCountry: "Name the country from capital"
        case .countryToFlag: "Match country to its flag"
        }
    }

    public var promptLabel: String {
        switch self {
        case .countryToCapital: "What is the capital?"
        case .flagToCountry: "Which country?"
        case .capitalToCountry: "Which country has this capital?"
        case .countryToFlag: "What does the flag look like?"
        }
    }
}
