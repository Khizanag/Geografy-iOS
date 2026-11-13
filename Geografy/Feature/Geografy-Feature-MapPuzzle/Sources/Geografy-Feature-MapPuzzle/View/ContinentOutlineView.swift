import Geografy_Core_DesignSystem
import SwiftUI

/// A continent's silhouette with its country borders, fitted into the available space,
/// optionally with one country picked out in a color.
struct ContinentOutlineView: View {
    // MARK: - Highlight
    struct Highlight {
        let countryCode: String
        let color: Color
    }

    // MARK: - Properties
    let outline: ContinentOutline
    let fill: Color
    var highlight: Highlight?

    // MARK: - Body
    var body: some View {
        Canvas { context, size in
            let transform = outline.fittingTransform(in: size)
            var mapContext = context
            mapContext.concatenate(transform)
            mapContext.clip(to: Path(outline.viewport))
            let path = Path(outline.path)
            mapContext.fill(path, with: .color(fill))

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
    /// Countries smaller than this on screen, such as Monaco, get a ring so they can be found.
    static let tinyCountrySize: CGFloat = 8
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
