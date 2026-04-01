import GeografyCore
import GeografyDesign
import SwiftUI

struct CountryBrowserScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(FavoritesService.self) private var favoritesService

    let countryDataService: CountryDataService

    @State private var searchText = ""
    @State private var selectedContinent: Country.Continent?
    @AppStorage("tvCountryLayout") private var useGridLayout = true

    var body: some View {
        Group {
            if useGridLayout {
                gridLayout
            } else {
                listLayout
            }
        }
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search countries")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation { useGridLayout.toggle() }
                } label: {
                    Image(systemName: useGridLayout ? "list.bullet" : "square.grid.2x2")
                }
            }
        }
        .navigationDestination(for: Country.self) { country in
            CountryDetailScreen(country: country)
        }
    }
}

// MARK: - Grid Layout
private extension CountryBrowserScreen {
    var gridLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                continentPicker

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 220), spacing: 32)],
                    spacing: 32
                ) {
                    ForEach(filteredCountries) { country in
                        NavigationLink(value: country) {
                            VStack(spacing: 16) {
                                FlagView(countryCode: country.code, height: 80)

                                Text(country.name)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(DesignSystem.Color.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)

                                Text(country.capital)
                                    .font(.system(size: 22))
                                    .foregroundStyle(DesignSystem.Color.textSecondary)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(
                                DesignSystem.Color.cardBackground,
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                }
            }
            .padding(60)
        }
        .background { AmbientBlobsView(.tv) }
    }
}

// MARK: - List Layout
private extension CountryBrowserScreen {
    var listLayout: some View {
        List {
            Section {
                continentPicker
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
                                    .font(.system(size: 22))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(country.continent.displayName)
                                .font(.system(size: 22))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Shared
private extension CountryBrowserScreen {
    var continentPicker: some View {
        Picker("Continent", selection: $selectedContinent) {
            Text("All").tag(nil as Country.Continent?)
            ForEach(Country.Continent.allCases, id: \.self) { continent in
                Text(continent.displayName)
                    .tag(continent as Country.Continent?)
            }
        }
    }

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
