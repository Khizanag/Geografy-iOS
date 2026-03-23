import SwiftUI

// MARK: - Economy

extension CountryDetailScreen {
    var hasEconomyData: Bool {
        country.gdp != nil || country.gdpPerCapita != nil || country.gdpPPP != nil
    }

    var economySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Economy", premium: true)
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let gdp = country.gdp {
                    economyTile(
                        icon: "chart.bar.fill",
                        label: "GDP",
                        value: gdp.formatGDP(),
                        color: DesignSystem.Color.accent
                    )
                }
                if let perCapita = country.gdpPerCapita {
                    economyTile(
                        icon: "person.crop.circle",
                        label: "Per Capita",
                        value: perCapita.formatCurrency(),
                        color: DesignSystem.Color.blue
                    )
                }
                if let ppp = country.gdpPPP {
                    economyTile(
                        icon: "chart.bar",
                        label: "GDP PPP",
                        value: ppp.formatGDP(),
                        color: DesignSystem.Color.indigo
                    )
                }
            }
        }
    }

    var governmentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Government", premium: true)
            InfoTile(
                icon: "building.columns",
                title: "Form of Government",
                value: country.formOfGovernment
            ) {
                activeSheet = .info(
                    InfoItem(
                        icon: "building.columns.fill",
                        title: "Form of Government",
                        value: country.formOfGovernment,
                        supportsMap: false
                    )
                )
            }
        }
    }

    var currencySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Currency", premium: true)
            InfoTile(
                icon: "dollarsign.circle",
                title: country.currency.name,
                value: country.currency.code
            ) {
                activeSheet = .info(
                    InfoItem(
                        icon: "dollarsign.circle.fill",
                        title: "Currency",
                        value: "\(country.currency.name) (\(country.currency.code))",
                        supportsMap: false
                    )
                )
            }
            GeoButton(
                "Convert \(country.currency.code)",
                systemImage: "arrow.left.arrow.right",
                style: .secondary
            ) {
                hapticsService.impact(.light)
                activeSheet = .currencyConverter(country.currency.code)
            }
        }
    }
}

// MARK: - Helpers

private extension CountryDetailScreen {
    func economyTile(icon: String, label: String, value: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(color)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(value)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.sm)
        }
    }
}
