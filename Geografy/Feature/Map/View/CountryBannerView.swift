import SwiftUI

struct CountryBannerView: View {
    let name: String
    let flag: String
    let capital: String
    let onMoreInfo: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            flagView
            infoSection
            Spacer()
            if let onMoreInfo {
                moreInfoButton(action: onMoreInfo)
            }
            closeButton
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Subviews

private extension CountryBannerView {
    var flagView: some View {
        Text(flag)
            .font(DesignSystem.IconSize.large)
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(capital)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    func moreInfoButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("More info")
                    .font(DesignSystem.Font.caption)
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(.glass)
    }

    var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
        .buttonStyle(.glass)
    }
}
