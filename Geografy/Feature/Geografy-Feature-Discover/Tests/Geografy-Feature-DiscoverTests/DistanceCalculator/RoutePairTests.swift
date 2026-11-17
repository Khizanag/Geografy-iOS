import Geografy_Core_Common
@testable import Geografy_Feature_Discover
import Testing

@Suite("RoutePair")
struct RoutePairTests {
    @Test("A route matches itself and its reverse, not another route")
    func matches() {
        let route = RoutePair(originCode: "GB", destinationCode: "US")

        #expect(route.matches(RoutePair(originCode: "GB", destinationCode: "US")))
        #expect(route.matches(RoutePair(originCode: "US", destinationCode: "GB")))
        #expect(!route.matches(RoutePair(originCode: "GB", destinationCode: "FR")))
    }

    @Test("A new route goes to the front")
    func newRouteFirst() {
        let recents = Self.recents(limit: 5).adding(Self.route("JP", "AU"), to: [Self.route("GB", "US")])

        #expect(recents.map(\.id) == ["JP-AU", "GB-US"])
    }

    @Test("A repeated route moves to the front in its newest direction")
    func repeatedRouteMoves() {
        let recents = Self.recents(limit: 5).adding(Self.route("AU", "JP"), to: [Self.route("GB", "US"), Self.route("JP", "AU")])

        #expect(recents.map(\.id) == ["AU-JP", "GB-US"])
    }

    @Test("Only the newest routes up to the limit are kept")
    func keepsLimit() {
        let recents = Self.recents(limit: 3).adding(Self.route("BR", "PT"), to: [Self.route("GB", "US"), Self.route("JP", "AU"), Self.route("FR", "DE")])

        #expect(recents.map(\.id) == ["BR-PT", "GB-US", "JP-AU"])
    }
}

// MARK: - Fixtures
private extension RoutePairTests {
    static func recents(limit: Int) -> RecentList<RoutePair> {
        RecentList(storageKey: "routes", limit: limit) { $0.matches($1) }
    }

    static func route(_ originCode: String, _ destinationCode: String) -> RoutePair {
        RoutePair(originCode: originCode, destinationCode: destinationCode)
    }
}
