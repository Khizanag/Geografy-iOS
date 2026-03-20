import SwiftUI

struct CountryBannerView: View {
    let country: Country
    let onMoreInfo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: GeoSpacing.sm) {
            flagSection
            infoSection
            Spacer()
            moreInfoButton
            dismissButton
        }
        .padding(.horizontal, GeoSpacing.md)
        .padding(.vertical, GeoSpacing.sm)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: GeoCornerRadius.large))
        .padding(.horizontal, GeoSpacing.md)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Subviews

private extension CountryBannerView {
    var flagSection: some View {
        Text(country.flagEmoji)
            .font(GeoIconSize.large)
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xxs) {
            Text(country.name)
                .font(GeoFont.headline)
                .foregroundStyle(GeoColors.textPrimary)

            HStack(spacing: GeoSpacing.xxs) {
                Image(systemName: "star.fill")
                    .font(GeoFont.caption)
                    .foregroundStyle(GeoColors.accent)

                Text(country.capital)
                    .font(GeoFont.caption)
                    .foregroundStyle(GeoColors.textSecondary)
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
                .font(GeoFont.caption)
                .foregroundStyle(GeoColors.textSecondary)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
