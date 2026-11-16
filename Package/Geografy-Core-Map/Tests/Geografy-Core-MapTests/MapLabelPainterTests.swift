import CoreGraphics
@testable import Geografy_Core_Map
import Testing

@Suite("MapLabelPainter")
struct MapLabelPainterTests {
    @Test("A name is hidden while its country is narrower than where the fade starts")
    func hiddenBelowFade() {
        #expect(MapLabelPainter.opacity(forWidth: MapLabelPainter.fadeStartWidth) == 0)
        #expect(MapLabelPainter.opacity(forWidth: 10) == 0)
    }

    @Test("A name is fully shown once its country is past the fade")
    func opaqueAboveFade() {
        let width = MapLabelPainter.fadeStartWidth + MapLabelPainter.fadeRange
        #expect(MapLabelPainter.opacity(forWidth: width) == 1)
        #expect(MapLabelPainter.opacity(forWidth: width * 4) == 1)
    }

    @Test("Opacity rises in small steps as a country grows, never jumping")
    func opacityIsContinuous() {
        let step: CGFloat = 0.5
        var width = MapLabelPainter.fadeStartWidth - 5
        var previous = MapLabelPainter.opacity(forWidth: width)
        while width < MapLabelPainter.fadeStartWidth + MapLabelPainter.fadeRange + 5 {
            width += step
            let current = MapLabelPainter.opacity(forWidth: width)
            #expect(current >= previous)
            #expect(current - previous <= Double(step / MapLabelPainter.fadeRange) + 0.0001)
            previous = current
        }
    }

    @Test("Font size follows the country's width between the bounds")
    func fontSizeBounds() {
        #expect(MapLabelPainter.fontSize(forWidth: 1, name: "Chile") == MapLabelPainter.minFontSize)
        #expect(MapLabelPainter.fontSize(forWidth: 10_000, name: "Chile") == MapLabelPainter.maxFontSize)
        #expect(MapLabelPainter.fontSize(forWidth: 50, name: "Chile") == 10)
    }

    @Test("An empty name doesn't divide by zero")
    func emptyName() {
        #expect(MapLabelPainter.fontSize(forWidth: 50, name: "") == MapLabelPainter.maxFontSize)
    }
}
