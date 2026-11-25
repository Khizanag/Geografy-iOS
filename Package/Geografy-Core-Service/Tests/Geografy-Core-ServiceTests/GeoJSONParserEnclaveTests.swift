import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@Suite("Enclaves")
struct GeoJSONParserEnclaveTests {
    /// The app's own map file, found from this test's path.
    static let mapURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appending(path: "../../../../Geografy/Resource/countries.geojson")
        .standardized

    @Test("A country inside another draws after it, so it stays visible", arguments: [
        ("LS", "ZA"),
        ("SM", "IT"),
        ("VA", "IT"),
    ])
    func enclaveDrawsOnTop(enclave: String, surrounding: String) throws {
        let codes = GeoJSONParser.parse(data: try Data(contentsOf: Self.mapURL), projection: .mercator).map(\.id)
        let enclaveIndex = try #require(codes.firstIndex(of: enclave))
        let surroundingIndex = try #require(codes.firstIndex(of: surrounding))

        #expect(enclaveIndex > surroundingIndex)
    }

    @Test("Bir Tawil, which no country claims, is drawn inside Sudan, so the map has no hole there")
    func birTawilIsLand() throws {
        let shapes = GeoJSONParser.parse(data: try Data(contentsOf: Self.mapURL), projection: .mercator)
        let sudan = try #require(shapes.first { $0.id == "SD" })
        let birTawil = MapProjection.project(longitude: 33.6, latitude: 21.85, kind: .mercator)

        #expect(sudan.polygons.contains { $0.contains(birTawil) })
    }
}
