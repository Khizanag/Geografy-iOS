import SwiftUI

struct MapLoadingView: View {
    @State private var isAnimating = false
    @State private var globeRotation: Double = 0
    @State private var ringsExpanded = false

    var body: some View {
        ZStack {
            DesignSystem.Color.ocean
                .ignoresSafeArea()

            pulsingRings
            globe
            shimmerOverlay
        }
        .onAppear { startAnimations() }
    }
}

// MARK: - Subviews

private extension MapLoadingView {
    var pulsingRings: some View {
        ZStack {
            ringView(size: 300, delay: 0)
            ringView(size: 240, delay: 0.08)
            ringView(size: 180, delay: 0.16)
            ringView(size: 120, delay: 0.24)
        }
    }

    var globe: some View {
        Image(systemName: "globe.americas.fill")
            .font(.system(size: 80, weight: .ultraLight))
            .foregroundStyle(DesignSystem.Color.accent)
            .rotationEffect(.degrees(globeRotation))
            .scaleEffect(isAnimating ? 1.0 : 0.6)
            .opacity(isAnimating ? 1 : 0)
    }

    var shimmerOverlay: some View {
        VStack {
            Spacer()

            Text("Loading map...")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .opacity(isAnimating ? 1 : 0)
                .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Helpers

private extension MapLoadingView {
    func ringView(size: CGFloat, delay: Double) -> some View {
        Circle()
            .stroke(
                DesignSystem.Color.accent.opacity(0.15),
                lineWidth: 1.5
            )
            .frame(width: size, height: size)
            .scaleEffect(ringsExpanded ? 1.3 : 0.5)
            .opacity(ringsExpanded ? 0 : 0.8)
            .animation(
                .easeOut(duration: 1.5)
                .delay(delay),
                value: ringsExpanded
            )
    }

    func startAnimations() {
        withAnimation(.easeOut(duration: 0.6)) {
            isAnimating = true
        }
        withAnimation(.linear(duration: 1.5)) {
            globeRotation = 360
        }
        ringsExpanded = true
    }
}
