@testable import Geografy_Feature_DistanceCalculator
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
        let recents = RoutePair.recents(
            [Self.route("GB", "US")],
            adding: Self.route("JP", "AU"),
            limit: 5
        )

        #expect(recents.map(\.id) == ["JP-AU", "GB-US"])
    }

    @Test("A repeated route moves to the front in its newest direction")
    func repeatedRouteMoves() {
        let recents = RoutePair.recents(
            [Self.route("GB", "US"), Self.route("JP", "AU")],
            adding: Self.route("AU", "JP"),
            limit: 5
        )

        #expect(recents.map(\.id) == ["AU-JP", "GB-US"])
    }

    @Test("Only the newest routes up to the limit are kept")
    func keepsLimit() {
        let recents = RoutePair.recents(
            [Self.route("GB", "US"), Self.route("JP", "AU"), Self.route("FR", "DE")],
            adding: Self.route("BR", "PT"),
            limit: 3
        )

        #expect(recents.map(\.id) == ["BR-PT", "GB-US", "JP-AU"])
    }
}

// MARK: - Fixtures
private extension RoutePairTests {
    static func route(_ originCode: String, _ destinationCode: String) -> RoutePair {
        RoutePair(originCode: originCode, destinationCode: destinationCode)
    }
}
