import Foundation
import Geografy_Core_Common

public enum SearchRow: Identifiable, Hashable {
    case country(Country)
    case capital(country: Country, capitalName: String)
    case organization(Organization)

    public var id: String {
        switch self {
        case .country(let country): "country-\(country.code)"
        case .capital(let country, let capitalName): "capital-\(country.code)-\(capitalName)"
        case .organization(let organization): "org-\(organization.id)"
        }
    }
}

public struct SearchResultSection: Identifiable {
    public let id: String
    public let title: String
    public let icon: String
    public let rows: [SearchRow]

    public init(id: String, title: String, icon: String, rows: [SearchRow]) {
        self.id = id
        self.title = title
        self.icon = icon
        self.rows = rows
    }
}
