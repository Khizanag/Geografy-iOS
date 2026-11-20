import CoreGraphics
import Geografy_Core_Map
@testable import Geografy_Feature_Play
import SwiftUI
import Testing

@Suite("PinDrop camera")
struct PinDropCameraTests {
    private let size = CGSize(width: 400, height: 800)
    private let insets = EdgeInsets(top: 100, leading: 0, bottom: 300, trailing: 0)
    /// Where the visible area's middle sits: halfway across, and halfway between the top and bottom insets.
    private let focus = CGPoint(x: 200, y: 300)
    private let region = CGRect(x: 100, y: 100, width: 400, height: 200)

    @Test("Zoomed in, a pan reaches the region's far edges")
    func zoomedInReachesEdges() {
        let zoomed = PinDropCamera.frame(fitting: region, in: size, insets: insets, fill: 1)
        var frame = MapFrame(scale: zoomed.scale * 4, offset: .zero)
        // Put the region's right edge just left of the middle: one point past where the clamp stops it.
        let rightEdge = PinDropCamera.screenPoint(of: CGPoint(x: region.maxX, y: region.midY), frame: frame, in: size)
        frame.offset.width += focus.x - rightEdge.x - 1
        frame.offset.height += focus.y - rightEdge.y

        let clamped = PinDropCamera.clamped(frame, keeping: region, in: size, insets: insets)

        let edge = PinDropCamera.screenPoint(of: CGPoint(x: region.maxX, y: region.midY), frame: clamped, in: size)
        #expect(abs(edge.x - focus.x) < 0.001)
        #expect(abs(clamped.offset.width - frame.offset.width - 1) < 0.001)
    }

    @Test("A frame that keeps the region over the middle doesn't move")
    func frameOverRegionStays() {
        let frame = PinDropCamera.frame(fitting: region, in: size, insets: insets)

        let clamped = PinDropCamera.clamped(frame, keeping: region, in: size, insets: insets)

        #expect(clamped == frame)
    }

    @Test("A pan past the region stops with its edge at the middle", arguments: [
        CGSize(width: 10_000, height: 0),
        CGSize(width: -10_000, height: 0),
        CGSize(width: 0, height: 10_000),
        CGSize(width: 0, height: -10_000),
    ])
    func panPastRegionStops(shift: CGSize) {
        var frame = PinDropCamera.frame(fitting: region, in: size, insets: insets)
        frame.offset.width += shift.width
        frame.offset.height += shift.height

        let clamped = PinDropCamera.clamped(frame, keeping: region, in: size, insets: insets)

        let topLeading = PinDropCamera.screenPoint(of: region.origin, frame: clamped, in: size)
        let bottomTrailing = PinDropCamera.screenPoint(
            of: CGPoint(x: region.maxX, y: region.maxY),
            frame: clamped,
            in: size
        )
        #expect(topLeading.x <= focus.x + 0.001, "left edge passed the middle")
        #expect(bottomTrailing.x >= focus.x - 0.001, "right edge passed the middle")
        #expect(topLeading.y <= focus.y + 0.001, "top edge passed the middle")
        #expect(bottomTrailing.y >= focus.y - 0.001, "bottom edge passed the middle")
    }
}
