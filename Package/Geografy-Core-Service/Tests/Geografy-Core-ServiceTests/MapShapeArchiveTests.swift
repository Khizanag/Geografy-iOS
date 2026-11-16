import CoreGraphics
import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@Suite("Map shape archive")
struct MapShapeArchiveTests {
    @Test("Saved outlines read back the same")
    func roundTrip() throws {
        let shapes = [Self.shape(id: "AA", origin: 0), Self.shape(id: "BB", origin: 100)]

        let decoded = try #require(MapShapeArchive.decode(MapShapeArchive.encode(shapes)))

        #expect(decoded.map(\.id) == ["AA", "BB"])
        #expect(decoded.map(\.name) == ["Country AA", "Country BB"])
        #expect(decoded[1].boundingBox == shapes[1].boundingBox)
        #expect(decoded[1].centroid == shapes[1].centroid)
        #expect(decoded[1].polygons.map(\.boundingBoxOfPath) == shapes[1].polygons.map(\.boundingBoxOfPath))
        #expect(decoded[1].detailPaths.count == shapes[1].detailPaths.count)
        #expect(decoded[1].contains(CGPoint(x: 105, y: 105)))
        #expect(!decoded[1].contains(CGPoint(x: 5, y: 5)))
    }

    @Test("Damaged or foreign data isn't read")
    func rejectsBadData() {
        let data = MapShapeArchive.encode([Self.shape(id: "AA", origin: 0)])

        #expect(MapShapeArchive.decode(data.dropLast(3)) == nil)
        #expect(MapShapeArchive.decode(Data("not a map".utf8)) == nil)
        #expect(MapShapeArchive.decode(Data()) == nil)
    }

    @Test("The real map survives a save and a read")
    func realMapRoundTrip() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "../../../../Geografy/Resource/countries.geojson")
            .standardized
        let shapes = GeoJSONParser.parse(data: try Data(contentsOf: url), projection: .equalEarth)

        let decoded = try #require(MapShapeArchive.decode(MapShapeArchive.encode(shapes)))

        #expect(decoded.map(\.id) == shapes.map(\.id))
        #expect(decoded.map(\.boundingBox) == shapes.map(\.boundingBox))
        #expect(decoded.map { $0.detailPaths.count } == shapes.map { $0.detailPaths.count })
    }
}

// MARK: - Helpers
private extension MapShapeArchiveTests {
    static func shape(id: String, origin: CGFloat) -> CountryShape {
        let rect = CGRect(x: origin, y: origin, width: 10, height: 10)
        let polygon = CGPath(rect: rect, transform: nil)
        let coarse = CGPath(rect: rect.insetBy(dx: 1, dy: 1), transform: nil)
        return CountryShape(
            id: id,
            name: "Country \(id)",
            continent: "Europe",
            polygons: [polygon],
            detailPaths: [coarse, polygon],
            centroid: CGPoint(x: rect.midX, y: rect.midY),
            boundingBox: rect,
            color: .gray
        )
    }
}
