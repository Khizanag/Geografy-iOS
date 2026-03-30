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
                    CircleCloseButton()
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
    var circleScale: CGFloat { isLandscape ? 0.6 : 1.0 }

    var portraitLayout: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            pulsingIcon
            textSection
            Spacer()
            Spacer()
        }
    }

    var landscapeLayout: some View {
        HStack(spacing: DesignSystem.Spacing.xxl) {
            pulsingIcon
            textSection
        }
    }
}

// MARK: - Subviews
private extension ComingSoonView {
    var pulsingIcon: some View {
        PulsingCirclesView(icon: icon, isAnimating: isAnimating)
            .scaleEffect(circleScale)
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
