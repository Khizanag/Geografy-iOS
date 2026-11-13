import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct CountrySpotlightCard: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let country: Country
    let funFact: String?

    // MARK: - Body
    var body: some View {
        CardView {
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
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews
private extension CountrySpotlightCard {
    var headerBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.micro)
                .foregroundStyle(DesignSystem.Color.warning)
                .accessibilityHidden(true)
            EyebrowLabel("Country of the Day")
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
                if !reduceTransparency {
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
            .accessibilityHidden(true)
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
        let isStacked = dynamicTypeSize.isAccessibilitySize
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.xs))
            : AnyLayout(HStackLayout(spacing: 0))
        return layout {
            statCell(
                icon: "star.fill",
                value: country.capital,
                label: "Capital"
            )
            statDivider(isStacked: isStacked)
            statCell(
                icon: "person.2.fill",
                value: country.population.formatPopulation(),
                label: "Population"
            )
            statDivider(isStacked: isStacked)
            statCell(
                icon: "map.fill",
                value: country.area.formatArea(),
                label: "Area"
            )
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
        )
        .overlay {
            if colorSchemeContrast == .increased {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .strokeBorder(DesignSystem.Color.dividerSubtle)
            }
        }
    }

    @ViewBuilder
    func statDivider(isStacked: Bool) -> some View {
        if isStacked {
            Divider()
        } else {
            Divider().frame(height: 32)
        }
    }

    func funFactRow(_ fact: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "lightbulb.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.warning)
                .padding(.top, 2)
                .accessibilityHidden(true)
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
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
        )
    }
}

// MARK: - Helpers
private extension CountrySpotlightCard {
    func statCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            Text(value)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
            Text(label)
                .font(DesignSystem.Font.nano)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
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
