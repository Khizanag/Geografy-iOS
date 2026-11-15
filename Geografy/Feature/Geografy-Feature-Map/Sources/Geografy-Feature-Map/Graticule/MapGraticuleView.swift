import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Latitude and longitude lines over a map, with their degrees, when the setting is on.
///
/// Drawn at the map's current scale and offset on every frame, so lines stay crisp and labels stay
/// at the screen's edge through a pan or pinch. Latitudes are named along the leading edge, longitudes
/// along the equator when it's on screen, otherwise across the middle, clear of the bars at the top and bottom.
public struct MapGraticuleView: View {
    // MARK: - Properties
    @AppStorage(MapPreferences.showsGraticuleKey) private var isShown = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale

    private let scale: CGFloat
    private let offset: CGSize
    private let wrapsHorizontally: Bool

    // MARK: - Init
    /// - Parameters:
    ///   - scale: The map's scale, as drawn now.
    ///   - offset: The map's offset, as drawn now.
    public init(scale: CGFloat, offset: CGSize, wrapsHorizontally: Bool = true) {
        self.scale = scale
        self.offset = offset
        self.wrapsHorizontally = wrapsHorizontally
    }

    // MARK: - Body
    public var body: some View {
        if isShown {
            Canvas { context, size in
                draw(in: &context, size: size)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .transition(.opacity)
        }
    }
}

// MARK: - Drawing
private extension MapGraticuleView {
    /// Room the latitude labels take along the leading edge.
    static let latitudeLabelWidth: CGFloat = 72
    static let labelRowGap: CGFloat = 11
    static let labelGap: CGFloat = 6

    var lineColor: Color { DesignSystem.Color.textPrimary }

    func draw(in context: inout GraphicsContext, size: CGSize) {
        let projection = MapProjection.current
        let placement = MapGraticule.Placement(scale: scale, offset: offset, size: size, projection: projection)
        let step = MapGraticule.step(forScale: scale)

        let topLatitude = min(placement.latitude(atY: 0), MapGraticule.latitudeLimit)
        let bottomLatitude = max(placement.latitude(atY: size.height), -MapGraticule.latitudeLimit)
        let latitudes = MapGraticule.values(from: bottomLatitude, to: topLatitude, step: step)
        let longitudeRange = visibleLongitudes(placement: placement, size: size, projection: projection)
        let longitudes = MapGraticule.values(from: longitudeRange.lowerBound, to: longitudeRange.upperBound, step: step)

        for latitude in latitudes {
            let parallel = parallelPath(latitude, across: longitudeRange, placement: placement)
            stroke(parallel, isPrimary: latitude == 0, in: context)
        }
        for longitude in longitudes {
            let meridian = meridianPath(longitude, from: bottomLatitude, to: topLatitude, placement: placement)
            stroke(meridian, isPrimary: MapGraticule.normalizedLongitude(longitude) == 0, in: context)
        }
        drawSpecialLatitudes(
            placement: placement,
            longitudes: longitudeRange,
            size: size,
            range: bottomLatitude...topLatitude,
            in: &context
        )

        for latitude in latitudes {
            drawLatitudeLabel(latitude, step: step, y: placement.y(forLatitude: latitude), in: &context)
        }
        // Just above the equator, so the row reads as its scale and clears the Tropic of Capricorn's name below;
        // it moves to the middle when the equator is off screen.
        let equator = placement.y(forLatitude: 0)
        let isEquatorCentral = (size.height * 0.25...size.height * 0.75).contains(equator)
        let labelRow = isEquatorCentral ? equator - Self.labelRowGap : size.height / 2
        let rowLatitude = placement.latitude(atY: labelRow)
        let labelStride = MapGraticule.labelStride(forScale: scale, step: step)
        var previousLabelEnd = -CGFloat.infinity
        for longitude in longitudes where Int((longitude / step).rounded()).isMultiple(of: labelStride) {
            let point = CGPoint(x: placement.x(forLongitude: longitude, atLatitude: rowLatitude), y: labelRow)
            // Labels skip rather than touch, however long the language writes them.
            let leadingEdge = max(Self.latitudeLabelWidth, previousLabelEnd + Self.labelGap)
            if let drawn = drawLongitudeLabel(longitude, step: step, at: point, clearOf: leadingEdge, in: &context) {
                previousLabelEnd = drawn.maxX
            }
        }
    }

    /// The longitudes on screen. Equal Earth's meridians lean outward toward the poles, so the screen's
    /// corners can show wider longitudes than its middle; a world that doesn't repeat stops at ±180°.
    func visibleLongitudes(
        placement: MapGraticule.Placement,
        size: CGSize,
        projection: MapProjectionKind
    ) -> ClosedRange<Double> {
        let rows: [CGFloat] = [0, size.height / 2, size.height, placement.y(forLatitude: 0)]
        let samples = rows.flatMap { y in
            [placement.longitude(atX: 0, y: y), placement.longitude(atX: size.width, y: y)]
        }
        var west = samples.min() ?? -180
        var east = samples.max() ?? 180
        if !wrapsHorizontally || projection != .mercator {
            west = max(west, -180)
            east = min(east, 180)
        }
        return west...max(west, east)
    }

