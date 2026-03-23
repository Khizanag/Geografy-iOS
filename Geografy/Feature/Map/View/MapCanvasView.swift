import SwiftUI

struct MapCanvasView: View {
    let countryShapes: [CountryShape]
    let scale: CGFloat
    let offset: CGSize
    let selectedCountryCode: String?
    let showLabels: Bool
    let canvasSize: CGSize
    var capitalPoint: CGPoint?
    var travelStatuses: [String: TravelStatus] = [:]
    var densityData: [String: Double] = [:]
    var showDensityOverlay: Bool = false

    var body: some View {
        Canvas { context, size in
            let visibleRect = CGRect(origin: .zero, size: size)

            for horizontalCopy in horizontalOffsets {
                let transform = makeTransform(for: size, horizontalShift: horizontalCopy)
                drawAllCountries(in: &context, transform: transform, visibleRect: visibleRect)

                if showLabels {
                    drawLabels(in: &context, transform: transform, visibleRect: visibleRect)
                }

                if let capitalPoint {
                    drawCapitalPin(in: &context, at: capitalPoint, transform: transform, visibleRect: visibleRect)
                }
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}

// MARK: - Drawing

private extension MapCanvasView {
    func drawAllCountries(
        in context: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        for shape in countryShapes {
            drawCountry(shape, in: &context, transform: transform, visibleRect: visibleRect)
        }
    }

    func drawCountry(
        _ shape: CountryShape,
        in context: inout GraphicsContext,
        transform: CGAffineTransform,
        visibleRect: CGRect
    ) {
        let transformedBounds = shape.boundingBox.applying(transform)
        guard transformedBounds.intersects(visibleRect) else { return }

        let isSelected = shape.id == selectedCountryCode

        for cgPath in shape.polygons {
            var path = Path(cgPath)
            path = path.applying(transform)

            if showDensityOverlay, let density = densityData[shape.id] {
                context.fill(path, with: .color(densityHeatmapColor(for: density)))
            } else {
                let fillColor = isSelected ? shape.color.opacity(1) : shape.color.opacity(0.85)
                context.fill(path, with: .color(fillColor))
            }

            if !showDensityOverlay, let travelStatus = travelStatuses[shape.id] {
                context.fill(path, with: .color(travelStatus.color.opacity(0.35)))
            }

            if isSelected {
                context.stroke(path, with: .color(.white), lineWidth: 2)
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
                        .font(.system(size: fontSize, weight: .semibold))
                        .foregroundStyle(.black)
                ),
                at: CGPoint(x: point.x + 0.5, y: point.y + 0.5),
                anchor: .center
            )

            context.draw(
                context.resolve(
                    Text(shape.name)
                        .font(.system(size: fontSize, weight: .semibold))
                        .foregroundStyle(.white)
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
        context.fill(Path(ellipseIn: outerRect), with: .color(.white.opacity(0.4)))

        // Inner dot
        let innerRect = CGRect(
            x: screenPoint.x - pinSize / 2,
            y: screenPoint.y - pinSize / 2,
            width: pinSize,
            height: pinSize
        )
        context.fill(Path(ellipseIn: innerRect), with: .color(.white))
        context.stroke(Path(ellipseIn: innerRect), with: .color(.black.opacity(0.3)), lineWidth: 1)
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

        guard mapWidthScaled < canvasSize.width * 1.5 else {
            return [0]
        }

        return [-mapWidthScaled, 0, mapWidthScaled]
    }

    func makeTransform(for size: CGSize, horizontalShift: CGFloat) -> CGAffineTransform {
        let centerX = size.width / 2 - (MapProjection.mapWidth * scale) / 2 + offset.width + horizontalShift
        let centerY = size.height / 2 - (MapProjection.mapHeight * scale) / 2 + offset.height

        return CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: centerX / scale, y: centerY / scale)
    }
}
