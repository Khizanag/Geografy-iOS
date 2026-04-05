import SwiftUI

public struct EmptyStateView: View {
    // MARK: - Properties
    public let icon: String
    public let title: String
    public let subtitle: String
    public var actionTitle: String?
    public var action: (() -> Void)?

    // MARK: - Init
    public init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            iconCircle
            titleLabel
            subtitleLabel
            actionButton
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews
private extension EmptyStateView {
    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.1))
                .frame(width: 100, height: 100)
            Image(systemName: icon)
                .font(DesignSystem.Font.displayXXS)
                .foregroundStyle(DesignSystem.Color.accent.opacity(0.6))
        }
    }

    var titleLabel: some View {
        Text(title)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var subtitleLabel: some View {
        Text(subtitle)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var actionButton: some View {
        if let actionTitle, let action {
            GlassButton(actionTitle, action: action)
                .padding(.top, DesignSystem.Spacing.xs)
        }
    }
}
