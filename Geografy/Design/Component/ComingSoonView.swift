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
        .frame(width: 280, height: 280)
    }

    var pulsingCircles: some View {
        ZStack {
            pulsingCircle(size: 260, opacity: 0.02, delay: 0)
            pulsingCircle(size: 220, opacity: 0.04, delay: 0.4)
            pulsingCircle(size: 180, opacity: 0.06, delay: 0.8)
            pulsingCircle(size: 140, opacity: 0.09, delay: 1.2)
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
            .stroke(DesignSystem.Color.accent.opacity(opacity * 2), lineWidth: 1.5)
            .background(Circle().fill(DesignSystem.Color.accent.opacity(opacity)))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.06 : 0.94)
            .opacity(isAnimating ? 1 : 0.5)
            .animation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
    }
}
