import Foundation
import SwiftData

@Model
public final class CollectionItem {
    // MARK: - Properties
    public var itemID: String
    public var itemType: String
    public var collectionName: String
    public var addedAt: Date

    // MARK: - Init
    public init(
        itemID: String,
        itemType: ItemType,
        collectionName: String,
        addedAt: Date = .now
    ) {
        self.itemID = itemID
        self.itemType = itemType.rawValue
        self.collectionName = collectionName
        self.addedAt = addedAt
    }

    public var type: ItemType {
        ItemType(rawValue: itemType) ?? .country
    }
}

// MARK: - ItemType
public extension CollectionItem {
    enum ItemType: String, CaseIterable, Codable, Sendable {
        case country
        case ocean
        case language
        case organization

        public var displayName: String {
            switch self {
            case .country: "Country"
            case .ocean: "Ocean"
            case .language: "Language"
            case .organization: "Organization"
            }
        }

        public var icon: String {
            switch self {
            case .country: "globe.americas.fill"
            case .ocean: "water.waves"
            case .language: "character.book.closed.fill"
            case .organization: "building.2.fill"
            }
        }

        public var pluralName: String {
            switch self {
            case .country: "Countries"
            case .ocean: "Oceans"
            case .language: "Languages"
            case .organization: "Organizations"
            }
        }
    }
}
