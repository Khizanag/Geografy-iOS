import Foundation

public struct CountryProfile: Codable, Identifiable {
    public var id: String { countryCode }

    public let countryCode: String
    public let funFacts: [CountryFunFact]
    public let culture: CultureHighlights
    public let phrases: [CountryPhrase]
    public let geography: GeographyDeepDive
    public let timeline: [CountryTimelineEvent]
    public let economy: EconomySnapshot
}

// MARK: - Culture Highlights
extension CountryProfile {
    public struct CultureHighlights: Codable {
        public let traditionalFood: [String]
        public let music: String
        public let art: String
        public let festivals: [String]
    }
}

// MARK: - Geography Deep Dive
extension CountryProfile {
    public struct GeographyDeepDive: Codable {
        public let climate: String
        public let terrain: String
        public let naturalWonders: [String]
        public let borderingCountries: [String]
    }
}

// MARK: - Economy Snapshot
extension CountryProfile {
    public struct EconomySnapshot: Codable {
        public let majorIndustries: [String]
        public let topExports: [String]
        public let gdpRank: Int
    }
}
