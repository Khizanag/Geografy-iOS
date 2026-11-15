@testable import Geografy_Core_DesignSystem
import Testing

@Suite("MapPalette")
struct MapPaletteTests {
    @Test("Every palette has the six colors the coloring engine counts on", arguments: MapPalette.allCases)
    func sixColors(palette: MapPalette) {
        #expect(palette.colors.count == MapPalette.colorCount)
        #expect(palette.distances.count == MapPalette.colorCount)
    }

    @Test("Every pair of colors looks clearly different, in light and dark mode", arguments: MapPalette.allCases)
    func contrast(palette: MapPalette) {
        // 0.065 ΔE in Oklab is about three times a just-noticeable difference.
        #expect(palette.minimumContrast >= 0.065)
    }

    @Test("Every country stands out from the sea, in light and dark mode", arguments: MapPalette.allCases)
    func oceanContrast(palette: MapPalette) {
        #expect(palette.oceanContrast >= 0.07)
    }

    @Test("Colored palettes beat the old fixed palette's closest pair", arguments: [MapPalette.vivid, .colorSafe])
    func strongPalettesBeatTheOld(palette: MapPalette) {
        // The old palette's red and orange were 0.092 apart.
        #expect(palette.minimumContrast > 0.092)
    }

    @Test("The designs stay inside sRGB, so no color is clipped on screen", arguments: MapPalette.allCases)
    func inGamut(palette: MapPalette) {
        for swatch in palette.swatches {
            #expect(swatch.light.isInGamut)
            #expect(swatch.dark.isInGamut)
        }
    }

    @Test("Distances are symmetric and zero only on the diagonal")
    func distanceMatrix() {
        let distances = MapPalette.atlas.distances
        for row in distances.indices {
            #expect(distances[row][row] == 0)
            for column in distances.indices where column != row {
                #expect(distances[row][column] == distances[column][row])
                #expect(distances[row][column] > 0)
            }
        }
    }

    @Test("Oklab conversion lands on sRGB's black and white")
    func conversion() {
        let white = OKLCH(1, 0, 0).rgb
        let black = OKLCH(0, 0, 0).rgb
        #expect(abs(white.red - 1) < 0.001 && abs(white.green - 1) < 0.001 && abs(white.blue - 1) < 0.001)
        #expect(black.red < 0.001 && black.green < 0.001 && black.blue < 0.001)
    }
}
