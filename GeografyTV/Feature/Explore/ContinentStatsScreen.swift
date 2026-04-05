import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_ContinentStats
import SwiftUI

struct ContinentStatsScreen: View {
    let countryDataService: CountryDataService

    @State private var selectedContinent: Country.Continent = .europe

    var body: some View {
        List {
            Section {
                Picker("Continent", selection: $selectedContinent) {
                    ForEach(Country.Continent.allCases, id: \.self) { continent in
                        Text(continent.displayName)
                            .tag(continent)
                    }
                }
            }

            Section("Overview") {
                statsGrid
            }

            Section("Countries (\(continentCountries.count))") {
                ForEach(continentCountries) { country in
                    countryRow(country)
                }
            }
        }
        .navigationTitle("Continent Stats")
    }
}

// MARK: - Stats
private extension ContinentStatsScreen {
    var continentCountries: [Country] {
        countryDataService.countries
            .filter { $0.continent == selectedContinent }
            .sorted(by: \.name)
    }

    var statsGrid: some View {
        let countries = continentCountries
        let totalPopulation = countries.reduce(0) { $0 + $1.population }
        let totalArea = countries.reduce(0.0) { $0 + $1.area }
        let averageGDP = countries.compactMap(\.gdpPerCapita).reduce(0.0, +)
            / max(Double(countries.compactMap(\.gdpPerCapita).count), 1)

        return Group {
            statRow(label: "Countries", value: "\(countries.count)", icon: "flag.fill")
            statRow(label: "Total Population", value: totalPopulation.formatted(), icon: "person.3.fill")
            statRow(label: "Total Area", value: "\(totalArea.formatted()) km\u{00B2}", icon: "map.fill")
            statRow(
                label: "Avg GDP per Capita",
                value: "$\(Int(averageGDP).formatted())",
                icon: "chart.bar.fill"
            )
            statRow(
                label: "Languages",
                value: "\(Set(countries.flatMap(\.languages).map(\.name)).count)",
                icon: "text.bubble.fill"
            )
        }
    }

    func statRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 36)

            Text(label)
                .font(DesignSystem.Font.system(size: 20))

            Spacer()

            Text(value)
                .font(DesignSystem.Font.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Country Row
private extension ContinentStatsScreen {
    func countryRow(_ country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            FlagView(countryCode: country.code, height: 36)

            Text(country.name)
                .font(DesignSystem.Font.system(size: 20))

            Spacer()

            Text(country.capital)
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(.secondary)

            Text(country.population.formatted())
                .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(width: 120, alignment: .trailing)
        }
    }
}
