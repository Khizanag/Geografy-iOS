import SwiftUI
import GeografyDesign
import GeografyCore

struct HomeCountrySpotlightCard: View {
    let country: Country
    let funFact: String?

    var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
            VStack(spacing: DesignSystem.Spacing.md) {
                headerBadge

                flagSection

                nameSection

                statsStrip

                if let fact = funFact {
                    funFactRow(fact)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension HomeCountrySpotlightCard {
    var headerBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.micro)
                .foregroundStyle(DesignSystem.Color.warning)
            Text("COUNTRY OF THE DAY")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .kerning(0.8)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: Capsule()
        )
    }

    var flagSection: some View {
        FlagView(countryCode: country.code, height: 72)
            .geoShadow(.elevated)
            .background {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [continentColor.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60,
                        )
                    )
                    .frame(width: 140, height: 100)
                    .blur(radius: 20)
            }
    }

    var nameSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(country.name)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(country.continent.displayName)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(continentColor, in: Capsule())
        }
    }

    var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(
                icon: "mappin.and.ellipse",
                value: country.capital,
                label: "Capital"
            )
            Divider().frame(height: 32)
            statCell(
                icon: "person.2.fill",
                value: country.population.formatPopulation(),
                label: "Population"
            )
            Divider().frame(height: 32)
            statCell(
                icon: "map.fill",
                value: country.area.formatArea(),
                label: "Area"
            )
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
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
        .padding(DesignSystem.Spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Helpers
private extension HomeCountrySpotlightCard {
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
                .font(DesignSystem.Font.nano)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    var continentColor: Color {
        switch country.continent {
        case .europe: DesignSystem.Color.blue
        case .asia: DesignSystem.Color.accent
        case .africa: DesignSystem.Color.orange
        case .northAmerica: DesignSystem.Color.indigo
        case .southAmerica: DesignSystem.Color.success
        case .oceania: DesignSystem.Color.purple
        case .antarctica: DesignSystem.Color.blue
        }
    }
}
