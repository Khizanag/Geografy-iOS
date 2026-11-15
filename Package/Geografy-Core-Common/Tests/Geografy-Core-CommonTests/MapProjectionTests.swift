import CoreGraphics
import Foundation
@testable import Geografy_Core_Common
import Testing

@Suite("MapProjection")
struct MapProjectionTests {
    private static let places: [(longitude: Double, latitude: Double)] = [
        (0, 0), (44.8, 41.7), (-74, 40.7), (151.2, -33.9), (-179, 70), (120, -60), (2.35, 48.86),
    ]

    @Test("Every projection puts the equator and prime meridian in the middle", arguments: MapProjectionKind.allCases)
    func centered(kind: MapProjectionKind) {
        let center = MapProjection.project(longitude: 0, latitude: 0, kind: kind)
        #expect(abs(center.x - MapProjection.mapWidth / 2) < 0.001)
        #expect(abs(center.y - MapProjection.mapHeight / 2) < 0.001)
    }

    @Test("Projecting and unprojecting returns the same place", arguments: MapProjectionKind.allCases)
    func roundTrip(kind: MapProjectionKind) {
        for place in Self.places {
            let point = MapProjection.project(longitude: place.longitude, latitude: place.latitude, kind: kind)
            let back = MapProjection.unproject(point: point, kind: kind)
            #expect(abs(back.longitude - place.longitude) < 1e-6)
            #expect(abs(back.latitude - place.latitude) < 1e-6)
        }
    }

    @Test("Equal Earth's equator spans the map's width, like Mercator's")
    func equalEarthWidth() {
        let west = MapProjection.project(longitude: -180, latitude: 0, kind: .equalEarth)
        let east = MapProjection.project(longitude: 180, latitude: 0, kind: .equalEarth)
        #expect(abs(west.x) < 0.001)
        #expect(abs(east.x - MapProjection.mapWidth) < 0.001)
    }

    @Test("Equal Earth keeps sizes: a 10° cell near the pole has its true share of a cell at the equator")
    func equalEarthKeepsArea() {
        // On the globe, the 60–70° band holds (sin 70° − sin 60°) / sin 10° ≈ 0.42 of the 0–10° band's area.
        let expected = (sin(70 * Double.pi / 180) - sin(60 * Double.pi / 180)) / sin(10 * Double.pi / 180)
        let ratio = Self.projectedArea(fromLatitude: 60) / Self.projectedArea(fromLatitude: 0)
        #expect(abs(ratio - expected) < 0.002)
    }

    /// The area of a 10° by 10° cell on the Equal Earth map, from its outline traced along each edge.
    private static func projectedArea(fromLatitude latitude: Double) -> Double {
        let steps = 20
        var outline: [CGPoint] = []
        let edges: [(Double, Double, Double, Double)] = [
            (0, latitude, 10, latitude), (10, latitude, 10, latitude + 10),
            (10, latitude + 10, 0, latitude + 10), (0, latitude + 10, 0, latitude),
        ]
        for (startLongitude, startLatitude, endLongitude, endLatitude) in edges {
            for index in 0..<steps {
                let fraction = Double(index) / Double(steps)
                outline.append(MapProjection.project(
                    longitude: startLongitude + (endLongitude - startLongitude) * fraction,
                    latitude: startLatitude + (endLatitude - startLatitude) * fraction,
                    kind: .equalEarth
                ))
            }
        }
        let doubled = zip(outline, outline.dropFirst() + [outline[0]]).reduce(0.0) { sum, pair in
            sum + Double(pair.0.x * pair.1.y - pair.1.x * pair.0.y)
        }
        return abs(doubled) / 2
    }

    @Test("Mercator inflates the same polar cell instead")
    func mercatorInflates() {
        let polar = MapProjection.boundingRect(
            minLongitude: 0, maxLongitude: 10, minLatitude: 60, maxLatitude: 70, kind: .mercator
        )
        let equatorial = MapProjection.boundingRect(
            minLongitude: 0, maxLongitude: 10, minLatitude: 0, maxLatitude: 10, kind: .mercator
        )
        #expect(polar.height > equatorial.height * 2)
    }

    @Test("Only Equal Earth has a rounded world edge")
    func outline() {
        #expect(MapProjection.worldOutline(kind: .mercator) == nil)
        #expect((MapProjection.worldOutline(kind: .equalEarth)?.count ?? 0) > 100)
    }
}
