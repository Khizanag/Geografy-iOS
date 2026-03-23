import SwiftUI

struct HomeCountrySpotlightCard: View {
    let country: Country
    let funFact: String?

    var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
            VStack(spacing: DesignSystem.Spacing.md) {
                headerRow
                countryInfoRow
                if let fact = funFact {
                    funFactRow(fact)
                }
                learnMoreButton
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension HomeCountrySpotlightCard {
    var headerRow: some View {
        HStack {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(.yellow)
                Text("COUNTRY OF THE DAY")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .kerning(0.8)
            }
            Spacer()
        }
    }

    func funFactRow(_ fact: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "lightbulb.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.warning)
                .padding(.top, 2)
            Text(fact)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var learnMoreButton: some View {
        HStack {
            Spacer()
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("Learn More")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption2)
            }
            .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var countryInfoRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            FlagView(countryCode: country.code, height: 68)
                .geoShadow(.subtle)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                infoChip(icon: "mappin.and.ellipse", text: country.capital)
                infoChip(icon: "globe.americas.fill", text: country.continent.displayName)
            }
            Spacer(minLength: 0)
        }
    }

    var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(icon: "person.3.fill", value: country.population.formatPopulation(), label: "Population")
            Divider().frame(height: 36)
            statCell(icon: "map.fill", value: country.area.formatArea(), label: "Area")
            Divider().frame(height: 36)
            statCell(icon: "dollarsign.circle.fill", value: country.currency.code, label: "Currency")
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    func infoChip(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    func statCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(value)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
