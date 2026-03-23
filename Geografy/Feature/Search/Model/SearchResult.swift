import Foundation

enum SearchRow: Identifiable, Hashable {
    case country(Country)
    case capital(country: Country, capitalName: String)
    case organization(Organization)

    var id: String {
        switch self {
        case .country(let country): "country-\(country.code)"
        case .capital(let country, let capitalName): "capital-\(country.code)-\(capitalName)"
        case .organization(let organization): "org-\(organization.id)"
        }
    }
}

struct SearchResultSection: Identifiable {
    let id: String
    let title: String
    let icon: String
    let rows: [SearchRow]
}
