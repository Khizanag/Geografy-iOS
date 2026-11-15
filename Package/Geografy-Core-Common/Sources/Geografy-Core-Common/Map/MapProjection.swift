import CoreGraphics
import Foundation

/// How the round Earth is laid flat on the maps. Every map draws in a square of `mapWidth` by `mapHeight`
/// points with the equator across its middle; the projection decides where each place lands in it.
public enum MapProjection {
    public static let mapWidth: CGFloat = 2_048
    public static let mapHeight: CGFloat = 2_048

    /// The projection chosen in Settings.
    public static var current: MapProjectionKind {
        UserDefaults.standard.string(forKey: MapPreferences.projectionKey)
            .flatMap(MapProjectionKind.init(rawValue:)) ?? .mercator
    }
}

// MARK: - Kind
/// A way of flattening the Earth.
public enum MapProjectionKind: String, CaseIterable, Identifiable, Sendable {
    /// Straight meridians and parallels at right angles, true to shape locally, as on navigation maps.
    /// Sizes swell toward the poles, so Greenland looks as large as Africa.
    case mercator
    /// Curved meridians and true areas, as in an atlas: every country at its real size.
    case equalEarth

    public var id: String { rawValue }
}

// MARK: - Projection
public extension MapProjection {
    static func project(longitude: Double, latitude: Double) -> CGPoint {
        project(longitude: longitude, latitude: latitude, kind: current)
    }

    static func unproject(point: CGPoint) -> (longitude: Double, latitude: Double) {
        unproject(point: point, kind: current)
    }

    static func project(longitude: Double, latitude: Double, kind: MapProjectionKind) -> CGPoint {
        switch kind {
        case .mercator: Mercator.project(longitude: longitude, latitude: latitude)
        case .equalEarth: EqualEarth.project(longitude: longitude, latitude: latitude)
        }
    }

    static func unproject(point: CGPoint, kind: MapProjectionKind) -> (longitude: Double, latitude: Double) {
        switch kind {
        case .mercator: Mercator.unproject(point: point)
        case .equalEarth: EqualEarth.unproject(point: point)
        }
    }

