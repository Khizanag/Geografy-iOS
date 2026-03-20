import SwiftUI

struct MapCanvasView: View {
    let countryShapes: [CountryShape]
    let scale: CGFloat
    let offset: CGSize
    let selectedCountryCode: String?
    let showLabels: Bool
    let canvasSize: CGSize

    var body: some View {
        Canvas { context, size in
            let visibleRect = CGRect(origin: .zero, size: size)

            for horizontalCopy in horizontalOffsets {
                let transform = makeTransform(for: size, horizontalShift: horizontalCopy)
                drawAllCountries(in: &context, transform: transform, visibleRect: visibleRect)

                if showLabels {
                    drawLabels(in: &context, transform: transform, visibleRect: visibleRect)
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

            let fillColor = isSelected ? shape.color.opacity(1) : shape.color.opacity(0.85)
            context.fill(path, with: .color(fillColor))

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

            let point = shape.centroid.applying(transform)
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
