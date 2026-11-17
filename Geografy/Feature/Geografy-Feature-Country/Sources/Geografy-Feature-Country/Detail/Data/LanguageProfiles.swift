import Geografy_Core_Common

struct LanguageProfile: Decodable, Identifiable, Sendable {
    let id: String
    let name: String
    let nativeName: String
    /// Native speakers, in millions.
    let speakerCount: Int
    /// Countries where the language is official.
    let countries: [String]
    let family: String
    let script: String
    let funFact: String
}

// MARK: - Data
enum LanguageProfiles {
    static func official(in countryCode: String) -> [LanguageProfile] {
        all
            .filter { $0.countries.contains(countryCode) }
            .sorted { $0.speakerCount > $1.speakerCount }
    }

    /// Every language with a profile, from `language_profiles.json`.
    static let all = BundledJSON.decode([LanguageProfile].self, named: "language_profiles", in: .module) ?? []
}
