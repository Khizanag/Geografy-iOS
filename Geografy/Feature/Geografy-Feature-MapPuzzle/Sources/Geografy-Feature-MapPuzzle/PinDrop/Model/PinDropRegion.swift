import CoreGraphics
import Geografy_Core_Common

/// The part of the world a Pin Drop game is played on.
public enum PinDropRegion: String, CaseIterable, Identifiable, Sendable {
    case world
    case europe
    case asia
    case africa
    case northAmerica
    case southAmerica
    case oceania

    public var id: String { rawValue }

    /// The continent whose countries are asked; nil for the whole world.
    public var continent: Country.Continent? {
        switch self {
        case .world: nil
        case .europe: .europe
        case .asia: .asia
        case .africa: .africa
        case .northAmerica: .northAmerica
        case .southAmerica: .southAmerica
        case .oceania: .oceania
        }
    }

    public var displayName: String {
        continent?.displayName ?? "World"
    }

    /// What the camera frames, leaving out far territories that would shrink the continent:
    /// French Guiana for Europe, Hawaii for Oceania.
    var bounds: GeoBounds {
        switch self {
        case .world: GeoBounds(minLongitude: -170, maxLongitude: 180, minLatitude: -56, maxLatitude: 76)
        case .europe: GeoBounds(minLongitude: -25, maxLongitude: 45, minLatitude: 34, maxLatitude: 71)
        case .asia: GeoBounds(minLongitude: 26, maxLongitude: 146, minLatitude: -11, maxLatitude: 56)
        case .africa: GeoBounds(minLongitude: -20, maxLongitude: 55, minLatitude: -36, maxLatitude: 38)
        case .northAmerica: GeoBounds(minLongitude: -140, maxLongitude: -52, minLatitude: 7, maxLatitude: 62)
        case .southAmerica: GeoBounds(minLongitude: -82, maxLongitude: -34, minLatitude: -56, maxLatitude: 13)
        case .oceania: GeoBounds(minLongitude: 112, maxLongitude: 180, minLatitude: -48, maxLatitude: 2)
        }
    }

    /// How far across the region is, from corner to corner. Scores scale with it, so missing by
    /// 300 km costs more in Europe than on the whole world map.
    var spanKilometers: Double {
        let bounds = bounds
        return PinDropGeometry.distanceKilometers(
            from: GeoCoordinate(latitude: bounds.minLatitude, longitude: bounds.minLongitude),
            to: GeoCoordinate(latitude: bounds.maxLatitude, longitude: bounds.maxLongitude)
        )
    }

    /// The region's frame in map coordinates.
    var mapRect: CGRect {
        let bounds = bounds
        let topLeft = MapProjection.project(longitude: bounds.minLongitude, latitude: bounds.maxLatitude)
        let bottomRight = MapProjection.project(longitude: bounds.maxLongitude, latitude: bounds.minLatitude)
        return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
    }
}

// MARK: - GeoBounds
struct GeoBounds: Equatable, Sendable {
    let minLongitude: Double
    let maxLongitude: Double
    let minLatitude: Double
    let maxLatitude: Double
}
