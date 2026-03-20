import SwiftUI

struct CountryBannerView: View {
    let country: Country
    let onMoreInfo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            flagSection
            infoSection
            Spacer()
            moreInfoButton
            dismissButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Subviews

private extension CountryBannerView {
    var flagSection: some View {
        Text(country.flagEmoji)
            .font(DesignSystem.IconSize.large)
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(country.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(country.capital)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var moreInfoButton: some View {
        GeoButton("More info", systemImage: "chevron.right", style: .primary) {
            onMoreInfo()
        }
    }

    var dismissButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
