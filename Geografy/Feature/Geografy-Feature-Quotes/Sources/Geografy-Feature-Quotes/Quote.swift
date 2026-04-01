import Foundation
import Geografy_Core_Common

public struct Quote: Identifiable {
    public let id: String
    public let text: String
    public let author: String
    public let countryCode: String?
    public let category: QuoteCategory
    public var isFavorited: Bool

    public init(id: String, text: String, author: String, countryCode: String?, category: QuoteCategory, isFavorited: Bool = false) {
        self.id = id
        self.text = text
        self.author = author
        self.countryCode = countryCode
        self.category = category
        self.isFavorited = isFavorited
    }
}

public enum QuoteCategory: String, Sendable, CaseIterable {
    case travel
    case exploration
    case geography
    case country
    case wisdom

    public var icon: String {
        switch self {
        case .travel: "airplane"
        case .exploration: "map.fill"
        case .geography: "globe.americas.fill"
        case .country: "flag.fill"
        case .wisdom: "brain.filled.head.profile"
        }
    }

    public var displayName: String {
        switch self {
        case .travel: "Travel"
        case .exploration: "Exploration"
        case .geography: "Geography"
        case .country: "Country"
        case .wisdom: "Wisdom"
        }
    }
}
