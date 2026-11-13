import Foundation
@testable import Geografy_Feature_CurrencyConverter
import Testing

@Suite("CurrencyRateStatus")
struct CurrencyRateStatusTests {
    private static let date = Date(timeIntervalSince1970: 1_000)

    @Test("Without a rate it's loading or unavailable")
    func withoutRate() {
        #expect(CurrencyRateStatus(hasRate: false, isLoading: true, hasError: false, lastUpdated: nil) == .loading)
        #expect(CurrencyRateStatus(hasRate: false, isLoading: false, hasError: true, lastUpdated: nil) == .unavailable)
    }

    @Test("A rate after a failed fetch is cached")
    func cachedAfterError() {
        let status = CurrencyRateStatus(hasRate: true, isLoading: false, hasError: true, lastUpdated: Self.date)

        #expect(status == .cached(updated: Self.date))
    }

    @Test("A rate keeps showing while a refresh loads")
    func liveWhileRefreshing() {
        let status = CurrencyRateStatus(hasRate: true, isLoading: true, hasError: false, lastUpdated: Self.date)

        #expect(status == .live(updated: Self.date))
    }
}
