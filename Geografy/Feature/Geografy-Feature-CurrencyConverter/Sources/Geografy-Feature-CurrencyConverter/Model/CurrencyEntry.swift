import Geografy_Core_Common

/// A currency and the countries that use it, with one flag to stand for it.
struct CurrencyEntry: Identifiable, Hashable, Sendable {
    let code: String
    let name: String
    let flagCode: String
    /// Most populous first.
    let countryNames: [String]

    var id: String { code }

    /// "Japan" for a national currency, "26 countries" for a shared one.
    var usageSummary: String {
        if countryNames.count == 1, let only = countryNames.first {
            return only
        }
        return "\(countryNames.count) countries"
    }
}

enum CurrencyCatalog {
    /// The currencies most people convert between, in the order they're offered.
    static let majorCodes = ["USD", "EUR", "GBP", "JPY", "CNY", "CHF", "CAD", "AUD"]

    /// One entry per currency the countries use, sorted by code.
    static func entries(from countries: [Country]) -> [CurrencyEntry] {
        let users = Dictionary(grouping: countries.filter { !$0.currency.code.isEmpty }, by: \.currency.code)
        return users.compactMap { code, countries -> CurrencyEntry? in
            let byPopulation = countries.sorted { $0.population > $1.population }
            guard let largest = byPopulation.first else { return nil }
            return CurrencyEntry(
                code: code,
                name: largest.currency.name,
                flagCode: flagCode(for: code, countryCodes: byPopulation.map(\.code)),
                countryNames: byPopulation.map(\.name)
            )
        }
        .sorted { $0.code < $1.code }
    }

    /// Major currencies to offer for the other side, skipping the one already picked.
    static func major(in currencies: [CurrencyEntry], excluding code: String?, limit: Int = 5) -> [CurrencyEntry] {
        let byCode = Dictionary(uniqueKeysWithValues: currencies.map { ($0.code, $0) })
        return majorCodes
            .filter { $0 != code }
            .compactMap { byCode[$0] }
            .prefix(limit)
            .map(\.self)
    }

    /// ISO 4217 codes start with the issuer's country code (USD → US, CHF → CH), so that flag wins.
    /// The euro gets the EU flag; other shared currencies take their most populous user's.
    static func flagCode(for currencyCode: String, countryCodes: [String]) -> String {
        if currencyCode == "EUR" {
            return "EU"
        }
        let issuer = String(currencyCode.prefix(2))
        if countryCodes.contains(issuer) {
            return issuer
        }
        return countryCodes.first ?? issuer
    }
}