    /// The map area a span of longitudes and latitudes covers. Its edges are sampled, not just its corners,
    /// since meridians curve in some projections and a box's widest point can lie mid-edge.
    static func boundingRect(
        minLongitude: Double,
        maxLongitude: Double,
        minLatitude: Double,
        maxLatitude: Double,
        kind: MapProjectionKind = current
    ) -> CGRect {
        let samples = 8
        var points: [CGPoint] = []
        for index in 0...samples {
            let fraction = Double(index) / Double(samples)
            let longitude = minLongitude + (maxLongitude - minLongitude) * fraction
            let latitude = minLatitude + (maxLatitude - minLatitude) * fraction
            points.append(project(longitude: longitude, latitude: minLatitude, kind: kind))
            points.append(project(longitude: longitude, latitude: maxLatitude, kind: kind))
            points.append(project(longitude: minLongitude, latitude: latitude, kind: kind))
            points.append(project(longitude: maxLongitude, latitude: latitude, kind: kind))
        }
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else {
            return .zero
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// The edge of the whole Earth on the map, for projections whose world isn't a rectangle; nil when it is.
    static func worldOutline(kind: MapProjectionKind = current) -> [CGPoint]? {
        guard kind == .equalEarth else { return nil }
        let east = stride(from: -90.0, through: 90, by: 2).map { project(longitude: 180, latitude: $0, kind: kind) }
        let west = stride(from: 90.0, through: -90, by: -2).map { project(longitude: -180, latitude: $0, kind: kind) }
        return east + west
    }
}

// MARK: - Mercator
private enum Mercator {
    static func project(longitude: Double, latitude: Double) -> CGPoint {
        let clampedLatitude = min(max(latitude, -85), 85)
        let x = (longitude + 180) / 360 * Double(MapProjection.mapWidth)
        let latRad = clampedLatitude * .pi / 180
        let y = (1 - log(tan(latRad) + 1 / cos(latRad)) / .pi) / 2 * Double(MapProjection.mapHeight)
        return CGPoint(x: x, y: y)
    }

    static func unproject(point: CGPoint) -> (longitude: Double, latitude: Double) {
        let longitude = Double(point.x) / Double(MapProjection.mapWidth) * 360 - 180
        let n = .pi - 2 * .pi * Double(point.y) / Double(MapProjection.mapHeight)
        let latitude = 180 / .pi * atan(0.5 * (exp(n) - exp(-n)))
        return (longitude, latitude)
    }
}

// MARK: - Equal Earth
/// Šavrič, Patterson, and Jenny's Equal Earth (2018): equal-area, with straight parallels and gently
/// curved meridians. Scaled so the equator spans the map's width, as on Mercator.
private enum EqualEarth {
    static let a1 = 1.340264
    static let a2 = -0.081106
    static let a3 = 0.000893
    static let a4 = 0.003796
    static let m = sqrt(3) / 2
    /// Half the equator's length in the projection's own units: π / (m · a1).
    static let halfWidth = Double.pi / (m * a1)

    static func project(longitude: Double, latitude: Double) -> CGPoint {
        let lambda = longitude * .pi / 180
        let theta = asin(m * sin(min(max(latitude, -90), 90) * .pi / 180))
        let theta2 = theta * theta
        let theta6 = theta2 * theta2 * theta2
        let x = lambda * cos(theta) / (m * (a1 + 3 * a2 * theta2 + theta6 * (7 * a3 + 9 * a4 * theta2)))
        let y = theta * (a1 + a2 * theta2 + theta6 * (a3 + a4 * theta2))
        return CGPoint(x: mapX(x), y: mapY(y))
    }

    static func unproject(point: CGPoint) -> (longitude: Double, latitude: Double) {
        let x = (Double(point.x) / Double(MapProjection.mapWidth) * 2 - 1) * halfWidth
        let poleY = polarY
        let halfMapWidth = Double(MapProjection.mapWidth) / 2
        let rawY = (Double(MapProjection.mapHeight) / 2 - Double(point.y)) / halfMapWidth * halfWidth
        let y = min(max(rawY, -poleY), poleY)

        var theta = y
        for _ in 0..<12 {
            let theta2 = theta * theta
            let theta6 = theta2 * theta2 * theta2
            let value = theta * (a1 + a2 * theta2 + theta6 * (a3 + a4 * theta2)) - y
            let slope = a1 + 3 * a2 * theta2 + theta6 * (7 * a3 + 9 * a4 * theta2)
            let delta = value / slope
            theta -= delta
            if abs(delta) < 1e-12 { break }
        }
        let theta2 = theta * theta
        let theta6 = theta2 * theta2 * theta2
        let slope = a1 + 3 * a2 * theta2 + theta6 * (7 * a3 + 9 * a4 * theta2)
        let lambda = m * x * slope / max(cos(theta), 1e-9)
        let latitude = asin(min(max(sin(theta) / m, -1), 1)) * 180 / .pi
        let longitude = min(max(lambda * 180 / .pi, -180), 180)
        return (longitude, latitude)
    }

    /// y at the poles, where the projection's top and bottom edges are.
    static var polarY: Double {
        let theta = Double.pi / 3
        let theta2 = theta * theta
        let theta6 = theta2 * theta2 * theta2
        return theta * (a1 + a2 * theta2 + theta6 * (a3 + a4 * theta2))
    }

    static func mapX(_ x: Double) -> Double {
        (x / halfWidth + 1) / 2 * Double(MapProjection.mapWidth)
    }

    /// The same scale as x, so shapes keep their proportions, with the equator across the map's middle.
    static func mapY(_ y: Double) -> Double {
        Double(MapProjection.mapHeight) / 2 - y / halfWidth * Double(MapProjection.mapWidth) / 2
    }
}
