import Foundation

public struct Country: Identifiable, Hashable, Codable, Sendable {
    public var id: String { code }

    public let code: String
    public let name: String
    public let capital: String
    public var capitals: [Capital]?
    public let flagEmoji: String
    public let continent: Continent
    public let area: Double
    public let population: Int
    public let populationDensity: Double
    public let currency: Currency
    public let languages: [Language]
    public let formOfGovernment: String
    public let gdp: Double?
    public let gdpPerCapita: Double?
    public let gdpPPP: Double?
    public let organizations: [String]

    public var allCapitals: [Capital] {
        if let caps = capitals, !caps.isEmpty { return caps }
        return [Capital(name: capital, role: nil)]
    }

    public init(
        code: String,
        name: String,
        capital: String,
        capitals: [Capital]? = nil,
        flagEmoji: String,
        continent: Continent,
        area: Double,
        population: Int,
        populationDensity: Double,
        currency: Currency,
        languages: [Language],
        formOfGovernment: String,
        gdp: Double?,
        gdpPerCapita: Double?,
        gdpPPP: Double?,
        organizations: [String]
    ) {
        self.code = code
        self.name = name
        self.capital = capital
        self.capitals = capitals
        self.flagEmoji = flagEmoji
        self.continent = continent
        self.area = area
        self.population = population
        self.populationDensity = populationDensity
        self.currency = currency
        self.languages = languages
        self.formOfGovernment = formOfGovernment
        self.gdp = gdp
        self.gdpPerCapita = gdpPerCapita
        self.gdpPPP = gdpPPP
        self.organizations = organizations
    }
}

// MARK: - Capital
public extension Country {
    struct Capital: Codable, Hashable, Sendable {
        public let name: String
        public let role: String?

        public init(name: String, role: String?) {
            self.name = name
            self.role = role
        }
    }
}

// MARK: - Continent
public extension Country {
    enum Continent: String, Codable, CaseIterable, Sendable {
        case africa
        case asia
        case europe
        case northAmerica
        case southAmerica
        case oceania
        case antarctica

        public var displayName: String {
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
public extension Country {
    struct Currency: Codable, Hashable, Sendable {
        public let name: String
        public let code: String

        public init(name: String, code: String) {
            self.name = name
            self.code = code
        }
    }
}

// MARK: - Language
public extension Country {
    struct Language: Codable, Hashable, Sendable {
        public let name: String
        public let percentage: Double

        public init(name: String, percentage: Double) {
            self.name = name
            self.percentage = percentage
        }
    }
}
