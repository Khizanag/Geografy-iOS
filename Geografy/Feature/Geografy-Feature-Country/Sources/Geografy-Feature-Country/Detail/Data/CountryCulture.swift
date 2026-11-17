import Geografy_Core_Common

/// Culture facts per country, keyed by country code, from `country_culture.json`.
enum CountryCulture {
    static let data = BundledJSON.decode(
        [String: CountryCultureEntry].self,
        named: "country_culture",
        in: .module
    ) ?? [:]
}
