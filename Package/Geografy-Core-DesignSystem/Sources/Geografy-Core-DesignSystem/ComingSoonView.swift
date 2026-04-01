import SwiftUI

public struct ComingSoonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    public let icon: String
    public var title: String?
    public var isDismissible: Bool = false

    @State private var isAnimating = false

    public init(
        icon: String,
        title: String? = nil,
        isDismissible: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.isDismissible = isDismissible
    }

    public var body: some View {
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
        .onAppear {
            isAnimating = true
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
