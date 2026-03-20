import SwiftUI

struct CountryBannerView: View {
    let name: String
    let country: Country?
    let onMoreInfo: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            countryRow
            if onMoreInfo != nil {
                moreInfoButton
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Subviews

private extension CountryBannerView {
    var countryRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let flag = country?.flagEmoji {
                Text(flag)
                    .font(DesignSystem.IconSize.large)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(name)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                if let capital = country?.capital {
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

            Spacer()
        }
    }

    var moreInfoButton: some View {
        Button { onMoreInfo?() } label: {
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
