/// A conversion direction, saved by code so a recent or popular pair can be reopened.
struct CurrencyPair: Identifiable, Codable, Hashable, Sendable {
    let fromCode: String
    let toCode: String

    var id: String { "\(fromCode)-\(toCode)" }

    static let popular = [
        CurrencyPair(fromCode: "USD", toCode: "EUR"),
        CurrencyPair(fromCode: "EUR", toCode: "GBP"),
        CurrencyPair(fromCode: "USD", toCode: "JPY"),
        CurrencyPair(fromCode: "GBP", toCode: "USD"),
        CurrencyPair(fromCode: "USD", toCode: "CNY"),
        CurrencyPair(fromCode: "EUR", toCode: "CHF"),
    ]

    /// The same two currencies, in either direction.
    func matches(_ other: CurrencyPair) -> Bool {
        Set([fromCode, toCode]) == Set([other.fromCode, other.toCode])
    }
}

/// A pair with both currencies looked up, ready to show.
struct CurrencyEntryPair: Identifiable, Hashable, Sendable {
    let from: CurrencyEntry
    let to: CurrencyEntry

    var id: String { pair.id }
    var pair: CurrencyPair { CurrencyPair(fromCode: from.code, toCode: to.code) }

    /// Drops pairs whose currencies aren't in the catalog, keeping the rest in order.
    static func resolve(_ pairs: [CurrencyPair], in currencies: [CurrencyEntry]) -> [CurrencyEntryPair] {
        let byCode = Dictionary(uniqueKeysWithValues: currencies.map { ($0.code, $0) })
        return pairs.compactMap { pair in
            guard let from = byCode[pair.fromCode], let to = byCode[pair.toCode] else { return nil }
            return CurrencyEntryPair(from: from, to: to)
        }
    }
}
