import Foundation

struct CountryProfile: Codable, Identifiable {
    var id: String { countryCode }

    let countryCode: String
    let funFacts: [CountryFunFact]
    let culture: CultureHighlights
    let phrases: [CountryPhrase]
    let geography: GeographyDeepDive
    let timeline: [CountryTimelineEvent]
    let economy: EconomySnapshot
}

// MARK: - Culture Highlights

extension CountryProfile {
    struct CultureHighlights: Codable {
        let traditionalFood: [String]
        let music: String
        let art: String
        let festivals: [String]
    }
}

// MARK: - Geography Deep Dive

extension CountryProfile {
    struct GeographyDeepDive: Codable {
        let climate: String
        let terrain: String
        let naturalWonders: [String]
        let borderingCountries: [String]
    }
}

// MARK: - Economy Snapshot

extension CountryProfile {
    struct EconomySnapshot: Codable {
        let majorIndustries: [String]
        let topExports: [String]
        let gdpRank: Int
    }
}
