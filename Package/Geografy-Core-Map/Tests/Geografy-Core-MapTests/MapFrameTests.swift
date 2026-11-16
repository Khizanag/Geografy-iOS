import CoreGraphics
@testable import Geografy_Core_Map
import Testing

@Suite("MapFrame")
struct MapFrameTests {
    private let viewSize = CGSize(width: 400, height: 800)

    @Test("Moving to the same frame needs no transform")
    func identityTransform() {
        let frame = MapFrame(scale: 2, offset: CGSize(width: 30, height: -10))

        let (magnification, shift) = frame.transform(to: frame)

        #expect(magnification == 1)
        #expect(shift == .zero)
    }

    @Test("The transform places a map point where the target frame draws it")
    func transformMatchesTargetFrame() {
        let drawn = MapFrame(scale: 2, offset: CGSize(width: 40, height: 20))
        let target = MapFrame(scale: 3, offset: CGSize(width: -15, height: 60))
        let centered = CGPoint(x: 120, y: -70)

        let (magnification, shift) = drawn.transform(to: target)
        let drawnPoint = CGPoint(
            x: centered.x * drawn.scale + drawn.offset.width,
            y: centered.y * drawn.scale + drawn.offset.height
        )
        let moved = CGPoint(
            x: drawnPoint.x * magnification + shift.width,
            y: drawnPoint.y * magnification + shift.height
        )

        #expect(abs(moved.x - (centered.x * target.scale + target.offset.width)) < 0.0001)
        #expect(abs(moved.y - (centered.y * target.scale + target.offset.height)) < 0.0001)
    }

    @Test("A pan within the overscan keeps the drawn map")
    func smallPanIsCovered() {
        let drawn = MapFrame(scale: 1, offset: .zero)
        let target = MapFrame(scale: 1, offset: CGSize(width: 150, height: -300))

        #expect(MapFrame.drawnMap(drawn, covers: viewSize, at: target))
    }

    @Test("A pan past the overscan needs a redraw")
    func longPanIsNotCovered() {
        let drawn = MapFrame(scale: 1, offset: .zero)
        let target = MapFrame(scale: 1, offset: CGSize(width: 250, height: 0))

        #expect(!MapFrame.drawnMap(drawn, covers: viewSize, at: target))
    }

    @Test("Zooming out past what was drawn needs a redraw")
    func zoomOutIsNotCovered() {
        let drawn = MapFrame(scale: 2, offset: .zero)

        #expect(MapFrame.drawnMap(drawn, covers: viewSize, at: MapFrame(scale: 1.2, offset: .zero)))
        #expect(!MapFrame.drawnMap(drawn, covers: viewSize, at: MapFrame(scale: 0.9, offset: .zero)))
    }

    @Test("Zooming in past twice the drawn scale redraws so it stays sharp")
    func zoomInPastMagnificationLimit() {
        let drawn = MapFrame(scale: 1, offset: .zero)

        #expect(MapFrame.drawnMap(drawn, covers: viewSize, at: MapFrame(scale: 2, offset: .zero)))
        #expect(!MapFrame.drawnMap(drawn, covers: viewSize, at: MapFrame(scale: 2.1, offset: .zero)))
    }
}

@Suite("MapState gesture frame")
@MainActor
struct MapStateGestureFrameTests {
    @Test("A gesture keeps the map drawn where it began until it ends")
    func gestureKeepsDrawnFrame() {
        let mapState = MapState()
        mapState.beginGesture()
        mapState.offset = CGSize(width: 50, height: 0)

        #expect(mapState.drawnFrame == MapFrame(scale: 1, offset: .zero))

        mapState.endGesture()

        #expect(mapState.drawnFrame == MapFrame(scale: 1, offset: CGSize(width: 50, height: 0)))
    }

    @Test("Redrawing mid-gesture moves the drawn frame to the current one")
    func redrawMovesDrawnFrame() {
        let mapState = MapState()
        mapState.beginGesture()
        mapState.offset = CGSize(width: 900, height: 0)

        #expect(mapState.needsRedraw(in: CGSize(width: 400, height: 800)))

        mapState.redrawGestureFrame()

        #expect(mapState.drawnFrame == mapState.currentFrame)
        #expect(!mapState.needsRedraw(in: CGSize(width: 400, height: 800)))
    }

    @Test("Without a gesture there's nothing to redraw")
    func noGestureNoRedraw() {
        let mapState = MapState()
        mapState.offset = CGSize(width: 900, height: 0)

        #expect(!mapState.needsRedraw(in: CGSize(width: 400, height: 800)))
        #expect(mapState.drawnFrame == mapState.currentFrame)
    }
}
