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
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
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
        .frame(width: 240, height: 240)
    }

    var pulsingCircles: some View {
        ZStack {
            pulsingCircle(size: 240, opacity: 0.03, delay: 0)
            pulsingCircle(size: 200, opacity: 0.05, delay: 0.3)
            pulsingCircle(size: 160, opacity: 0.07, delay: 0.6)
            pulsingCircle(size: 120, opacity: 0.10, delay: 0.9)
            pulsingCircle(size: 90, opacity: 0.14, delay: 1.2)
        }
    }

    var iconView: some View {
        Image(systemName: icon)
            .font(DesignSystem.IconSize.xxLarge)
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
            .scaleEffect(isAnimating ? 1.08 : 0.92)
            .opacity(isAnimating ? 1 : 0.6)
            .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
    }
}
