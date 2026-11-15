import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Draws country names on a map, sized to each country as it appears on screen.
///
/// A name's size and opacity change continuously with the zoom, so names grow, shrink, and fade in
/// as the map is pinched instead of jumping between sizes or popping into view.
enum MapLabelPainter {
    /// How wide a country must appear before its name starts to fade in.
    static let fadeStartWidth: CGFloat = 40
    /// How much wider it must grow, past `fadeStartWidth`, for its name to be fully opaque.
    static let fadeRange: CGFloat = 24
    static let minFontSize: CGFloat = 6
    static let maxFontSize: CGFloat = 14

    static func draw(
        _ shapes: [CountryShape],
        in context: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        for shape in shapes {
            let bounds = shape.boundingBox.applying(transform)
            let opacity = opacity(forWidth: bounds.width)
            guard opacity > 0, bounds.intersects(visibleRect) else { continue }

            let point = labelPoint(for: shape, in: bounds, transform: transform)
            guard visibleRect.contains(point) else { continue }

            var labelContext = context
            labelContext.opacity = opacity
            let size = fontSize(forWidth: bounds.width, name: shape.name)
            drawName(shape.name, at: point, fontSize: size, in: labelContext)
        }
    }

    /// 0 while a country is too small on screen for its name, rising to 1 as it grows.
    static func opacity(forWidth width: CGFloat) -> Double {
        Double(min(max((width - fadeStartWidth) / fadeRange, 0), 1))
    }

    static func fontSize(forWidth width: CGFloat, name: String) -> CGFloat {
        min(max(width / CGFloat(max(name.count, 1)), minFontSize), maxFontSize)
    }
}

// MARK: - Helpers
private extension MapLabelPainter {
    /// The centroid, kept inside the country's bounds so names never sit outside narrow or
    /// non-convex countries such as Chile or the UAE.
    static func labelPoint(for shape: CountryShape, in bounds: CGRect, transform: CGAffineTransform) -> CGPoint {
        let rawPoint = shape.centroid.applying(transform)
        let insetBounds = bounds.insetBy(dx: 2, dy: 2)
        return CGPoint(
            x: max(insetBounds.minX, min(rawPoint.x, insetBounds.maxX)),
            y: max(insetBounds.minY, min(rawPoint.y, insetBounds.maxY))
        )
    }

    static func drawName(_ name: String, at point: CGPoint, fontSize: CGFloat, in context: GraphicsContext) {
        // Resolved once and recolored, so each name is laid out once per frame, not twice.
        var label = context.resolve(
            Text(name)
                .font(DesignSystem.Font.system(size: fontSize, weight: .semibold))
        )

        var shadowContext = context
        shadowContext.opacity *= 0.7
        label.shading = .color(DesignSystem.Color.textPrimary)
        shadowContext.draw(label, at: CGPoint(x: point.x + 0.5, y: point.y + 0.5), anchor: .center)

        label.shading = .color(DesignSystem.Color.onAccent)
        context.draw(label, at: point, anchor: .center)
    }
}
