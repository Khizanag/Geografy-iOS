import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import SwiftUI

/// The Pin Drop map with everything placed on it: the pin, and once a guess is in, the line to the
/// country's border, the distance, and the country's flag.
///
/// The camera is this view's animatable data, so when it flies to a new frame the map, the pin,
/// and the line move frame by frame together. The map itself is drawn once, at `drawnFrame`,
/// and moved by a transform until the flight ends.
struct PinDropMapLayer: View, Animatable {
    // MARK: - Properties
    @Environment(\.locale) private var locale

    var camera: MapFrame
    let drawnFrame: MapFrame
    let size: CGSize
    let shapes: [CountryShape]
    let pin: CGPoint?
    /// The country picked so far, when the player picks countries; it's lit instead of a pin shown.
    let selectedCountryCode: String?
    let dropCount: Int
    let result: PinDropGame.Result?
    let lineProgress: CGFloat
    let borderColor: Color?

    nonisolated var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(camera.scale, AnimatablePair(camera.offset.width, camera.offset.height)) }
        set {
            camera = MapFrame(
                scale: newValue.first,
                offset: CGSize(width: newValue.second.first, height: newValue.second.second)
            )
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            map
            MapGraticuleView(scale: camera.scale, offset: camera.offset, wrapsHorizontally: false)
                .frame(width: size.width, height: size.height)
            if let result {
                if !result.isInside {
                    guideLine(for: result)
                    distanceLabel(for: result)
                }
                targetMarker(for: result)
            }
            if let pin {
                if selectedCountryCode == nil, result?.guessedCountryCode == nil {
                    pinMarker(at: pin)
                } else if let result, !result.isInside {
                    guessMarker(at: pin)
                }
                if let result, result.isInside {
                    PinDropBurstView(color: result.score.rating.color)
                        .position(screenPoint(pin))
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }
}

// MARK: - Map
private extension PinDropMapLayer {
    var map: some View {
        let (magnification, shift) = drawnFrame.transform(to: camera)
        return MapCanvasView(
            countryShapes: shapes,
            scale: drawnFrame.scale,
            offset: drawnFrame.offset,
            // A wrong pick stays outlined next to the answer.
            selectedCountryCode: result?.isInside == false ? result?.guessedCountryCode : nil,
            showLabels: false,
            canvasSize: MapFrame.drawnSize(for: size),
            highlightedCodes: highlightedCodes,
            highlightColor: result?.score.rating.color ?? PinDropStyle.gameColor,
            wrapsHorizontally: false,
            borderColor: borderColor
        )
        .equatable()
        .scaleEffect(magnification)
        .offset(shift)
        .frame(width: size.width, height: size.height)
    }

    /// The answer once revealed; before that, the country picked.
    var highlightedCodes: Set<String> {
        if let result { return [result.round.id] }
        return selectedCountryCode.map { [$0] } ?? []
    }

    func screenPoint(_ mapPoint: CGPoint) -> CGPoint {
        PinDropCamera.screenPoint(of: mapPoint, frame: camera, in: size)
    }
}

// MARK: - Pin
private extension PinDropMapLayer {
    func pinMarker(at mapPoint: CGPoint) -> some View {
        let tip = screenPoint(mapPoint)
        let pinHeight = PinDropPinView.headDiameter + PinDropPinView.needleLength
        return PinDropPinView(dropCount: dropCount)
            .position(x: tip.x, y: tip.y - pinHeight / 2)
    }

    /// Where a wrong country pick is measured from: a dot in its middle.
    func guessMarker(at mapPoint: CGPoint) -> some View {
        Circle()
            .fill(PinDropStyle.gameColor)
            .overlay { Circle().strokeBorder(.white, lineWidth: 2.5) }
            .frame(width: 14, height: 14)
            .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
            .position(screenPoint(mapPoint))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

// MARK: - Reveal
private extension PinDropMapLayer {
    func guideLine(for result: PinDropGame.Result) -> some View {
        let start = screenPoint(result.pin)
        let end = screenPoint(result.nearestPoint)
        let line = Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        return ZStack {
            line
                .trim(from: 0, to: lineProgress)
                .stroke(.black.opacity(0.35), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            line
                .trim(from: 0, to: lineProgress)
                .stroke(.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [7, 6]))
            Circle()
                .fill(.white)
                .frame(width: 9, height: 9)
                .shadow(color: .black.opacity(0.3), radius: 2)
                .position(end)
                .opacity(lineProgress >= 1 ? 1 : 0)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    func distanceLabel(for result: PinDropGame.Result) -> some View {
        let start = screenPoint(result.pin)
        let end = screenPoint(result.nearestPoint)
        // On a short line the label would sit on the pin, so it goes under the pin's tip instead.
        let isShort = hypot(end.x - start.x, end.y - start.y) < 90
        let anchor = isShort
            ? CGPoint(x: start.x, y: start.y + DesignSystem.Spacing.xl + DesignSystem.Spacing.md)
            : CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        return Text(verbatim: PinDropStyle.distance(result.distanceKilometers, locale: locale))
            .font(DesignSystem.Font.footnote)
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .glassEffect(.regular, in: .capsule)
            .position(x: anchor.x, y: anchor.y - DesignSystem.Spacing.md)
            .opacity(lineProgress >= 1 ? 1 : 0)
            .scaleEffect(lineProgress >= 1 ? 1 : 0.6)
            .animation(.snappy, value: lineProgress >= 1)
            .accessibilityHidden(true)
    }

    /// The country's flag on a short stem above its middle, so it never covers a small country.
    func targetMarker(for result: PinDropGame.Result) -> some View {
        let center = screenPoint(result.round.shape.centroid)
        let stem: CGFloat = 22
        return ZStack {
            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(x: center.x, y: center.y - stem))
            }
            .stroke(.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .shadow(color: .black.opacity(0.3), radius: 1.5)
            Circle()
                .fill(.white)
                .frame(width: 7, height: 7)
                .shadow(color: .black.opacity(0.3), radius: 1.5)
                .position(center)
            FlagView(countryCode: result.round.id, height: 22)
                .frame(width: 30, height: 30)
                .clipShape(.circle)
                .overlay { Circle().strokeBorder(.white, lineWidth: 2.5) }
                .shadow(color: .black.opacity(0.35), radius: 5, y: 3)
                .position(x: center.x, y: center.y - stem - 15)
        }
        .transition(.scale.combined(with: .opacity))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
