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
    /// Every country the run asks for, so the small ones can be marked.
    let countries: [Country]
    let namedCodes: Set<String>
    /// A country picked out in Speed Run's colour, such as one tapped in the named list.
    var highlightedCode: String?

    @State private var outline: ContinentOutline?

    // MARK: - Body
    var body: some View {
        Group {
            if let outline {
                ContinentOutlineView(
                    outline: outline,
                    fill: DesignSystem.Color.textTertiary.opacity(DesignSystem.Opacity.half),
                    highlight: highlight,
                    countryColors: namedColors,
                    markers: markers
                )
                .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: namedCodes)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: highlightedCode)
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
extension SpeedRunMap {
    /// Speed Run's own colour, so a tapped row and its country read as one.
    static let highlightColor = DesignSystem.Color.pink
}

private extension SpeedRunMap {
    var highlight: ContinentOutlineView.Highlight? {
        highlightedCode.map { ContinentOutlineView.Highlight(countryCode: $0, color: Self.highlightColor) }
    }

    /// Named countries in green, the colour of a right answer (Geografy article 101).
    var namedColors: [String: Color] {
        Dictionary(uniqueKeysWithValues: namedCodes.map { ($0, DesignSystem.Color.success) })
    }

    /// A missing country too small to see shows as a ring, so a tiny one such as Monaco can't hide; once named,
    /// its ring goes and only its own outline fills in.
    var markers: [String: ContinentOutlineView.Marker] {
        // The highlighted country draws its own mark, in the highlight's colour.
        Dictionary(uniqueKeysWithValues: countries
            .filter { !namedCodes.contains($0.code) && $0.code != highlightedCode }
            .map { country in
                let marker = ContinentOutlineView.Marker(
                    style: .ring,
                    color: DesignSystem.Color.textPrimary,
                    fallbackPoint: country.capitalCoordinate.map(MapProjection.project)
                )
                return (country.code, marker)
            })
    }

    func loadOutline() async {
        let shapes = await geoJSONCache.loadShapes()
        outline = await ContinentOutline.puzzleOutline(for: region.continent, shapes: shapes)
    }
}
