import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The comparison itself: numbers as bars, then text facts side by side.
struct CompareMetricsView: View {
    // MARK: - Properties
    let left: Country
    let right: Country

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "In Numbers")
            populationChart
            areaChart
            gdpChart
            densityChart

            SectionHeaderView(title: "Facts")
                .padding(.top, DesignSystem.Spacing.sm)
            textMetrics
        }
    }
}

// MARK: - Charts
private extension CompareMetricsView {
    var populationChart: some View {
        CompareBarChart(
            title: "Population",
            icon: "person.2.fill",
            leftValue: Double(left.population),
            rightValue: Double(right.population),
            leftLabel: left.population.formatPopulation(),
            rightLabel: right.population.formatPopulation()
        )
    }

    var areaChart: some View {
        CompareBarChart(
            title: "Area",
            icon: "map.fill",
            leftValue: left.area,
            rightValue: right.area,
            leftLabel: left.area.formatArea(),
            rightLabel: right.area.formatArea()
        )
    }

    @ViewBuilder
    var gdpChart: some View {
        if let leftGDP = left.gdp, let rightGDP = right.gdp {
            CompareBarChart(
                title: "GDP",
                icon: "chart.bar.fill",
                leftValue: leftGDP,
                rightValue: rightGDP,
                leftLabel: leftGDP.formatGDP(),
                rightLabel: rightGDP.formatGDP()
            )
        }
    }

    var densityChart: some View {
        CompareBarChart(
            title: "Density",
            icon: "person.crop.square",
            leftValue: left.populationDensity,
            rightValue: right.populationDensity,
            leftLabel: densityLabel(left.populationDensity),
            rightLabel: densityLabel(right.populationDensity)
        )
    }
}

// MARK: - Facts
private extension CompareMetricsView {
    @ViewBuilder
    var textMetrics: some View {
        CompareMetricRow(
            title: "Capital",
            icon: "star.fill",
            leftValue: left.capital,
            rightValue: right.capital
        )

        CompareMetricRow(
            title: "Continent",
            icon: "globe.americas.fill",
            leftValue: left.continent.displayName,
            rightValue: right.continent.displayName,
            match: left.continent == right.continent
        )

        CompareMetricRow(
            title: "Currency",
            icon: "dollarsign.circle.fill",
            leftValue: "\(left.currency.name) (\(left.currency.code))",
            rightValue: "\(right.currency.name) (\(right.currency.code))",
            match: left.currency.code == right.currency.code
        )

        CompareMetricRow(
            title: "Languages",
            icon: "character.bubble.fill",
            leftValue: languagesSummary(left.languages),
            rightValue: languagesSummary(right.languages)
        )

        CompareMetricRow(
            title: "Memberships",
            icon: "building.2.fill",
            leftValue: membershipCount(left),
            rightValue: membershipCount(right),
            sharedItems: Set(left.organizations).intersection(right.organizations).sorted()
        )
    }
}

// MARK: - Helpers
private extension CompareMetricsView {
    func densityLabel(_ value: Double) -> String {
        String(format: "%.1f/km\u{00B2}", value)
    }

    func membershipCount(_ country: Country) -> String {
        country.organizations.count == 1 ? "1 organization" : "\(country.organizations.count) organizations"
    }

    func languagesSummary(_ languages: [Country.Language]) -> String {
        let names = languages
            .sorted(by: \.percentage, descending: true)
            .prefix(3)
            .map(\.name)
        if names.isEmpty { return "N/A" }
        let suffix = languages.count > 3 ? " +\(languages.count - 3)" : ""
        return names.joined(separator: ", ") + suffix
    }
}
