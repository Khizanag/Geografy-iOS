import Foundation

struct GeoQuote: Identifiable {
    let id: String
    let text: String
    let author: String
    let countryCode: String?
    let category: QuoteCategory
    var isFavorited: Bool
}

enum QuoteCategory: String, CaseIterable {
    case travel
    case exploration
    case geography
    case country
    case wisdom

    var icon: String {
        switch self {
        case .travel: "airplane"
        case .exploration: "map.fill"
        case .geography: "globe.americas.fill"
        case .country: "flag.fill"
        case .wisdom: "brain.filled.head.profile"
        }
    }

    var displayName: String {
        switch self {
        case .travel: "Travel"
        case .exploration: "Exploration"
        case .geography: "Geography"
        case .country: "Country"
        case .wisdom: "Wisdom"
        }
    }
}
