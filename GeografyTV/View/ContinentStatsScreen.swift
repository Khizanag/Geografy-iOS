import SwiftUI
import GeografyDesign
import GeografyCore

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
            .sorted { $0.name < $1.name }
    }

    var statsGrid: some View {
        let countries = continentCountries
        let totalPopulation = countries.reduce(0) { $0 + $1.population }
        let totalArea = countries.reduce(0.0) { $0 + $1.area }
        let avgGDP = countries.compactMap(\.gdpPerCapita).reduce(0.0, +)
            / max(Double(countries.compactMap(\.gdpPerCapita).count), 1)

        return Group {
            statRow(label: "Countries", value: "\(countries.count)", icon: "flag.fill")
            statRow(label: "Total Population", value: totalPopulation.formatted(), icon: "person.3.fill")
            statRow(label: "Total Area", value: "\(totalArea.formatted()) km²", icon: "map.fill")
            statRow(label: "Avg GDP per Capita", value: "$\(Int(avgGDP).formatted())", icon: "chart.bar.fill")
            statRow(
                label: "Languages",
                value: "\(Set(countries.flatMap(\.languages).map(\.name)).count)",
                icon: "text.bubble.fill"
            )
        }
    }

    func statRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 36)

            Text(label)
                .font(.system(size: 20))

            Spacer()

            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Country Row
private extension ContinentStatsScreen {
    func countryRow(_ country: Country) -> some View {
        HStack(spacing: 20) {
            FlagView(countryCode: country.code, height: 36)

            Text(country.name)
                .font(.system(size: 20))

            Spacer()

            Text(country.capital)
                .font(.system(size: 22))
                .foregroundStyle(.secondary)

            Text(country.population.formatted())
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(width: 120, alignment: .trailing)
        }
    }
}
