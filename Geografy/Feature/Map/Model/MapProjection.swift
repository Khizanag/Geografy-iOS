import CoreGraphics
import Foundation

enum MapProjection {
    static let mapWidth: CGFloat = 2048
    static let mapHeight: CGFloat = 2048
}

// MARK: - Projection
extension MapProjection {
    static func project(longitude: Double, latitude: Double) -> CGPoint {
        let clampedLatitude = min(max(latitude, -85), 85)
        let x = (longitude + 180) / 360 * Double(mapWidth)
        let latRad = clampedLatitude * .pi / 180
        let y = (1 - log(tan(latRad) + 1 / cos(latRad)) / .pi) / 2 * Double(mapHeight)
        return CGPoint(x: x, y: y)
    }

    static func unproject(point: CGPoint) -> (longitude: Double, latitude: Double) {
        let longitude = Double(point.x) / Double(mapWidth) * 360 - 180
        let n = .pi - 2 * .pi * Double(point.y) / Double(mapHeight)
        let latitude = 180 / .pi * atan(0.5 * (exp(n) - exp(-n)))
        return (longitude, latitude)
    }
}
