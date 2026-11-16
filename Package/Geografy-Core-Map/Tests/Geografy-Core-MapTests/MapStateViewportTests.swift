import CoreGraphics
import Geografy_Core_Common
@testable import Geografy_Core_Map
import SwiftUI
import Testing

@Suite("MapState viewport")
@MainActor
struct MapStateViewportTests {
    private let viewSize = CGSize(width: 400, height: 800)

    @Test("At scale 1 and no offset, the view's center is the map's center")
    func centerMapsToCenter() {
        let state = MapState()

        let point = state.mapPoint(for: CGPoint(x: 200, y: 400), in: viewSize, wrapping: false)

        #expect(point == CGPoint(x: MapProjection.mapWidth / 2, y: MapProjection.mapHeight / 2))
    }

    @Test("A tap on the copy to the right maps back onto the one copy of the shapes")
    func wrappedTapMapsBack() {
        let state = MapState()
        let onRightCopy = CGPoint(x: 200 + MapProjection.mapWidth, y: 400)

        let wrapped = state.mapPoint(for: onRightCopy, in: viewSize, wrapping: true)
        let unwrapped = state.mapPoint(for: onRightCopy, in: viewSize, wrapping: false)

        #expect(wrapped.x == MapProjection.mapWidth / 2)
        #expect(unwrapped.x == MapProjection.mapWidth * 1.5)
    }

    @Test("A point inside two shapes picks the smaller one")
    func smallestShapeWins() {
        let state = MapState()
        state.countryShapes = [
            Self.square(id: "BIG", CGRect(x: 0, y: 0, width: 100, height: 100)),
            Self.square(id: "SMALL", CGRect(x: 40, y: 40, width: 20, height: 20)),
        ]

        #expect(state.shape(at: CGPoint(x: 50, y: 50))?.id == "SMALL")
        #expect(state.shape(at: CGPoint(x: 10, y: 10))?.id == "BIG")
        #expect(state.shape(at: CGPoint(x: 500, y: 500)) == nil)
    }

    @Test("Wrapping keeps the offset within one copy of the world, gesture start included")
    func wrapKeepsOneCopy() {
        let state = MapState()
        state.offset = CGSize(width: MapProjection.mapWidth * 0.75, height: 0)
        state.lastOffset = state.offset

        state.wrapHorizontalOffset()

        #expect(state.offset.width == -MapProjection.mapWidth * 0.25)
        #expect(state.lastOffset == state.offset)
    }

    @Test("Centering puts the bounds' middle on the view's middle")
    func centerOnBounds() {
        let state = MapState()
        state.scale = 2
        let bounds = CGRect(x: MapProjection.mapWidth / 2 + 100, y: MapProjection.mapHeight / 2, width: 0.5, height: 0.5)

        state.center(on: bounds)

        #expect(abs(state.offset.width + 200.5) < 0.001)
    }

    @Test("Bounds cover every shape, and are zero without shapes")
    func boundsOfShapes() {
        let shapes = [
            Self.square(id: "A", CGRect(x: 0, y: 0, width: 10, height: 10)),
            Self.square(id: "B", CGRect(x: 50, y: 20, width: 10, height: 10)),
        ]

        #expect(MapState.bounds(of: shapes) == CGRect(x: 0, y: 0, width: 60, height: 30))
        #expect(MapState.bounds(of: []) == .zero)
    }
}

// MARK: - Helpers
private extension MapStateViewportTests {
    static func square(id: String, _ rect: CGRect) -> CountryShape {
        CountryShape(
            id: id,
            name: id,
            continent: "",
            polygons: [CGPath(rect: rect, transform: nil)],
            centroid: CGPoint(x: rect.midX, y: rect.midY),
            boundingBox: rect,
            color: .gray
        )
    }
}

// MARK: - Focus
extension MapStateViewportTests {
    @Test("Focusing zooms a country to about half the view and centers it")
    func focusFitsAndCenters() {
        let state = MapState()
        state.minScale = 0.1
        let bounds = CGRect(x: MapProjection.mapWidth / 2, y: MapProjection.mapHeight / 2, width: 100, height: 50)

        state.focus(on: bounds, in: CGSize(width: 400, height: 800))

        #expect(state.scale == 2)
        #expect(state.lastScale == 2)
        #expect(state.offset == CGSize(width: -100, height: -50))
    }

    @Test("Focusing never zooms past the focus limit, even for a tiny country")
    func focusIsCapped() {
        let state = MapState()
        let tiny = CGRect(x: 10, y: 10, width: 0.01, height: 0.01)

        state.focus(on: tiny, in: CGSize(width: 400, height: 800))

        #expect(state.scale == MapState.maxFocusScale)
    }
}
