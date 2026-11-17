import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct MapCanvasView: View {
    // MARK: - Properties
    public let countryShapes: [CountryShape]
    public let scale: CGFloat
    public let offset: CGSize
    public var selectedCountryCode: String?
    /// Whether names are drawn on the countries. `MapViewport` turns this off and draws them in a layer of their own.
    public var showLabels: Bool
    public let canvasSize: CGSize
    public var capitalPoint: CGPoint?
    public var travelStatuses: [String: TravelStatus] = [:]
    /// Countries filled with `highlightColor` and outlined, such as the ones the user visited. The outline
    /// keeps them distinct from neighbors whose palette color happens to be close, and from color alone.
    public var highlightedCodes: Set<String> = []
    public var highlightColor: Color = DesignSystem.Color.success
    public var densityData: [String: Double] = [:]
    public var showDensityOverlay: Bool = false
    public var wrapsHorizontally: Bool = true
    /// Outlines every country in this color, a hairline at any zoom; nil leaves borders to the fills.
    public var borderColor: Color?
    /// Draws only the selected country and the capital pin, for `MapViewport`'s selection layer, so a tap
    /// redraws one country instead of the whole map.
    var drawsOnlySelection = false

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    // MARK: - Init
    public init(
        countryShapes: [CountryShape],
        scale: CGFloat,
        offset: CGSize,
        selectedCountryCode: String?,
        showLabels: Bool,
        canvasSize: CGSize,
        capitalPoint: CGPoint? = nil,
        travelStatuses: [String: TravelStatus] = [:],
        highlightedCodes: Set<String> = [],
        highlightColor: Color = DesignSystem.Color.success,
        densityData: [String: Double] = [:],
        showDensityOverlay: Bool = false,
        wrapsHorizontally: Bool = true,
        borderColor: Color? = nil
    ) {
        self.countryShapes = countryShapes
        self.scale = scale
        self.offset = offset
        self.selectedCountryCode = selectedCountryCode
        self.showLabels = showLabels
        self.canvasSize = canvasSize
        self.capitalPoint = capitalPoint
        self.travelStatuses = travelStatuses
        self.highlightedCodes = highlightedCodes
        self.highlightColor = highlightColor
        self.densityData = densityData
        self.showDensityOverlay = showDensityOverlay
        self.wrapsHorizontally = wrapsHorizontally
        self.borderColor = borderColor
    }

    // MARK: - Body
    public var body: some View {
        Canvas { context, size in
            let visibleRect = CGRect(origin: .zero, size: size)

            for horizontalCopy in horizontalOffsets {
                let transform = makeTransform(for: size, horizontalShift: horizontalCopy)

                var transformedContext = context
                transformedContext.concatenate(transform)

                if drawsOnlySelection {
                    drawSelectedCountry(in: &transformedContext, transform: transform, visibleRect: visibleRect)
                } else {
                    drawWorldOutline(in: &transformedContext)
                    drawAllCountries(in: &transformedContext, transform: transform, visibleRect: visibleRect)
                }

                if showLabels, !drawsOnlySelection {
                    drawLabels(in: &context, transform: transform, visibleRect: visibleRect)
                }

                if let capitalPoint {
                    drawCapitalPin(
                        in: &context,
                        at: capitalPoint,
                        transform: transform,
                        visibleRect: visibleRect
                    )
                }
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}

// MARK: - Drawing
private extension MapCanvasView {
    /// The Earth's edge, for projections whose world isn't a rectangle, so its rounded shape reads at a glance.
    func drawWorldOutline(in transformedContext: inout GraphicsContext) {
        guard let outline = MapProjection.worldOutline() else { return }
        let edge = Path { path in
            path.addLines(outline)
            path.closeSubpath()
        }
        transformedContext.fill(edge, with: .color(DesignSystem.Color.textPrimary.opacity(0.04)))
        let edgeColor = DesignSystem.Color.textTertiary.opacity(0.6)
        transformedContext.stroke(edge, with: .color(edgeColor), lineWidth: 1.2 / scale)
    }

    func drawAllCountries(
        in transformedContext: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        for shape in countryShapes {
            drawCountry(
                shape,
                in: &transformedContext,
                transform: transform,
                visibleRect: visibleRect
            )
        }
    }

    func drawSelectedCountry(
        in transformedContext: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        guard let selectedCountryCode,
              let shape = countryShapes.first(where: { $0.id == selectedCountryCode })
        else { return }
        drawCountry(shape, in: &transformedContext, transform: transform, visibleRect: visibleRect)
    }

    func drawCountry(
        _ shape: CountryShape,
        in transformedContext: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        let transformedBounds = shape.boundingBox.applying(transform)
        guard transformedBounds.intersects(visibleRect) else { return }

        let isSelected = shape.id == selectedCountryCode
        let isHighlighted = highlightedCodes.contains(shape.id)
        let baseColor = isHighlighted ? highlightColor : shape.color
        let strokeWidth = 2.0 / scale

        let paths = shape.detailPath(forScale: scale).map { [Path($0)] } ?? shape.polygons.map(Path.init)
        for path in paths {
            if showDensityOverlay, let density = densityData[shape.id] {
                transformedContext.fill(path, with: .color(densityHeatmapColor(for: density)))
            } else {
                let fillColor = isSelected || reduceTransparency ? baseColor.opacity(1) : baseColor.opacity(0.85)
                transformedContext.fill(path, with: .color(fillColor))
            }

            if !showDensityOverlay, let travelStatus = travelStatuses[shape.id] {
                transformedContext.fill(
                    path,
                    with: .color(travelStatus.color.opacity(0.35))
                )
                let outlineWidth = 1.5 / scale
                transformedContext.stroke(
                    path,
                    with: .color(travelStatus.color),
                    style: StrokeStyle(
                        lineWidth: outlineWidth,
                        dash: travelStatus.mapOutlineDash(lineWidth: outlineWidth)
                    )
                )
            }

            if let borderColor, !isHighlighted, !isSelected {
                transformedContext.stroke(path, with: .color(borderColor), lineWidth: 0.75 / scale)
            }

            if isHighlighted, !isSelected {
                transformedContext.stroke(
                    path,
                    with: .color(DesignSystem.Color.textPrimary.opacity(0.7)),
                    lineWidth: 1.0 / scale
                )
            }

            if isSelected {
                transformedContext.stroke(
                    path,
                    with: .color(DesignSystem.Color.onAccent),
                    lineWidth: strokeWidth
                )
            }
        }
    }

    func drawLabels(
        in context: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        MapLabelPainter.draw(countryShapes, in: &context, transform: transform, visibleRect: visibleRect)
    }
}

// MARK: - Capital Pin
private extension MapCanvasView {
    func drawCapitalPin(
        in context: inout GraphicsContext,
        at mapPoint: CGPoint,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        let screenPoint = mapPoint.applying(transform)
        guard visibleRect.contains(screenPoint) else { return }

        let pinSize: CGFloat = 8
        let outerSize: CGFloat = 14

        // Outer ring
        let outerRect = CGRect(
            x: screenPoint.x - outerSize / 2,
            y: screenPoint.y - outerSize / 2,
            width: outerSize,
            height: outerSize
        )
        context.fill(Path(ellipseIn: outerRect), with: .color(DesignSystem.Color.onAccent.opacity(0.4)))

        // Inner dot
        let innerRect = CGRect(
            x: screenPoint.x - pinSize / 2,
            y: screenPoint.y - pinSize / 2,
            width: pinSize,
            height: pinSize
        )
        context.fill(Path(ellipseIn: innerRect), with: .color(DesignSystem.Color.onAccent))
        context.stroke(
            Path(ellipseIn: innerRect),
            with: .color(DesignSystem.Color.textPrimary.opacity(0.3)),
            lineWidth: 1
        )
    }
}

// MARK: - Density Heatmap
private extension MapCanvasView {
    /// Maps population density (people/km²) to a color on a yellow→orange→red→dark-red gradient.
    /// Uses log10 scale since density spans 0.03 (Greenland) to 26000+ (Monaco).
    func densityHeatmapColor(for density: Double) -> Color {
        let logValue = log10(max(density, 0.01))
        // Normalize: log range roughly -2 (sparse) to 4 (very dense) → 0…1
        let normalized = min(max((logValue + 2.0) / 6.0, 0), 1)

        let red: Double
        let green: Double
        let blue: Double

        if normalized < 0.5 {
            // light yellow (1, 1, 0.7) → orange-red (1, 0.3, 0)
            let transition = normalized * 2
            red = 1.0
            green = 1.0 - transition * 0.7
            blue = 0.7 - transition * 0.7
        } else {
            // orange-red (1, 0.3, 0) → dark red (0.45, 0, 0)
            let transition = (normalized - 0.5) * 2
            red = 1.0 - transition * 0.55
            green = 0.3 - transition * 0.3
            blue = 0.0
        }

        return Color(red: red, green: green, blue: blue, opacity: 0.92)
    }
}

// MARK: - Helpers
private extension MapCanvasView {
    var horizontalOffsets: [CGFloat] {
        Self.horizontalOffsets(scale: scale, wrapsHorizontally: wrapsHorizontally)
    }

    func makeTransform(for size: CGSize, horizontalShift: CGFloat) -> CGAffineTransform {
        Self.transform(scale: scale, offset: offset, size: size, horizontalShift: horizontalShift)
    }
}

// MARK: - Geometry
extension MapCanvasView {
    /// The horizontal shifts of the copies drawn side by side, so the world wraps around when panned sideways.
    /// Only a rectangular world repeats sideways: Equal Earth's curved edges can't meet.
    static func horizontalOffsets(scale: CGFloat, wrapsHorizontally: Bool) -> [CGFloat] {
        guard wrapsHorizontally, MapProjection.current == .mercator else { return [0] }
        let mapWidthScaled = MapProjection.mapWidth * scale
        return [-mapWidthScaled, 0, mapWidthScaled]
    }

    /// Maps projected map coordinates to a view of `size`, with the map centered and then moved by `offset`.
    static func transform(
        scale: CGFloat,
        offset: CGSize,
        size: CGSize,
        horizontalShift: CGFloat
    ) -> CGAffineTransform {
        let centerX = size.width / 2 - (MapProjection.mapWidth * scale) / 2 + offset.width + horizontalShift
        let centerY = size.height / 2 - (MapProjection.mapHeight * scale) / 2 + offset.height

        return CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: centerX / scale, y: centerY / scale)
    }
}

// MARK: - Equatable
/// Lets a pan or pinch re-run the parent without redrawing the canvas, as long as what it draws is unchanged.
extension MapCanvasView: @MainActor Equatable {
    public static func == (lhs: MapCanvasView, rhs: MapCanvasView) -> Bool {
        lhs.scale == rhs.scale
            && lhs.offset == rhs.offset
            && lhs.canvasSize == rhs.canvasSize
            && lhs.selectedCountryCode == rhs.selectedCountryCode
            && lhs.showLabels == rhs.showLabels
            && lhs.capitalPoint == rhs.capitalPoint
            && lhs.wrapsHorizontally == rhs.wrapsHorizontally
            && lhs.borderColor == rhs.borderColor
            && lhs.showDensityOverlay == rhs.showDensityOverlay
            && lhs.highlightColor == rhs.highlightColor
            && lhs.highlightedCodes == rhs.highlightedCodes
            && lhs.travelStatuses == rhs.travelStatuses
            && lhs.densityData == rhs.densityData
            && lhs.drawsOnlySelection == rhs.drawsOnlySelection
            && drawSameShapes(lhs.countryShapes, rhs.countryShapes)
    }

    /// Shapes are drawn alike when they have the same countries, names, and colors; their outlines never change.
    private static func drawSameShapes(_ lhs: [CountryShape], _ rhs: [CountryShape]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy { left, right in
            left.id == right.id && left.color == right.color && left.name == right.name
        }
    }
}
