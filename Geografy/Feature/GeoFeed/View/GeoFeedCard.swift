import SwiftUI

struct GeoFeedCard: View {
    let item: GeoFeedItem
    let isSaved: Bool
    let country: Country?
    let onSave: () -> Void
    let onCountryTap: (Country) -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                cardHeader
                cardBody
                if let country {
                    cardFooter(country: country)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension GeoFeedCard {
    var cardHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            categoryChip
            Spacer()
            saveButton
        }
    }

    var categoryChip: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: item.icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(item.color)
            Text(item.type.label)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(item.color)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(item.color.opacity(0.15), in: Capsule())
    }

    var saveButton: some View {
        Button(action: onSave) {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(isSaved ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSaved)
        }
        .buttonStyle(.plain)
    }

    var cardBody: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(item.title)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(item.body)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func cardFooter(country: Country) -> some View {
        Button { onCountryTap(country) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                Text(country.name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer()
                Text("Learn More")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(item.color)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(item.color)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
        }
        .buttonStyle(.plain)
    }
}
