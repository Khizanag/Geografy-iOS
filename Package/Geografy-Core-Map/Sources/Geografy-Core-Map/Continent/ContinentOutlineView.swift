import Geografy_Core_DesignSystem
import SwiftUI

/// A continent's silhouette with its country borders, fitted into the available space,
/// optionally with one country picked out in a color.
public struct ContinentOutlineView: View {
    // MARK: - Highlight
    public struct Highlight {
        let countryCode: String
        let color: Color

        public init(countryCode: String, color: Color) {
            self.countryCode = countryCode
            self.color = color
        }
    }

    // MARK: - Properties
    let outline: ContinentOutline
    let fill: Color
    var highlight: Highlight?
    var countryColors: [String: Color] = [:]

    // MARK: - Init
    /// - Parameter countryColors: Fills for any number of countries, such as each one's mastery; the rest take
    ///   `fill`.
    public init(
        outline: ContinentOutline,
        fill: Color,
        highlight: Highlight? = nil,
        countryColors: [String: Color] = [:]
    ) {
        self.outline = outline
        self.fill = fill
        self.highlight = highlight
        self.countryColors = countryColors
    }

    // MARK: - Body
    public var body: some View {
        Canvas { context, size in
            let transform = outline.fittingTransform(in: size)
            var mapContext = context
            mapContext.concatenate(transform)
            mapContext.clip(to: Path(outline.viewport))
            let path = Path(outline.path)
            mapContext.fill(path, with: .color(fill))
            for (countryCode, color) in countryColors {
                guard let countryPath = outline.countryPaths[countryCode] else { continue }
                mapContext.fill(Path(countryPath), with: .color(color))
            }

            if let highlight, let countryPath = outline.countryPaths[highlight.countryCode] {
                mapContext.fill(Path(countryPath), with: .color(highlight.color))
                drawMarkerIfTiny(countryPath, color: highlight.color, transform: transform, in: &context)
            }

            mapContext.stroke(
                path,
                with: .color(DesignSystem.Color.cardBackground),
                lineWidth: Self.borderWidth / transform.a
            )
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Helpers
private extension ContinentOutlineView {
    static let borderWidth: CGFloat = 0.6
    /// Countries smaller than this on screen get a ring so they can be found: Monaco on a continent, and on the
    /// whole world anything about Guyana's size.
    static let tinyCountrySize: CGFloat = 14
    static let markerRadius: CGFloat = 12

    func drawMarkerIfTiny(
        _ countryPath: CGPath,
        color: Color,
        transform: CGAffineTransform,
        in context: inout GraphicsContext
    ) {
        let screenBounds = countryPath.boundingBoxOfPath.applying(transform)
        guard max(screenBounds.width, screenBounds.height) < Self.tinyCountrySize else { return }
        let ring = CGRect(
            x: screenBounds.midX - Self.markerRadius,
            y: screenBounds.midY - Self.markerRadius,
            width: Self.markerRadius * 2,
            height: Self.markerRadius * 2
        )
        context.stroke(Path(ellipseIn: ring), with: .color(color), lineWidth: 2)
    }
}
