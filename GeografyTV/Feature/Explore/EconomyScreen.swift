import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct EconomyScreen: View {
    let countryDataService: CountryDataService

    @State private var sortMetric: EconomySortMetric = .gdpPerCapita

    private var rankedCountries: [Country] {
        switch sortMetric {
        case .gdpPerCapita:
            countryDataService.countries
                .filter { $0.gdpPerCapita != nil }
                .sorted { ($0.gdpPerCapita ?? 0) > ($1.gdpPerCapita ?? 0) }
        case .gdpTotal:
            countryDataService.countries
                .filter { $0.gdp != nil }
                .sorted { ($0.gdp ?? 0) > ($1.gdp ?? 0) }
        case .population:
            countryDataService.countries
                .sorted(by: \.population, descending: true)
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Sort By", selection: $sortMetric) {
                    ForEach(EconomySortMetric.allCases, id: \.self) { metric in
                        Text(metric.displayName).tag(metric)
                    }
                }
            }

            Section("\(rankedCountries.count) countries") {
                ForEach(Array(rankedCountries.enumerated()), id: \.element.id) { rank, country in
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        Text("#\(rank + 1)")
                            .font(DesignSystem.Font.system(size: 20, weight: .bold))
                            .foregroundStyle(rank < 3 ? DesignSystem.Color.accent : .secondary)
                            .frame(width: 50, alignment: .leading)

                        FlagView(countryCode: country.code, height: 32)

                        Text(country.name)
                            .font(DesignSystem.Font.system(size: 20))

                        Spacer()

                        Text(formattedValue(country))
                            .font(DesignSystem.Font.system(size: 20, weight: .semibold))
                            .foregroundStyle(DesignSystem.Color.accent)
                    }
                }
            }
        }
        .navigationTitle("Economy")
    }
}

// MARK: - Helpers
private extension EconomyScreen {
    enum EconomySortMetric: CaseIterable {
        case gdpPerCapita
        case gdpTotal
        case population

        var displayName: String {
            switch self {
            case .gdpPerCapita: "GDP per Capita"
            case .gdpTotal: "GDP Total"
            case .population: "Population"
            }
        }
    }

    func formattedValue(_ country: Country) -> String {
        switch sortMetric {
        case .gdpPerCapita:
            guard let value = country.gdpPerCapita else { return "\u{2014}" }
            return "$\(Int(value).formatted())"
        case .gdpTotal:
            guard let value = country.gdp else { return "\u{2014}" }
            if value >= 1_000_000_000_000 { return String(format: "$%.1fT", value / 1_000_000_000_000) }
            if value >= 1_000_000_000 { return String(format: "$%.1fB", value / 1_000_000_000) }
            return String(format: "$%.0fM", value / 1_000_000)
        case .population:
            return country.population.formatted()
        }
    }
}