    func parallelPath(
        _ latitude: Double,
        across longitudes: ClosedRange<Double>,
        placement: MapGraticule.Placement
    ) -> Path {
        Path { path in
            path.move(to: placement.point(longitude: longitudes.lowerBound, latitude: latitude))
            path.addLine(to: placement.point(longitude: longitudes.upperBound, latitude: latitude))
        }
    }

    /// Traced in short steps, so it follows Equal Earth's curve; on Mercator the steps fall on one straight line.
    func meridianPath(
        _ longitude: Double,
        from southLatitude: Double,
        to northLatitude: Double,
        placement: MapGraticule.Placement
    ) -> Path {
        let segments = 32
        return Path { path in
            for index in 0...segments {
                let latitude = southLatitude + (northLatitude - southLatitude) * Double(index) / Double(segments)
                let point = placement.point(longitude: longitude, latitude: latitude)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }

    func stroke(_ line: Path, isPrimary: Bool, in context: GraphicsContext) {
        context.stroke(
            line,
            with: .color(lineColor.opacity(isPrimary ? 0.45 : 0.2)),
            lineWidth: isPrimary ? 1.2 : 0.6
        )
    }

    /// The Tropics and polar circles: dashed, and named where they meet the trailing edge.
    func drawSpecialLatitudes(
        placement: MapGraticule.Placement,
        longitudes: ClosedRange<Double>,
        size: CGSize,
        range: ClosedRange<Double>,
        in context: inout GraphicsContext
    ) {
        for special in MapGraticule.specialLatitudes where range.contains(special.latitude) {
            let y = placement.y(forLatitude: special.latitude)
            let line = parallelPath(special.latitude, across: longitudes, placement: placement)
            context.stroke(
                line,
                with: .color(lineColor.opacity(0.35)),
                style: StrokeStyle(lineWidth: 0.8, dash: [5, 4])
            )
            let name = context.resolve(
                Text(LocalizedStringKey(special.name))
                    .font(DesignSystem.Font.caption2)
                    .italic()
                    .foregroundStyle(lineColor.opacity(0.6))
            )
            context.draw(name, at: CGPoint(x: size.width - DesignSystem.Spacing.sm, y: y - 2), anchor: .bottomTrailing)
        }
    }

    func drawLatitudeLabel(_ latitude: Double, step: Double, y: CGFloat, in context: inout GraphicsContext) {
        let degrees = MapGraticule.degrees(latitude, step: step, locale: locale)
        let text: Text = switch latitude {
        case 0: Text("0°")
        case ..<0: Text("\(degrees)°S")
        default: Text("\(degrees)°N")
        }
        drawLabel(text, at: CGPoint(x: DesignSystem.Spacing.xs, y: y), anchor: .leading, in: &context)
    }

    func drawLongitudeLabel(
        _ longitude: Double,
        step: Double,
        at point: CGPoint,
        clearOf leadingEdge: CGFloat,
        in context: inout GraphicsContext
    ) -> CGRect? {
        let normalized = MapGraticule.normalizedLongitude(longitude)
        let degrees = MapGraticule.degrees(normalized, step: step, locale: locale)
        let text: Text = switch normalized {
        case 0: Text("0°")
        case -180, 180: Text("180°")
        case ..<0: Text("\(degrees)°W")
        default: Text("\(degrees)°E")
        }
        return drawLabel(text, at: point, anchor: .center, keepingClearOf: leadingEdge, in: &context)
    }

    /// A small label on a translucent pill, readable over land and sea alike. A label that would run off
    /// the screen, or into the latitude labels along the leading edge, is left out rather than cut.
    @discardableResult
    func drawLabel(
        _ text: Text,
        at point: CGPoint,
        anchor: UnitPoint,
        keepingClearOf leadingReserve: CGFloat = 0,
        in context: inout GraphicsContext
    ) -> CGRect? {
        let label = context.resolve(
            text
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(DesignSystem.Color.textSecondary)
        )
        let size = label.measure(in: CGSize(width: 200, height: 40))
        let padding = CGSize(width: 5, height: 2)
        let origin = CGPoint(
            x: point.x - size.width * anchor.x - padding.width * (anchor.x * 2),
            y: point.y - size.height / 2 - padding.height
        )
        let pill = CGRect(
            origin: origin,
            size: CGSize(width: size.width + padding.width * 2, height: size.height + padding.height * 2)
        )
        guard pill.minX >= leadingReserve, pill.maxX <= context.clipBoundingRect.maxX - 2 else { return nil }
        let fill = DesignSystem.Color.background.opacity(colorScheme == .dark ? 0.6 : 0.75)
        context.fill(Path(roundedRect: pill, cornerRadius: pill.height / 2), with: .color(fill))
        context.draw(label, at: CGPoint(x: pill.midX, y: pill.midY), anchor: .center)
        return pill
    }
}
