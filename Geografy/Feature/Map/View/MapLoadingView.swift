import Combine
import SwiftUI

struct MapLoadingView: View {
    @State private var isAnimating = false
    @State private var dotPhase = 0
    @State private var messageIndex = 0

    private let messages = [
        "Exploring the world",
        "Charting the continents",
        "Mapping every border",
        "Plotting coordinates",
    ]

    var body: some View {
        ZStack {
            DesignSystem.Color.background
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.lg) {
                Spacer()
                globeSection
                textSection
                Spacer()
                copyrightLabel
                    .padding(.bottom, DesignSystem.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onReceive(Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()) { _ in
            dotPhase = (dotPhase + 1) % 3
        }
        .onReceive(Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                messageIndex = (messageIndex + 1) % messages.count
            }
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
            pulseRing(size: 200, opacity: 0.08, delay: 0.00)
            pulseRing(size: 160, opacity: 0.13, delay: 0.15)
            pulseRing(size: 120, opacity: 0.20, delay: 0.30)
            pulseRing(size: 84,  opacity: 0.28, delay: 0.45)
        }
    }

    var globeIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.15))
                .frame(width: 76, height: 76)
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 36))
                .foregroundStyle(DesignSystem.Color.accent)
                .rotationEffect(.degrees(isAnimating ? 10 : -10))
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }

    var textSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: 0) {
                Text(messages[messageIndex])
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .animation(.easeInOut(duration: 0.3), value: messageIndex)

                Text(dotString)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: 28, alignment: .leading)
                    .animation(nil, value: dotPhase)
            }

            Text("Parsing geographic boundaries and rendering country shapes from GeoJSON data")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxl)
        }
    }

    var copyrightLabel: some View {
        Text("Map data © OpenStreetMap contributors · Geografy")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
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
