import SwiftUI

struct MapLoadingView: View {
    @State private var isAnimating = false
    @State private var textOpacity: Double = 0

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            PulsingCirclesView(icon: "globe.americas.fill", isAnimating: isAnimating)

            Text("Loading map...")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .opacity(textOpacity)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.background)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                textOpacity = 1
            }
        }
    }
}
