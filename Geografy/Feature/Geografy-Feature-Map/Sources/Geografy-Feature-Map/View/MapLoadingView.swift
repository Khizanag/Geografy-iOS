import Geografy_Core_DesignSystem
import SwiftUI

public struct MapLoadingView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var isAnimating = false
    @State private var blobAnimating = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        mainContent
            .background { oceanBackground }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                isAnimating = true
                blobAnimating = true
            }
    }
}

// MARK: - Subviews
private extension MapLoadingView {
    var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()
            globeSection
                .padding(.bottom, DesignSystem.Spacing.lg)
            textSection
                .padding(.bottom, 40)
            Spacer()
            copyrightLabel
                .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }

    var oceanBackground: some View {
        ZStack {
            DesignSystem.Color.ocean
                .ignoresSafeArea()

            if !reduceTransparency {
                glowBlobs
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 5).repeatForever(autoreverses: true), value: blobAnimating)
    }

    var glowBlobs: some View {
        ZStack {
            glowBlob(
                color: DesignSystem.Color.accent.opacity(0.18),
                endRadius: 200,
                size: CGSize(width: 400, height: 300),
                blur: 40
            )
            .offset(x: -80, y: -180)
            .scaleEffect(blobAnimating ? 1.10 : 0.90)

            glowBlob(
                color: DesignSystem.Color.blue.opacity(0.22),
                endRadius: 180,
                size: CGSize(width: 360, height: 280),
                blur: 36
            )
            .offset(x: 120, y: 80)
            .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .accessibilityHidden(true)
    }

    var globeSection: some View {
        ZStack {
            pulseRings
            globeIcon
        }
    }

    var pulseRings: some View {
        ZStack {
            pulseRing(size: 200, opacity: 0.06, delay: 0.00)
            pulseRing(size: 160, opacity: 0.10, delay: 0.15)
            pulseRing(size: 120, opacity: 0.16, delay: 0.30)
            pulseRing(size: 84, opacity: 0.22, delay: 0.45)
        }
    }

    var globeIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.20))
                .frame(width: 76, height: 76)
            Image(systemName: "globe.americas.fill")
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(DesignSystem.Color.accent)
                .rotationEffect(.degrees(isAnimating ? 12 : -12))
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }

    var textSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: 0) {
                Text("Loading map")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.90))

                TimelineView(.periodic(from: .now, by: 0.4)) { timeline in
                    Text(dotString(at: timeline.date))
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .frame(width: 28, alignment: .leading)
                }
            }

            Text("Parsing geographic data")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.45))
        }
    }

    var copyrightLabel: some View {
        Text("Map data © OpenStreetMap contributors · Geografy")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.30))
            .multilineTextAlignment(.center)
    }

    func dotString(at date: Date) -> String {
        let dotPhase = Int(date.timeIntervalSinceReferenceDate / 0.4) % 3
        return String(repeating: ".", count: dotPhase + 1)
    }

    // Each blob is blurred once into its own layer, padded so the blur isn't clipped;
    // the breathing animation then only scales that layer instead of re-blurring every frame.
    func glowBlob(color: Color, endRadius: CGFloat, size: CGSize, blur: CGFloat) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color, .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: endRadius
                )
            )
            .frame(width: size.width, height: size.height)
            .blur(radius: blur)
            .padding(blur)
            .drawingGroup()
    }

    func pulseRing(size: CGFloat, opacity: Double, delay: Double) -> some View {
        Circle()
            .fill(DesignSystem.Color.accent.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.14 : 0.86)
            .opacity(isAnimating ? 1.0 : 0.4)
            .animation(
                reduceMotion
                    ? nil
                    : .easeInOut(duration: 0.7)
                        .repeatForever(autoreverses: true)
                        .delay(delay),
                value: isAnimating
            )
    }
}
