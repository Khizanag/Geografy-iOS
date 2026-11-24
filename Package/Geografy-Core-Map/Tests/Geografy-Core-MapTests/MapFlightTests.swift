import CoreGraphics
@testable import Geografy_Core_Map
import Testing

@Suite("Map flight")
@MainActor
struct MapFlightTests {
    static let start = MapFrame(scale: 1, offset: CGSize(width: 40, height: -20))
    static let target = MapFrame(scale: 16, offset: CGSize(width: -3_200, height: 1_600))

    @Test("A flight starts and lands exactly on its frames")
    func endpoints() {
        #expect(MapFlight.frame(from: Self.start, to: Self.target, at: 0) == Self.start)
        let landed = MapFlight.frame(from: Self.start, to: Self.target, at: 1)
        #expect(abs(landed.scale - Self.target.scale) < 0.000_1)
        #expect(abs(landed.offset.width - Self.target.offset.width) < 0.01)
        #expect(abs(landed.offset.height - Self.target.offset.height) < 0.01)
    }

    @Test("The zoom only ever grows on the way in, and never overshoots")
    func zoomIsMonotonic() {
        let scales = stride(from: 0.0, through: 1.0, by: 0.05).map {
            MapFlight.frame(from: Self.start, to: Self.target, at: $0).scale
        }
        #expect(zip(scales, scales.dropFirst()).allSatisfy { $0 <= $1 })
        #expect(scales.allSatisfy { $0 >= Self.start.scale && $0 <= Self.target.scale })
    }

    @Test("Halfway through, the zoom is halfway in doublings, not in points")
    func zoomIsGeometric() {
        let halfway = MapFlight.frame(from: Self.start, to: Self.target, at: 0.5)
        #expect(abs(halfway.scale - 4) < 0.000_1)
    }
}
