import CoreGraphics
import Geografy_Core_Common

/// The part of the map a continent fills when the map is filtered to it, in projected map coordinates.
enum ContinentViewport {
    private typealias Bounds = (minLongitude: Double, maxLongitude: Double, minLatitude: Double, maxLatitude: Double)

    private static let bounds: [String: Bounds] = [
        "Europe": (-25, 40, 34, 72),
        "North America": (-140, -52, 7, 72),
        "Oceania": (112, 178, -50, 10),
        "Asia": (26, 145, -11, 78),
        "Africa": (-20, 55, -35, 38),
        "South America": (-82, -34, -56, 13),
    ]

    /// Nil for a filter that isn't a continent the map zooms to.
    static func rect(for continent: String) -> CGRect? {
        guard let bounds = bounds[continent] else { return nil }
        return MapProjection.boundingRect(
            minLongitude: bounds.minLongitude,
            maxLongitude: bounds.maxLongitude,
            minLatitude: bounds.minLatitude,
            maxLatitude: bounds.maxLatitude
        )
    }
}
