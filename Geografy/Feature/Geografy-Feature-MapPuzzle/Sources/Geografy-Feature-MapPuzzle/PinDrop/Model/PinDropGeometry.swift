import CoreGraphics
import Foundation
import Geografy_Core_Common

/// A point on the Earth, in degrees.
struct GeoCoordinate: Equatable, Sendable {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// The place under a point of the projected map.
    init(mapPoint: CGPoint) {
        let (longitude, latitude) = MapProjection.unproject(point: mapPoint)
        self.init(latitude: latitude, longitude: longitude)
    }
}

/// Distances between a dropped pin and a country, measured on the globe.
enum PinDropGeometry {
    static let earthRadiusKilometers = 6_371.0

    /// The great-circle distance between two places.
    static func distanceKilometers(from start: GeoCoordinate, to end: GeoCoordinate) -> Double {
        let startLatitude = start.latitude * .pi / 180
        let endLatitude = end.latitude * .pi / 180
        let latitudeDelta = endLatitude - startLatitude
        let longitudeDelta = (end.longitude - start.longitude) * .pi / 180

        let haversine = sin(latitudeDelta / 2) * sin(latitudeDelta / 2)
            + cos(startLatitude) * cos(endLatitude) * sin(longitudeDelta / 2) * sin(longitudeDelta / 2)
        return 2 * earthRadiusKilometers * atan2(sqrt(haversine), sqrt(1 - haversine))
    }

    /// The point of the outlines closest to `point`, both in map coordinates.
    /// The map is conformal, so the closest point on it is the closest on the ground for any sensible miss.
    static func nearestPoint(to point: CGPoint, on outlines: [CGPath]) -> CGPoint? {
        var nearest: CGPoint?
        var nearestDistance = CGFloat.infinity
        for outline in outlines {
            for (start, end) in segments(of: outline) {
                let candidate = closestPoint(to: point, onSegmentFrom: start, to: end)
                let distance = hypot(candidate.x - point.x, candidate.y - point.y)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearest = candidate
                }
            }
        }
        return nearest
    }

    /// A circle's radius with the country's area: how big it is, whatever its shape.
    static func equivalentRadiusKilometers(forArea area: Double) -> Double {
        sqrt(max(area, 0) / .pi)
    }
}

// MARK: - Segments
private extension PinDropGeometry {
    static func segments(of path: CGPath) -> [(CGPoint, CGPoint)] {
        var segments: [(CGPoint, CGPoint)] = []
        var subpathStart: CGPoint?
        var current: CGPoint?
        path.applyWithBlock { element in
            let points = element.pointee.points
            switch element.pointee.type {
            case .moveToPoint:
                subpathStart = points[0]
                current = points[0]
            case .addLineToPoint:
                if let current { segments.append((current, points[0])) }
                current = points[0]
            case .addQuadCurveToPoint:
                if let current { segments.append((current, points[1])) }
                current = points[1]
            case .addCurveToPoint:
                if let current { segments.append((current, points[2])) }
                current = points[2]
            case .closeSubpath:
                if let current, let subpathStart { segments.append((current, subpathStart)) }
                current = subpathStart
            @unknown default:
                break
            }
        }
        return segments
    }

    static func closestPoint(to point: CGPoint, onSegmentFrom start: CGPoint, to end: CGPoint) -> CGPoint {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let lengthSquared = deltaX * deltaX + deltaY * deltaY
        guard lengthSquared > 0 else { return start }
        let projection = ((point.x - start.x) * deltaX + (point.y - start.y) * deltaY) / lengthSquared
        let clamped = min(max(projection, 0), 1)
        return CGPoint(x: start.x + clamped * deltaX, y: start.y + clamped * deltaY)
    }
}
