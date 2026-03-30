import SwiftUI

struct PulsingCirclesView: View {
    let icon: String
    let isAnimating: Bool

    var body: some View {
        ZStack {
            circles
            iconView
        }
        .frame(width: DesignSystem.Size.feature, height: DesignSystem.Size.feature)
        .accessibilityHidden(true)
    }
}

// MARK: - Subviews
private extension PulsingCirclesView {
    var circles: some View {
        ZStack {
            circle(size: 270, opacity: 0.015, delay: 0)
            circle(size: 240, opacity: 0.025, delay: 0.25)
            circle(size: 210, opacity: 0.035, delay: 0.5)
            circle(size: 180, opacity: 0.045, delay: 0.75)
            circle(size: 150, opacity: 0.06, delay: 1.0)
            circle(size: 120, opacity: 0.08, delay: 1.25)
        }
    }

    var iconView: some View {
        Image(systemName: icon)
            .font(DesignSystem.IconSize.xLarge)
            .foregroundStyle(DesignSystem.Color.accent)
    }

    func circle(size: CGFloat, opacity: Double, delay: Double) -> some View {
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
