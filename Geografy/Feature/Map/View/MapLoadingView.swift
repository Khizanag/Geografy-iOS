import SwiftUI

struct MapLoadingView: View {
    @State private var isAnimating = false
    @State private var dotPhase = 0
    @State private var blobAnimating = false

    var body: some View {
        ZStack {
            oceanBackground
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
        .onReceive(Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()) { _ in
            dotPhase = (dotPhase + 1) % 3
        }
    }
}

// MARK: - Subviews
private extension MapLoadingView {
    var oceanBackground: some View {
        ZStack {
            DesignSystem.Color.ocean
                .ignoresSafeArea()

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 40)
                .offset(x: -80, y: -180)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 36)
                .offset(x: 120, y: 80)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
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
                    .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }

    var textSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: 0) {
                Text("Loading map")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(.white.opacity(0.90))

                Text(dotString)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: 28, alignment: .leading)
                    .animation(nil, value: dotPhase)
            }

            Text("Parsing geographic data")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    var copyrightLabel: some View {
        Text("Map data © OpenStreetMap contributors · Geografy")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(.white.opacity(0.30))
            .multilineTextAlignment(.center)
    }

    var dotString: String {
        String(repeating: ".", count: dotPhase + 1)
    }

    func pulseRing(size: CGFloat, opacity: Double, delay: Double) -> some View {
        Circle()
            .fill(DesignSystem.Color.accent.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.14 : 0.86)
            .opacity(isAnimating ? 1.0 : 0.4)
            .animation(
                .easeInOut(duration: 0.7)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
    }
}
