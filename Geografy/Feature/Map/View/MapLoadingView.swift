import SwiftUI

struct MapLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            PulsingCirclesView(icon: "globe.americas.fill", isAnimating: isAnimating)
            loadingText
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.background)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Subviews

private extension MapLoadingView {
    var loadingText: some View {
        Text("Loading map...")
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }
}
