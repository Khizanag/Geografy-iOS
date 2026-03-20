import Foundation

struct Country: Identifiable, Hashable, Codable {
    var id: String { code }

    let code: String
    let name: String
    let capital: String
    let flagEmoji: String
    let continent: Continent
    let area: Double
    let population: Int
    let populationDensity: Double
    let currency: Currency
    let languages: [Language]
    let formOfGovernment: String
    let gdp: Double?
    let gdpPerCapita: Double?
    let gdpPPP: Double?
    let organizations: [String]
}

// MARK: - Continent

extension Country {
    enum Continent: String, Codable, CaseIterable {
        case africa
        case asia
        case europe
        case northAmerica
        case southAmerica
        case oceania
        case antarctica

        var displayName: String {
            switch self {
            case .africa: "Africa"
            case .asia: "Asia"
            case .europe: "Europe"
            case .northAmerica: "North America"
            case .southAmerica: "South America"
            case .oceania: "Oceania"
            case .antarctica: "Antarctica"
            }
        }
    }
}

// MARK: - Currency

extension Country {
    struct Currency: Codable, Hashable {
        let name: String
        let code: String
    }
}

// MARK: - Language

extension Country {
    struct Language: Codable, Hashable {
        let name: String
        let percentage: Double
    }
}
