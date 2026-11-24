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

    // MARK: - Marker
    /// A mark on a country too small to see at this size, so it can still be found: a ring, or a filled dot.
    public struct Marker {
        public enum Style {
            case ring
            case dot
        }

        let style: Style
        let color: Color
        /// Where to mark a country with no shape on the map, in map space, such as its projected capital.
        let fallbackPoint: CGPoint?

        public init(style: Style, color: Color, fallbackPoint: CGPoint? = nil) {
            self.style = style
            self.color = color
            self.fallbackPoint = fallbackPoint
        }
    }

    // MARK: - Properties
    let outline: ContinentOutline
    let fill: Color
    var highlight: Highlight?
    var countryColors: [String: Color] = [:]
    var markers: [String: Marker] = [:]

    // MARK: - Init
    /// - Parameters:
    ///   - countryColors: Fills for any number of countries, such as each one's mastery; the rest take `fill`.
    ///   - markers: Marks for countries that may be too small to see; each shows only where its country is tiny
    ///     on screen or has no shape at all.
    public init(
        outline: ContinentOutline,
        fill: Color,
        highlight: Highlight? = nil,
        countryColors: [String: Color] = [:],
        markers: [String: Marker] = [:]
    ) {
        self.outline = outline
        self.fill = fill
        self.highlight = highlight
        self.countryColors = countryColors
        self.markers = markers
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

            for (countryCode, marker) in markers {
                draw(marker, for: countryCode, transform: transform, size: size, in: &context)
            }
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
    /// Small enough that neighbours such as Monaco, San Marino, and the Vatican keep their own marks.
    static let smallMarkerRadius: CGFloat = 4

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

    /// A marker sits at the middle of a country too small to see, or at its fallback point when it has no shape;
    /// a country large enough to see needs none.
    func draw(
        _ marker: Marker,
        for countryCode: String,
        transform: CGAffineTransform,
        size: CGSize,
        in context: inout GraphicsContext
    ) {
        let center: CGPoint
        if let countryPath = outline.countryPaths[countryCode] {
            let screenBounds = countryPath.boundingBoxOfPath.applying(transform)
            guard max(screenBounds.width, screenBounds.height) < Self.tinyCountrySize else { return }
            center = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        } else if let fallbackPoint = marker.fallbackPoint {
            center = fallbackPoint.applying(transform)
        } else {
            return
        }
        guard CGRect(origin: .zero, size: size).contains(center) else { return }
        let radius = Self.smallMarkerRadius
        let circle = Path(ellipseIn: CGRect(origin: center, size: .zero).insetBy(dx: -radius, dy: -radius))
        switch marker.style {
        case .ring: context.stroke(circle, with: .color(marker.color), lineWidth: 1.5)
        case .dot: context.fill(circle, with: .color(marker.color))
        }
    }
}
