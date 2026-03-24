import SwiftUI

struct TVCountryBrowserScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let countryDataService: CountryDataService

    @State private var searchText = ""
    @State private var selectedContinent: Country.Continent?

    var body: some View {
        List {
            Section {
                Picker("Continent", selection: $selectedContinent) {
                    Text("All").tag(nil as Country.Continent?)
                    ForEach(Country.Continent.allCases, id: \.self) { continent in
                        Text(continent.displayName)
                            .tag(continent as Country.Continent?)
                    }
                }
            }

            Section("\(filteredCountries.count) countries") {
                ForEach(filteredCountries) { country in
                    NavigationLink(value: country) {
                        HStack(spacing: 20) {
                            FlagView(countryCode: country.code, height: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(country.name)
                                    .font(.system(size: 22, weight: .semibold))

                                Text(country.capital)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(country.continent.displayName)
                                .font(.system(size: 18))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search countries")
        .navigationDestination(for: Country.self) { country in
            TVCountryDetailScreen(country: country)
        }
    }
}

// MARK: - Helpers

private extension TVCountryBrowserScreen {
    var filteredCountries: [Country] {
        var countries = countryDataService.countries

        if let continent = selectedContinent {
            countries = countries.filter { $0.continent == continent }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            countries = countries.filter {
                $0.name.lowercased().contains(query) ||
                $0.capital.lowercased().contains(query)
            }
        }

        return countries.sorted { $0.name < $1.name }
    }
}
