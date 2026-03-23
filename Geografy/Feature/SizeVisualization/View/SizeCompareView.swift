import SwiftUI

struct SizeCompareView: View {
    @Environment(\.dismiss) private var dismiss

    let referenceCountry: Country
    let comparisonCountry: Country

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Color.background.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("Size Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CircleCloseButton { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(DesignSystem.Color.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Subviews

private extension SizeCompareView {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            summaryText
                .padding(.top, DesignSystem.Spacing.lg)
            squaresRow
            statsRow
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }

    var summaryText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(comparisonLabel)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
            Text("by land area")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var squaresRow: some View {
        HStack(alignment: .bottom, spacing: DesignSystem.Spacing.xl) {
            countrySquare(
                country: referenceCountry,
                sizeFraction: referenceFraction,
                label: "Reference",
                color: DesignSystem.Color.accent
            )
            countrySquare(
                country: comparisonCountry,
                sizeFraction: comparisonFraction,
                label: "Selected",
                color: DesignSystem.Color.ocean
            )
        }
        .frame(height: 200)
    }

    func countrySquare(country: Country, sizeFraction: Double, label: String, color: Color) -> some View {
        let side = max(30, 160 * sizeFraction)
        return VStack(spacing: DesignSystem.Spacing.sm) {
            Spacer()
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(color.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(color, lineWidth: 2)
                )
                .frame(width: side, height: side)
                .overlay(
                    FlagView(countryCode: country.code, height: min(40, side * 0.4))
                )
            VStack(spacing: 2) {
                Text(country.name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                Text(formattedArea(country.area))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            statCard(
                title: referenceCountry.name,
                value: formattedArea(referenceCountry.area),
                color: DesignSystem.Color.accent
            )
            statCard(
                title: comparisonCountry.name,
                value: formattedArea(comparisonCountry.area),
                color: DesignSystem.Color.ocean
            )
        }
    }

    func statCard(title: String, value: String, color: Color) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
                Text(value)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Helpers

private extension SizeCompareView {
    var multiplier: Double {
        let larger = max(referenceCountry.area, comparisonCountry.area)
        let smaller = min(referenceCountry.area, comparisonCountry.area)
        guard smaller > 0 else { return 1 }
        return larger / smaller
    }

    var comparisonLabel: String {
        if comparisonCountry.area > referenceCountry.area {
            return String(format: "%@ is %.1fx larger than %@", comparisonCountry.name, multiplier, referenceCountry.name)
        } else if comparisonCountry.area < referenceCountry.area {
            return String(format: "%@ is %.1fx smaller than %@", comparisonCountry.name, multiplier, referenceCountry.name)
        }
        return "\(comparisonCountry.name) and \(referenceCountry.name) are similar in size"
    }

    var referenceFraction: Double {
        let maxArea = max(referenceCountry.area, comparisonCountry.area)
        guard maxArea > 0 else { return 0.5 }
        return referenceCountry.area / maxArea
    }

    var comparisonFraction: Double {
        let maxArea = max(referenceCountry.area, comparisonCountry.area)
        guard maxArea > 0 else { return 0.5 }
        return comparisonCountry.area / maxArea
    }

    var shareText: String {
        "\(comparisonLabel) by land area. Reference: \(formattedArea(referenceCountry.area)), \(comparisonCountry.name): \(formattedArea(comparisonCountry.area))"
    }

    func formattedArea(_ area: Double) -> String {
        if area >= 1_000_000 {
            return String(format: "%.2fM km²", area / 1_000_000)
        }
        return String(format: "%.0f km²", area)
    }
}

// MARK: - Preview

#Preview {
    SizeCompareView(
        referenceCountry: Country(
            code: "FR",
            name: "France",
            capital: "Paris",
            capitals: nil,
            flagEmoji: "🇫🇷",
            continent: .europe,
            area: 551_695,
            population: 67_750_000,
            populationDensity: 122.8,
            currency: Country.Currency(name: "Euro", code: "EUR"),
            languages: [],
            formOfGovernment: "Republic",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        ),
        comparisonCountry: Country(
            code: "BR",
            name: "Brazil",
            capital: "Brasília",
            capitals: nil,
            flagEmoji: "🇧🇷",
            continent: .southAmerica,
            area: 8_515_767,
            population: 215_313_498,
            populationDensity: 25.3,
            currency: Country.Currency(name: "Real", code: "BRL"),
            languages: [],
            formOfGovernment: "Federal Republic",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    )
}
