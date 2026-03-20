import SwiftUI

struct ComingSoonView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let icon: String
    var title: String?
    var isDismissible: Bool = false

    @State private var isAnimating = false

    var body: some View {
        Group {
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.background)
        .navigationTitle(title ?? "")
        .toolbar {
            if isDismissible {
                ToolbarItem(placement: .topBarTrailing) {
                    GeoCircleCloseButton()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Layouts

private extension ComingSoonView {
    var isLandscape: Bool { verticalSizeClass == .compact }

    var portraitLayout: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            iconSection
            textSection
            Spacer()
            Spacer()
        }
    }

    var landscapeLayout: some View {
        HStack(spacing: DesignSystem.Spacing.xxl) {
            iconSection
            textSection
        }
    }
}

// MARK: - Subviews

private extension ComingSoonView {
    var circleScale: CGFloat { isLandscape ? 0.6 : 1.0 }

    var iconSection: some View {
        ZStack {
            pulsingCircles
            iconView
        }
        .scaleEffect(circleScale)
        .frame(
            width: DesignSystem.Size.feature * circleScale,
            height: DesignSystem.Size.feature * circleScale
        )
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
