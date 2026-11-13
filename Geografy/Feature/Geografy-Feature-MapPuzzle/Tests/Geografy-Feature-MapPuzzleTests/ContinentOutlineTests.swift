import CoreGraphics
import Geografy_Core_Common
@testable import Geografy_Feature_MapPuzzle
import SwiftUI
import Testing

@Suite("ContinentOutline")
struct ContinentOutlineTests {
    private static let playableContinents = Country.Continent.allCases.filter { $0 != .antarctica }

    @Test("Every playable continent has a framing inside the map", arguments: playableContinents)
    func viewportInsideMap(continent: Country.Continent) throws {
        let viewport = try #require(ContinentOutline.viewport(for: continent))
        let map = CGRect(x: 0, y: 0, width: MapProjection.mapWidth, height: MapProjection.mapHeight)

        #expect(viewport.width > 0)
        #expect(viewport.height > 0)
        #expect(map.contains(viewport))
    }

    @Test("Antarctica has no framing")
    func antarcticaHasNoViewport() {
        #expect(ContinentOutline.viewport(for: .antarctica) == nil)
    }

    @Test("Joins only the shapes on its continent")
    func joinsMatchingShapes() throws {
        let shapes = [
            makeShape(continent: "Europe", rect: CGRect(x: 1_000, y: 500, width: 10, height: 10)),
            makeShape(continent: "Europe", rect: CGRect(x: 1_050, y: 520, width: 20, height: 20)),
            makeShape(continent: "Africa", rect: CGRect(x: 1_000, y: 900, width: 50, height: 50)),
        ]

        let outline = try #require(ContinentOutline(continent: .europe, shapes: shapes))

        #expect(outline.continent == .europe)
        #expect(outline.path.boundingBoxOfPath == CGRect(x: 1_000, y: 500, width: 70, height: 40))
    }

    @Test("No outline when no shape is on the continent")
    func noMatchingShapes() {
        let shapes = [makeShape(continent: "Africa", rect: CGRect(x: 1_000, y: 900, width: 50, height: 50))]

        #expect(ContinentOutline(continent: .asia, shapes: shapes) == nil)
    }

    @Test("Builds outlines only for continents that have shapes")
    func outlinesForContinents() {
        let shapes = [
            makeShape(continent: "Asia", rect: CGRect(x: 1_500, y: 700, width: 10, height: 10)),
            makeShape(continent: "Oceania", rect: CGRect(x: 1_800, y: 1_200, width: 10, height: 10)),
        ]

        let outlines = ContinentOutline.outlines(for: Self.playableContinents, shapes: shapes)

        #expect(Set(outlines.keys) == [.asia, .oceania])
    }

    @Test("Fits the framing into a size, centered, without stretching")
    func fittingTransform() {
        let outline = ContinentOutline(
            continent: .europe,
            path: CGPath(rect: .zero, transform: nil),
            viewport: CGRect(x: 100, y: 200, width: 200, height: 100)
        )

        let fitted = outline.viewport.applying(outline.fittingTransform(in: CGSize(width: 100, height: 100)))

        #expect(fitted.minX.isApproximately(0))
        #expect(fitted.width.isApproximately(100))
        #expect(fitted.minY.isApproximately(25))
        #expect(fitted.height.isApproximately(50))
    }

    @Test("Leaves an empty size untransformed")
    func fittingTransformEmptySize() {
        let outline = ContinentOutline(
            continent: .europe,
            path: CGPath(rect: .zero, transform: nil),
            viewport: CGRect(x: 100, y: 200, width: 200, height: 100)
        )

        #expect(outline.fittingTransform(in: .zero) == .identity)
    }
}

// MARK: - Helpers
private extension ContinentOutlineTests {
    func makeShape(continent: String, rect: CGRect) -> CountryShape {
        CountryShape(
            id: UUID().uuidString,
            name: continent,
            continent: continent,
            polygons: [CGPath(rect: rect, transform: nil)],
            centroid: CGPoint(x: rect.midX, y: rect.midY),
            boundingBox: rect,
            color: .gray
        )
    }
}

private extension CGFloat {
    func isApproximately(_ other: CGFloat) -> Bool {
        abs(self - other) < 0.001
    }
}
