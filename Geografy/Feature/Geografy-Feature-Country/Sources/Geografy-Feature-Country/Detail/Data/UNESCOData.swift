import Foundation
import Geografy_Core_Common

public enum UNESCOSiteType: String, Decodable, Sendable {
    case cultural = "Cultural"
    case natural = "Natural"
    case mixed = "Mixed"
}

public struct UNESCOSite: Decodable, Sendable {
    public let name: String
    public let type: UNESCOSiteType
    public let yearInscribed: Int
    public let description: String

    public init(name: String, type: UNESCOSiteType, yearInscribed: Int, description: String) {
        self.name = name
        self.type = type
        self.yearInscribed = yearInscribed
        self.description = description
    }
}

// MARK: - Data
/// World Heritage Sites per country, keyed by country code, from `unesco_sites.json`.
public enum UNESCOData: Sendable {
    public static let data = BundledJSON.decode([String: [UNESCOSite]].self, named: "unesco_sites", in: .module) ?? [:]
}
