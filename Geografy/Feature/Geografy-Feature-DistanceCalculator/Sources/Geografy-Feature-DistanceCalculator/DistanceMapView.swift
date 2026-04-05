import Geografy_Core_Navigation
#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct DistanceMapView: View {
    // MARK: - Properties
    let originCode: String?
    let destinationCode: String?
    let lineProgress: CGFloat

    // MARK: - Body
    var body: some View {
        Canvas { context, size in
            drawBackground(in: context, size: size)
            if let origin = originCoordinate, let destination = destinationCoordinate {
                drawLine(in: context, size: size, from: origin, to: destination)
                drawDot(
                    in: context, size: size,
                    coordinate: origin,
                    color: DesignSystem.Color.accent,
                    label: originCode ?? ""
                )
                drawDot(
                    in: context, size: size,
                    coordinate: destination,
                    color: DesignSystem.Color.error,
                    label: destinationCode ?? ""
                )
            }
        }
        .background(DesignSystem.Color.cardBackground)
    }
}

// MARK: - Drawing
private extension DistanceMapView {
    func mapPoint(from coordinate: CapitalCoordinateService.Coordinate, in size: CGSize) -> CGPoint {
        let padding: CGFloat = 20
        let usableWidth = size.width - padding * 2
        let usableHeight = size.height - padding * 2
        let x = padding + CGFloat((coordinate.longitude + 180) / 360) * usableWidth
        let y = padding + CGFloat((90 - coordinate.latitude) / 180) * usableHeight
        return CGPoint(x: x, y: y)
    }

    func drawBackground(in context: GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(Path(rect), with: .color(DesignSystem.Color.cardBackground))

        var gridContext = context
        gridContext.opacity = 0.06
        for i in stride(from: 0, through: 6, by: 1) {
            let x = CGFloat(i) / 6.0 * size.width
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            gridContext.stroke(path, with: .color(DesignSystem.Color.textPrimary), lineWidth: 0.5)
        }
        for i in stride(from: 0, through: 4, by: 1) {
            let y = CGFloat(i) / 4.0 * size.height
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            gridContext.stroke(path, with: .color(DesignSystem.Color.textPrimary), lineWidth: 0.5)
        }
    }

    func drawLine(
        in context: GraphicsContext,
        size: CGSize,
        from origin: CapitalCoordinateService.Coordinate,
        to destination: CapitalCoordinateService.Coordinate
    ) {
        let startPoint = mapPoint(from: origin, in: size)
        let endPoint = mapPoint(from: destination, in: size)
        let currentEnd = CGPoint(
            x: startPoint.x + (endPoint.x - startPoint.x) * lineProgress,
            y: startPoint.y + (endPoint.y - startPoint.y) * lineProgress
        )

        let midX = (startPoint.x + endPoint.x) / 2
        let midY = min(startPoint.y, endPoint.y) - 40
        let controlPoint = CGPoint(x: midX, y: midY)

        var path = Path()
        path.move(to: startPoint)
        path.addQuadCurve(to: currentEnd, control: controlPoint)

        var shadowContext = context
        shadowContext.opacity = 0.3
        shadowContext.stroke(
            path,
            with: .color(DesignSystem.Color.accent),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
        )
        context.stroke(
            path,
            with: .color(DesignSystem.Color.accent),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4])
        )
    }

    func drawDot(
        in context: GraphicsContext,
        size: CGSize,
        coordinate: CapitalCoordinateService.Coordinate,
        color: Color,
        label: String
    ) {
        let point = mapPoint(from: coordinate, in: size)
        let dotSize: CGFloat = 10
        let dotRect = CGRect(
            x: point.x - dotSize / 2,
            y: point.y - dotSize / 2,
            width: dotSize,
            height: dotSize
        )

        context.fill(Path(ellipseIn: dotRect), with: .color(color))
        context.fill(
            Path(ellipseIn: dotRect.insetBy(dx: 3, dy: 3)),
            with: .color(.white)
        )
    }

    var originCoordinate: CapitalCoordinateService.Coordinate? {
        guard let code = originCode else { return nil }
        return CapitalCoordinateService.coordinate(for: code)
    }

    var destinationCoordinate: CapitalCoordinateService.Coordinate? {
        guard let code = destinationCode else { return nil }
        return CapitalCoordinateService.coordinate(for: code)
    }
}
#endif
