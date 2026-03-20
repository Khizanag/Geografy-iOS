import SwiftUI

struct ComingSoonView: View {
    let icon: String

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            iconSection
            textSection
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.background)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Subviews

private extension ComingSoonView {
    var iconSection: some View {
        ZStack {
            pulsingCircles
            iconView
        }
        .frame(width: 280, height: 280)
    }

    var pulsingCircles: some View {
        ZStack {
            pulsingCircle(size: 270, opacity: 0.015, delay: 0)
            pulsingCircle(size: 240, opacity: 0.025, delay: 0.25)
            pulsingCircle(size: 210, opacity: 0.035, delay: 0.5)
            pulsingCircle(size: 180, opacity: 0.045, delay: 0.75)
            pulsingCircle(size: 150, opacity: 0.06, delay: 1.0)
            pulsingCircle(size: 120, opacity: 0.08, delay: 1.25)
        }
    }

    var iconView: some View {
        Image(systemName: icon)
            .font(DesignSystem.IconSize.xLarge)
            .foregroundStyle(DesignSystem.Color.accent)
    }

    var textSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Coming Soon")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("We're working on something great.")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Helpers

private extension ComingSoonView {
    func pulsingCircle(size: CGFloat, opacity: Double, delay: Double) -> some View {
        Circle()
            .fill(DesignSystem.Color.accent.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.06 : 0.94)
            .opacity(isAnimating ? 1 : 0.4)
            .animation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
    }
}
