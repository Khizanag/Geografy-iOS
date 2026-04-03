import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct MapCanvasView: View {
    public let countryShapes: [CountryShape]
    public let scale: CGFloat
    public let offset: CGSize
    public let selectedCountryCode: String?
    public let showLabels: Bool
    public let canvasSize: CGSize
    public var capitalPoint: CGPoint?
    public var travelStatuses: [String: TravelStatus] = [:]
    public var densityData: [String: Double] = [:]
    public var showDensityOverlay: Bool = false

    public init(
        countryShapes: [CountryShape],
        scale: CGFloat,
        offset: CGSize,
        selectedCountryCode: String?,
        showLabels: Bool,
        canvasSize: CGSize,
        capitalPoint: CGPoint? = nil,
        travelStatuses: [String: TravelStatus] = [:],
        densityData: [String: Double] = [:],
        showDensityOverlay: Bool = false
    ) {
        self.countryShapes = countryShapes
        self.scale = scale
        self.offset = offset
        self.selectedCountryCode = selectedCountryCode
        self.showLabels = showLabels
        self.canvasSize = canvasSize
        self.capitalPoint = capitalPoint
        self.travelStatuses = travelStatuses
        self.densityData = densityData
        self.showDensityOverlay = showDensityOverlay
    }

    public var body: some View {
        Canvas { context, size in
            let visibleRect = CGRect(origin: .zero, size: size)

            for horizontalCopy in horizontalOffsets {
                let transform = makeTransform(for: size, horizontalShift: horizontalCopy)

                var transformedContext = context
                transformedContext.concatenate(transform)

                drawAllCountries(
                    in: &transformedContext,
                    transform: transform,
                    visibleRect: visibleRect
                )

                if showLabels {
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

    func drawCountry(
        _ shape: CountryShape,
        in transformedContext: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        let transformedBounds = shape.boundingBox.applying(transform)
        guard transformedBounds.intersects(visibleRect) else { return }

        let isSelected = shape.id == selectedCountryCode
        let strokeWidth = 2.0 / scale

        for cgPath in shape.polygons {
            let path = Path(cgPath)

            if showDensityOverlay, let density = densityData[shape.id] {
                transformedContext.fill(path, with: .color(densityHeatmapColor(for: density)))
            } else {
                let fillColor = isSelected ? shape.color.opacity(1) : shape.color.opacity(0.85)
                transformedContext.fill(path, with: .color(fillColor))
            }

            if !showDensityOverlay, let travelStatus = travelStatuses[shape.id] {
                transformedContext.fill(
                    path,
                    with: .color(travelStatus.color.opacity(0.35))
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
        let minLabelWidth: CGFloat = 40

        for shape in countryShapes {
            let transformedBounds = shape.boundingBox.applying(transform)

            guard transformedBounds.width > minLabelWidth,
                  transformedBounds.intersects(visibleRect) else { continue }

            // Clamp the centroid within the country's transformed bounding box so labels
            // never appear outside narrow or geographically non-convex countries (e.g. UAE, Chile).
            let rawPoint = shape.centroid.applying(transform)
            let insetBounds = transformedBounds.insetBy(dx: 2, dy: 2)
            let point = CGPoint(
                x: max(insetBounds.minX, min(rawPoint.x, insetBounds.maxX)),
                y: max(insetBounds.minY, min(rawPoint.y, insetBounds.maxY))
            )

            guard visibleRect.contains(point) else { continue }

            let fontSize = min(max(transformedBounds.width / CGFloat(shape.name.count), 6), 14)

            var shadowContext = context
            shadowContext.opacity = 0.7
            shadowContext.draw(
                shadowContext.resolve(
                    Text(shape.name)
                        .font(DesignSystem.Font.system(size: fontSize, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                ),
                at: CGPoint(x: point.x + 0.5, y: point.y + 0.5),
                anchor: .center
            )

            context.draw(
                context.resolve(
                    Text(shape.name)
                        .font(DesignSystem.Font.system(size: fontSize, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.onAccent)
                ),
                at: point,
                anchor: .center
            )
        }
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
        let mapWidthScaled = MapProjection.mapWidth * scale
        return [-mapWidthScaled, 0, mapWidthScaled]
    }

    func makeTransform(for size: CGSize, horizontalShift: CGFloat) -> CGAffineTransform {
        let centerX = size.width / 2 - (MapProjection.mapWidth * scale) / 2 + offset.width + horizontalShift
        let centerY = size.height / 2 - (MapProjection.mapHeight * scale) / 2 + offset.height

        return CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: centerX / scale, y: centerY / scale)
    }
}
