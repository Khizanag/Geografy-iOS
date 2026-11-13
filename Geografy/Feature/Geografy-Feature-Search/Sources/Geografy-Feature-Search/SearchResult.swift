import Foundation
import Geografy_Core_Common

public enum SearchRow: Identifiable, Hashable, Sendable {
    case country(Country)
    case capital(country: Country, capitalName: String)
    case organization(Organization)

    public var id: String {
        switch self {
        case .country(let country): "country-\(country.code)"
        case let .capital(country, capitalName): "capital-\(country.code)-\(capitalName)"
        case .organization(let organization): "org-\(organization.id)"
        }
    }
}

public struct SearchResultSection: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let rows: [SearchRow]
}

/// What one query found: an optional standout match, then the rest grouped by kind.
public struct SearchResults: Equatable, Sendable {
    public let topHit: SearchRow?
    public let sections: [SearchResultSection]

    public static let empty = SearchResults(topHit: nil, sections: [])

    public var isEmpty: Bool {
        topHit == nil && sections.isEmpty
    }
}

/// The kinds of result a person can narrow the search to.
public enum SearchScope: String, CaseIterable, Identifiable, Sendable {
    case all
    case countries
    case capitals
    case organizations

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .all: "All"
        case .countries: "Countries"
        case .capitals: "Capitals"
        // Short, so four tabs fit across a phone without truncating.
        case .organizations: "Orgs"
        }
    }
}

// MARK: - Display
extension SearchRow {
    var title: String {
        switch self {
        case .country(let country): country.name
        case .capital(_, let capitalName): capitalName
        case .organization(let organization): organization.fullName
        }
    }

    var subtitle: String {
        switch self {
        case .country(let country): country.continent.displayName
        case .capital(let country, _): "Capital of \(country.name)"
        case .organization(let organization): organization.displayName
        }
    }

    var kindTitle: String {
        switch self {
        case .country: "Country"
        case .capital: "Capital"
        case .organization: "Organization"
        }
    }
}
