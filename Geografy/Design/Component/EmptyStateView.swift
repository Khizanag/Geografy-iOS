import SwiftUI
import GeografyDesign

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
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
