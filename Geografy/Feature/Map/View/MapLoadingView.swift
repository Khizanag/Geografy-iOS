import SwiftUI

struct MapLoadingView: View {
    @State private var isAnimating = false
    @State private var appeared = false
    @State private var dotPhase = 0

    private let messages = [
        "Exploring the world",
        "Charting the continents",
        "Mapping every border",
        "Plotting coordinates",
    ]

    @State private var messageIndex = 0

    var body: some View {
        ZStack {
            DesignSystem.Color.background
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.lg) {
                globeSection
                textSection
            }
            .offset(y: DesignSystem.Spacing.xxl)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.92)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            startDotAnimation()
            startMessageRotation()
        }
    }
}

// MARK: - Subviews

private extension MapLoadingView {
    var globeSection: some View {
        ZStack {
            pulseRings
            globeIcon
        }
    }

    var pulseRings: some View {
        ZStack {
            pulseRing(size: 200, opacity: 0.06, delay: 0.0)
            pulseRing(size: 160, opacity: 0.10, delay: 0.18)
            pulseRing(size: 120, opacity: 0.16, delay: 0.36)
            pulseRing(size: 84, opacity: 0.22, delay: 0.54)
        }
    }

    var globeIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 72, height: 72)
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 34))
                .foregroundStyle(DesignSystem.Color.accent)
                .rotationEffect(.degrees(isAnimating ? 8 : -8))
                .animation(
                    .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }

    var textSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: 0) {
                Text(messages[messageIndex])
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .animation(.easeInOut(duration: 0.4), value: messageIndex)

                Text(dotString)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: 28, alignment: .leading)
                    .animation(nil, value: dotPhase)
            }

            Text("This takes just a moment")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var dotString: String {
        String(repeating: ".", count: dotPhase + 1)
    }

    func pulseRing(size: CGFloat, opacity: Double, delay: Double) -> some View {
        Circle()
            .fill(DesignSystem.Color.accent.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.12 : 0.88)
            .opacity(isAnimating ? 1.0 : 0.3)
            .animation(
                .easeInOut(duration: 1.1)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
    }
}

// MARK: - Timers

private extension MapLoadingView {
    func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            dotPhase = (dotPhase + 1) % 3
        }
    }

    func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                messageIndex = (messageIndex + 1) % messages.count
            }
        }
    }
}
