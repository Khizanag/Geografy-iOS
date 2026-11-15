import CoreGraphics
import Foundation
import Geografy_Core_Common

/// The latitude and longitude grid for a map at a given zoom: which lines to draw, where, and how to name them.
///
/// The spacing follows the zoom, 30° apart on the whole world down to fractions of a degree close in,
/// so neighboring lines always sit a comfortable distance apart on screen.
public enum MapGraticule {
    /// Steps the grid can take, in degrees, widest first.
    static let steps: [Double] = [30, 20, 10, 5, 2, 1, 0.5, 0.25, 0.1]
    /// The least room, in points, between two neighboring meridians.
    static let minimumSpacing: CGFloat = 64
    /// The least room, in points, between two longitude labels; wider than a label, so they never touch.
    static let minimumLabelSpacing: CGFloat = 58
    /// The grid stops short of the poles, where the map ends.
    static let latitudeLimit = 80.0

    /// The Tropics and the polar circles, drawn dashed.
    static let specialLatitudes: [(latitude: Double, name: String)] = [
        (66.5635, "Arctic Circle"),
        (23.4365, "Tropic of Cancer"),
        (-23.4365, "Tropic of Capricorn"),
        (-66.5635, "Antarctic Circle"),
    ]

    /// The finest step that still keeps meridians `minimumSpacing` apart, so the grid is as useful as it can be
    /// without crowding.
    static func step(forScale scale: CGFloat) -> Double {
        let pointsPerDegree = MapProjection.mapWidth * scale / 360
        return steps.last { $0 * pointsPerDegree >= minimumSpacing } ?? steps[0]
    }

    /// How many meridians apart labels go, so they never crowd when the whole world is shown;
    /// counted from 0°, which is always named.
    static func labelStride(forScale scale: CGFloat, step: Double) -> Int {
        let spacing = MapProjection.mapWidth * scale / 360 * step
        return max(1, Int((minimumLabelSpacing / max(spacing, 1)).rounded(.up)))
    }

    /// The multiples of `step` from `lower` to `upper`.
    static func values(from lower: Double, to upper: Double, step: Double) -> [Double] {
        guard lower <= upper, step > 0 else { return [] }
        let first = (lower / step).rounded(.up)
        let last = (upper / step).rounded(.down)
        guard first <= last else { return [] }
        return stride(from: first, through: last, by: 1).map { ($0 * step * 1e6).rounded() / 1e6 }
    }

    /// A longitude folded into -180...180, for naming a meridian on a world map that repeats sideways.
    static func normalizedLongitude(_ longitude: Double) -> Double {
        var folded = (longitude + 180).truncatingRemainder(dividingBy: 360)
        if folded < 0 { folded += 360 }
        return folded - 180
    }

    /// The degrees as written on the grid: whole at wide steps, with as many decimals as the step needs.
    static func degrees(_ value: Double, step: Double, locale: Locale) -> String {
        let decimals = step >= 1 ? 0 : (step >= 0.5 ? 1 : 2)
        return abs(value).formatted(.number.precision(.fractionLength(decimals)).locale(locale))
    }
}

// MARK: - Screen Geometry
extension MapGraticule {
    /// Where a map at `scale` and `offset` puts longitudes and latitudes in a view of `size`.
    struct Placement {
        let scale: CGFloat
        let offset: CGSize
        let size: CGSize

        private var originX: CGFloat { size.width / 2 - MapProjection.mapWidth * scale / 2 + offset.width }
        private var originY: CGFloat { size.height / 2 - MapProjection.mapHeight * scale / 2 + offset.height }

        func x(forLongitude longitude: Double) -> CGFloat {
            originX + CGFloat((longitude + 180) / 360) * MapProjection.mapWidth * scale
        }

        func y(forLatitude latitude: Double) -> CGFloat {
            originY + MapProjection.project(longitude: 0, latitude: latitude).y * scale
        }

        func longitude(atX x: CGFloat) -> Double {
            Double((x - originX) / (MapProjection.mapWidth * scale)) * 360 - 180
        }

        func latitude(atY y: CGFloat) -> Double {
            MapProjection.unproject(point: CGPoint(x: 0, y: (y - originY) / scale)).latitude
        }
    }
}
