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
            // The panels sit close to the card's edge, so their concentric corners stay rounded (24 − 8 = 16).
            .padding(.horizontal, Self.panelInset)
            .padding(.bottom, Self.panelInset)
            .padding(.top, DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews
private extension CountrySpotlightCard {
    var headerBadge: some View {
        InfoPill(
            String(localized: "Country of the Day"),
            systemImage: "star.fill",
            style: .tinted(DesignSystem.Color.warning)
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
                                colors: [continentColor.opacity(DesignSystem.Opacity.soft), .clear],
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
            in: Self.panelShape
        )
        .overlay {
            if colorSchemeContrast == .increased {
                Self.panelShape
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
                .padding(.top, DesignSystem.Spacing.xxxs)
                .accessibilityHidden(true)
            Text(fact)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DesignSystem.Color.warning.opacity(DesignSystem.Opacity.tint),
            in: Self.panelShape
        )
        .overlay {
            if colorSchemeContrast == .increased {
                Self.panelShape
                    .strokeBorder(DesignSystem.Color.dividerSubtle)
            }
        }
    }
}

// MARK: - Helpers
private extension CountrySpotlightCard {
    func statCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
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

    /// How far the inner panels sit from the card's edge.
    static let panelInset = DesignSystem.Spacing.xs

    /// Inner panels' corners nest inside the card's, so both curves stay parallel.
    static let panelShape = RoundedRectangle(
        cornerRadius: DesignSystem.CornerRadius.nested(inset: panelInset),
        style: .continuous
    )

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
