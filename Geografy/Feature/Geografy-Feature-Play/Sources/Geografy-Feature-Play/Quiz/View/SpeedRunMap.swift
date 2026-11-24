import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Service
import SwiftUI

/// The run's region as a map, each country filling in as it's named, so the gaps show what's still missing.
struct SpeedRunMap: View {
    // MARK: - Properties
    /// Whether the map shows during a run, chosen in Speed Run's setup.
    static let storageKey = "speedRun_showsMap"

    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .body) private var height: CGFloat = 190

    let region: QuizRegion
    let namedCodes: Set<String>

    @State private var outline: ContinentOutline?

    // MARK: - Body
    var body: some View {
        Group {
            if let outline {
                ContinentOutlineView(
                    outline: outline,
                    fill: DesignSystem.Color.textTertiary.opacity(DesignSystem.Opacity.half),
                    countryColors: namedColors
                )
                .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: namedCodes)
            } else {
                Color.clear
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .task(id: region) { await loadOutline() }
        .accessibilityElement()
        .accessibilityLabel(Text("Map of \(region.displayName)", bundle: .module))
        .accessibilityValue(Text("\(namedCodes.count) countries named", bundle: .module))
    }
}

// MARK: - Helpers
private extension SpeedRunMap {
    /// Named countries in green, the colour of a right answer (Geografy article 101).
    var namedColors: [String: Color] {
        Dictionary(uniqueKeysWithValues: namedCodes.map { ($0, DesignSystem.Color.success) })
    }

    func loadOutline() async {
        let shapes = await geoJSONCache.loadShapes()
        outline = await ContinentOutline.puzzleOutline(for: region.continent, shapes: shapes)
    }
}
