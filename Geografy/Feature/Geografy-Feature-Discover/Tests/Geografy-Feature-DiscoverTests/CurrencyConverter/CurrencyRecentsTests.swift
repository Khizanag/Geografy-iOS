import Foundation
@testable import Geografy_Feature_Discover
import Testing

@Suite("CurrencyRecents")
struct CurrencyRecentsTests {
    private static let usdEur = CurrencyPair(fromCode: "USD", toCode: "EUR")
    private static let eurUsd = CurrencyPair(fromCode: "EUR", toCode: "USD")
    private static let gbpJpy = CurrencyPair(fromCode: "GBP", toCode: "JPY")

    @Test("A new pair goes first")
    func insertsFirst() {
        let recents = CurrencyRecents.list().adding(Self.gbpJpy, to: [Self.usdEur])

        #expect(recents == [Self.gbpJpy, Self.usdEur])
    }

    @Test("The same currencies in the other direction replace the older entry")
    func replacesReversedPair() {
        let recents = CurrencyRecents.list().adding(Self.eurUsd, to: [Self.gbpJpy, Self.usdEur])

        #expect(recents == [Self.eurUsd, Self.gbpJpy])
    }

    @Test("The list keeps only the newest pairs")
    func keepsLimit() {
        let codes = ["AUD", "CAD", "CHF", "CNY", "GBP", "JPY"]
        let list = CurrencyRecents.list(limit: 3)
        let recents = codes.reduce(into: [CurrencyPair]()) { recents, code in
            recents = list.adding(CurrencyPair(fromCode: "USD", toCode: code), to: recents)
        }

        #expect(recents.map(\.toCode) == ["JPY", "GBP", "CNY"])
    }

    @Test("Saved pairs load back in order")
    func persists() throws {
        let suiteName = "CurrencyRecentsTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let list = CurrencyRecents.list(defaults: defaults)
        #expect(list.load().isEmpty)

        list.save([Self.gbpJpy, Self.usdEur])

        #expect(list.load() == [Self.gbpJpy, Self.usdEur])
    }

    @Test("Resolving drops pairs whose currencies aren't known")
    func resolvesKnownPairs() {
        let currencies = CurrencyCatalog.entries(from: CurrencyCatalogTests.countries)

        let resolved = CurrencyEntryPair.resolve([Self.usdEur, Self.gbpJpy], in: currencies)

        #expect(resolved.map(\.pair) == [Self.usdEur])
        #expect(resolved.first?.from.flagCode == "US")
        #expect(resolved.first?.to.flagCode == "EU")
    }
}
