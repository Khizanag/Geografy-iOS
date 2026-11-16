import CoreGraphics
import Geografy_Core_Common
@testable import Geografy_Core_Map
import Testing

@Suite("MapState clamping")
@MainActor
struct MapStateClampTests {
    private let viewSize = CGSize(width: 400, height: 800)
    /// Land centered in the map's square, 1,600 wide and 800 tall.
    private let content = CGRect(
        x: MapProjection.mapWidth / 2 - 800,
        y: MapProjection.mapHeight / 2 - 400,
        width: 1_600,
        height: 800
    )

    @Test("Content smaller than the view stays centered on that side")
    func smallContentStaysCentered() {
        let state = MapState()
        state.scale = 0.25
        state.offset = CGSize(width: 900, height: -700)

        state.clampOffset(to: content, in: viewSize, horizontally: true)

        #expect(state.offset == .zero)
    }

    @Test("Content bigger than the view pans only until its edge meets the view's edge")
    func bigContentStopsAtItsEdge() {
        let state = MapState()
        state.scale = 1
        state.offset = CGSize(width: 5_000, height: -5_000)

        state.clampOffset(to: content, in: viewSize, horizontally: true)

        // 1,600 wide in a 400 view leaves 600 either way; 800 tall in an 800 view leaves none.
        #expect(state.offset == CGSize(width: 600, height: 0))
    }

    @Test("A map that wraps sideways keeps its sideways offset")
    func wrappingMapKeepsHorizontalOffset() {
        let state = MapState()
        state.scale = 1
        state.offset = CGSize(width: 5_000, height: 0)

        state.clampOffset(to: content, in: viewSize, horizontally: false)

        #expect(state.offset.width == 5_000)
    }

    @Test("Off-center content is clamped around its own center")
    func offCenterContentClampsAroundItsCenter() {
        let state = MapState()
        state.scale = 0.25
        let offCenter = content.offsetBy(dx: 400, dy: 0)
        state.offset = CGSize(width: 900, height: 0)

        state.clampOffset(to: offCenter, in: viewSize, horizontally: true)

        // Too narrow to pan, so the content's center lands on the view's center: 400 map points left, scaled.
        #expect(state.offset.width == -100)
    }
}
