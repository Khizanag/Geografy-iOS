import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// A flat sketch of the route: both capitals in their side colors, joined by an arc drawn on appear.
/// Give it a new `id` per route so the arc draws again.
struct DistanceMapView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let origin: RouteMapView.Endpoint
    let destination: RouteMapView.Endpoint

    @State private var lineProgress: CGFloat = 0

    // MARK: - Body
    var body: some View {
        RouteMapView(origin: origin, destination: destination, lineProgress: lineProgress)
            .onAppear(perform: drawLine)
    }
}

// MARK: - Actions
private extension DistanceMapView {
    func drawLine() {
        guard !reduceMotion else {
            lineProgress = 1
            return
        }
        withAnimation(.easeInOut(duration: 1.2)) {
            lineProgress = 1
        }
    }
}

/// Draws the route; animatable so the arc grows as `lineProgress` animates.
struct RouteMapView: View, Animatable {
    struct Endpoint {
        let countryCode: String
        let label: String
    }

    // MARK: - Properties
    let origin: Endpoint
    let destination: Endpoint
    var lineProgress: CGFloat

    nonisolated var animatableData: CGFloat {
        get { lineProgress }
        set { lineProgress = newValue }
    }

    private static let inset: CGFloat = 20
    private static let dotSize: CGFloat = 10

    // MARK: - Body
    var body: some View {
        Canvas { context, size in
            drawGrid(in: context, size: size)
            guard let start = CapitalCoordinateService.coordinate(for: origin.countryCode),
                  let end = CapitalCoordinateService.coordinate(for: destination.countryCode) else { return }
            let startPoint = mapPoint(from: start, in: size)
            let endPoint = mapPoint(from: end, in: size)
            drawLine(in: context, from: startPoint, to: endPoint)
            drawEndpoint(in: context, size: size, at: startPoint, side: .left, label: origin.label)
            drawEndpoint(in: context, size: size, at: endPoint, side: .right, label: destination.label)
        }
        .background(DesignSystem.Color.cardBackground)
    }
}

// MARK: - Drawing
private extension RouteMapView {
    func mapPoint(from coordinate: CapitalCoordinateService.Coordinate, in size: CGSize) -> CGPoint {
        let usableWidth = size.width - Self.inset * 2
        let usableHeight = size.height - Self.inset * 2
        return CGPoint(
            x: Self.inset + CGFloat((coordinate.longitude + 180) / 360) * usableWidth,
            y: Self.inset + CGFloat((90 - coordinate.latitude) / 180) * usableHeight
        )
    }

    func drawGrid(in context: GraphicsContext, size: CGSize) {
        var gridContext = context
        gridContext.opacity = 0.08
        var path = Path()
        for column in 0...6 {
            let x = CGFloat(column) / 6 * size.width
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }
        for row in 0...4 {
            let y = CGFloat(row) / 4 * size.height
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }
        gridContext.stroke(path, with: .color(DesignSystem.Color.textPrimary), lineWidth: 0.5)
    }

    /// An arc bowed toward the top, colored from the origin's side to the destination's.
    func drawLine(in context: GraphicsContext, from startPoint: CGPoint, to endPoint: CGPoint) {
        let control = CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: max(min(startPoint.y, endPoint.y) - 40, 0)
        )
        var arc = Path()
        arc.move(to: startPoint)
        arc.addQuadCurve(to: endPoint, control: control)
        let path = arc.trimmedPath(from: 0, to: lineProgress)

        let shading = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [PairSide.left.color, PairSide.right.color]),
            startPoint: startPoint,
            endPoint: endPoint
        )
        var glowContext = context
        glowContext.opacity = 0.25
        glowContext.stroke(path, with: shading, style: StrokeStyle(lineWidth: 5, lineCap: .round))
        context.stroke(path, with: shading, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4]))
    }

    /// The dot plus its capital's name, so the two ends read apart without relying on color.
    /// The origin's name sits above its dot and the destination's below, unless that would run off the map.
    func drawEndpoint(
        in context: GraphicsContext,
        size: CGSize,
        at point: CGPoint,
        side: PairSide,
        label: String
    ) {
        let dotRect = CGRect(
            x: point.x - Self.dotSize / 2,
            y: point.y - Self.dotSize / 2,
            width: Self.dotSize,
            height: Self.dotSize
        )
        context.fill(Path(ellipseIn: dotRect), with: .color(side.color))
        context.fill(Path(ellipseIn: dotRect.insetBy(dx: 3, dy: 3)), with: .color(DesignSystem.Color.cardBackground))

        let text = context.resolve(
            Text(label)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        )
        let offset = Self.dotSize / 2 + DesignSystem.Spacing.xxs
        let textHeight = text.measure(in: size).height
        let fitsAbove = point.y - offset - textHeight >= 0
        let fitsBelow = point.y + offset + textHeight <= size.height
        let prefersBelow = side == .right
        let below = prefersBelow ? fitsBelow || !fitsAbove : !fitsAbove && fitsBelow
        let isLeadingHalf = point.x < size.width / 2
        let anchor: UnitPoint = switch (below, isLeadingHalf) {
        case (false, true): .bottomLeading
        case (false, false): .bottomTrailing
        case (true, true): .topLeading
        case (true, false): .topTrailing
        }
        let labelPoint = CGPoint(
            x: point.x + (isLeadingHalf ? -Self.dotSize / 2 : Self.dotSize / 2),
            y: below ? point.y + offset : point.y - offset
        )
        context.draw(text, at: labelPoint, anchor: anchor)
    }
}
