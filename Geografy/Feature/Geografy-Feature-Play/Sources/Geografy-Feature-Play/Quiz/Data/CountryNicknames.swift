import Geografy_Core_Common

struct CountryNickname: Decodable, Sendable {
    let nickname: String
    let reason: String
}

// MARK: - Data
/// Informal country nicknames, keyed by ISO 3166-1 alpha-2 country code, from `country_nicknames.json`.
enum CountryNicknames {
    static let data = BundledJSON.decode(
        [String: [CountryNickname]].self,
        named: "country_nicknames",
        in: .module
    ) ?? [:]
}
