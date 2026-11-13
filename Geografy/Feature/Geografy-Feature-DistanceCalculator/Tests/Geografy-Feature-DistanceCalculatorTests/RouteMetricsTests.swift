import Geografy_Core_Service
@testable import Geografy_Feature_DistanceCalculator
import Testing

@Suite("RouteMetrics")
struct RouteMetricsTests {
    @Test("London to Paris is about 344 km")
    func londonToParis() {
        let metrics = RouteMetrics(from: Self.london, to: Self.paris)

        #expect(abs(metrics.distanceKm - 343.5) < 1)
    }

    @Test("Opposite points on the equator are half the Earth apart")
    func antipodes() {
        let metrics = RouteMetrics(from: Self.point(0, 0), to: Self.point(0, 180))

        #expect(abs(metrics.distanceKm - .pi * RouteMetrics.earthRadiusKm) < 0.001)
    }

    @Test("The same point is no distance at all")
    func samePoint() {
        let metrics = RouteMetrics(from: Self.london, to: Self.london)

        #expect(metrics.distanceKm == 0)
    }

    @Test(
        "Bearings point the way the route sets off",
        arguments: [
            (latitude: 10.0, longitude: 0.0, bearing: 0.0),
            (latitude: 0.0, longitude: 10.0, bearing: 90.0),
            (latitude: -10.0, longitude: 0.0, bearing: 180.0),
            (latitude: 0.0, longitude: -10.0, bearing: 270.0),
        ]
    )
    func bearing(latitude: Double, longitude: Double, bearing: Double) {
        let metrics = RouteMetrics(from: Self.point(0, 0), to: Self.point(latitude, longitude))

        #expect(abs(metrics.initialBearing - bearing) < 0.001)
    }

    @Test("Miles convert from kilometers")
    func miles() {
        let metrics = RouteMetrics(distanceKm: 1_609.344, initialBearing: 0)

        #expect(abs(metrics.distanceMiles - 1_000) < 0.001)
    }

    @Test("Flight time is cruise plus half an hour, to the nearest five minutes")
    func flightDuration() {
        #expect(RouteMetrics(distanceKm: 850, initialBearing: 0).flightDuration == .seconds(90 * 60))
        #expect(RouteMetrics(distanceKm: 870, initialBearing: 0).flightDuration == .seconds(90 * 60))
        #expect(RouteMetrics(distanceKm: 0, initialBearing: 0).flightDuration == .seconds(30 * 60))
    }

    @Test("Perspective figures scale with distance")
    func perspective() {
        let metrics = RouteMetrics(distanceKm: RouteMetrics.earthCircumferenceKm, initialBearing: 0)

        #expect(metrics.earthFraction == 1)
        #expect(abs(metrics.lightMilliseconds - 133.675) < 0.01)
        #expect(metrics.walkingDuration == .seconds(RouteMetrics.earthCircumferenceKm / 5 * 3_600))
    }
}

// MARK: - Fixtures
private extension RouteMetricsTests {
    static let london = point(51.5074, -0.1278)
    static let paris = point(48.8566, 2.3522)

    static func point(_ latitude: Double, _ longitude: Double) -> CapitalCoordinateService.Coordinate {
        CapitalCoordinateService.Coordinate(latitude: latitude, longitude: longitude)
    }
}
