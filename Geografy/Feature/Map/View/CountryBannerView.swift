import SwiftUI

struct CountryBannerView: View {
    let name: String
    let flag: String
    let capital: String
    let onMoreInfo: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            countryRow
            if let onMoreInfo {
                moreInfoButton(action: onMoreInfo)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Subviews

private extension CountryBannerView {
    var countryRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(flag)
                .font(DesignSystem.IconSize.large)

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

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.iconSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    func moreInfoButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("More info")
                    .font(DesignSystem.Font.subheadline)
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}
