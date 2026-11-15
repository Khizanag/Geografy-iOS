import CoreGraphics
import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Map
import Testing

@Suite("MapGraticule")
struct MapGraticuleTests {
    @Test("The grid tightens as the map zooms in")
    func stepFollowsZoom() {
        let world = MapGraticule.step(forScale: 0.2)
        let continent = MapGraticule.step(forScale: 1)
        let close = MapGraticule.step(forScale: 20)

        #expect(world == 30)
        #expect(continent < world)
        #expect(close < continent)
    }

    @Test("Neighboring meridians stay at least the minimum apart, unless the widest step is too tight")
    func spacingIsComfortable() {
        for scale in stride(from: CGFloat(0.5), through: 40, by: 0.5) {
            let step = MapGraticule.step(forScale: scale)
            let spacing = MapProjection.mapWidth * scale / 360 * step
            #expect(spacing >= MapGraticule.minimumSpacing)
        }
    }

    @Test("Labels skip meridians only when they would crowd")
    func labelStride() {
        #expect(MapGraticule.labelStride(forScale: 0.2, step: 30) > 1)
        #expect(MapGraticule.labelStride(forScale: 2, step: MapGraticule.step(forScale: 2)) == 1)
    }

    @Test("Values are the multiples of the step within the range")
    func values() {
        #expect(MapGraticule.values(from: -35, to: 65, step: 30) == [-30, 0, 30, 60])
        #expect(MapGraticule.values(from: 1.1, to: 1.9, step: 0.5) == [1.5])
        #expect(MapGraticule.values(from: 5, to: 4, step: 1).isEmpty)
    }

    @Test("Longitudes fold back into -180...180 on a repeating map")
    func normalizes() {
        #expect(MapGraticule.normalizedLongitude(200) == -160)
        #expect(MapGraticule.normalizedLongitude(-190) == 170)
        #expect(MapGraticule.normalizedLongitude(30) == 30)
    }

    @Test("Degrees carry as many decimals as the step needs")
    func degrees() {
        let english = Locale(identifier: "en_US")
        #expect(MapGraticule.degrees(-40, step: 10, locale: english) == "40")
        #expect(MapGraticule.degrees(12.5, step: 0.5, locale: english) == "12.5")
        #expect(MapGraticule.degrees(0.25, step: 0.25, locale: english) == "0.25")
        #expect(MapGraticule.degrees(12.5, step: 0.5, locale: Locale(identifier: "ka_GE")) == "12,5")
    }

    @Test("Screen positions and coordinates agree both ways")
    func placementRoundTrip() {
        let placement = MapGraticule.Placement(
            scale: 1.3,
            offset: CGSize(width: 40, height: -25),
            size: CGSize(width: 400, height: 800)
        )

        #expect(abs(placement.longitude(atX: placement.x(forLongitude: 44.8)) - 44.8) < 0.0001)
        #expect(abs(placement.latitude(atY: placement.y(forLatitude: 41.7)) - 41.7) < 0.0001)
    }
}
