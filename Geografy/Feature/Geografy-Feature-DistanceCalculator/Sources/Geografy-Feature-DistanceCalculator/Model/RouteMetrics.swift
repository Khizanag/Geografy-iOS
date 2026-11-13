import Foundation
import Geografy_Core_Service

/// The great-circle route between two capitals and the figures that put its length in perspective.
struct RouteMetrics: Equatable {
    // MARK: - Constants
    static let earthRadiusKm = 6_371.0
    static let earthCircumferenceKm = 40_075.0
    static let kilometersPerMile = 1.609344
    static let lightSpeedKmPerMs = 299.792458
    static let soundSpeedKmh = 1_235.0
    static let walkingSpeedKmh = 5.0
    /// Typical airliner cruise; real block times run a little longer.
    static let cruiseSpeedKmh = 850.0
    /// Taxi, climb and descent, which a straight cruise leaves out.
    static let flightOverheadMinutes = 30.0

    // MARK: - Properties
    let distanceKm: Double
    /// Degrees clockwise from true north, in `0..<360`, at the moment of departure.
    let initialBearing: Double

    // MARK: - Init
    init(distanceKm: Double, initialBearing: Double) {
        self.distanceKm = distanceKm
        self.initialBearing = initialBearing
    }

    init(from origin: CapitalCoordinateService.Coordinate, to destination: CapitalCoordinateService.Coordinate) {
        let latitude1 = origin.latitude * .pi / 180
        let latitude2 = destination.latitude * .pi / 180
        let deltaLatitude = latitude2 - latitude1
        let deltaLongitude = (destination.longitude - origin.longitude) * .pi / 180

        let haversine = sin(deltaLatitude / 2) * sin(deltaLatitude / 2)
            + cos(latitude1) * cos(latitude2) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        let centralAngle = 2 * atan2(sqrt(haversine), sqrt(1 - haversine))

        let bearingY = sin(deltaLongitude) * cos(latitude2)
        let bearingX = cos(latitude1) * sin(latitude2) - sin(latitude1) * cos(latitude2) * cos(deltaLongitude)
        let bearing = atan2(bearingY, bearingX) * 180 / .pi

        self.init(
            distanceKm: Self.earthRadiusKm * centralAngle,
            initialBearing: (bearing + 360).truncatingRemainder(dividingBy: 360)
        )
    }
}

// MARK: - Derived Figures
extension RouteMetrics {
    var distanceMiles: Double {
        distanceKm / Self.kilometersPerMile
    }

    var direction: CompassDirection {
        CompassDirection(bearing: initialBearing)
    }

    /// Rounded to five minutes, since anything finer would be false precision.
    var flightDuration: Duration {
        let minutes = distanceKm / Self.cruiseSpeedKmh * 60 + Self.flightOverheadMinutes
        return .seconds((minutes / 5).rounded() * 5 * 60)
    }

    var soundDuration: Duration {
        .seconds(distanceKm / Self.soundSpeedKmh * 3_600)
    }

    var walkingDuration: Duration {
        .seconds(distanceKm / Self.walkingSpeedKmh * 3_600)
    }

    var lightMilliseconds: Double {
        distanceKm / Self.lightSpeedKmPerMs
    }

    /// The share of the equator this route covers, where 1 is all the way around.
    var earthFraction: Double {
        distanceKm / Self.earthCircumferenceKm
    }
}
