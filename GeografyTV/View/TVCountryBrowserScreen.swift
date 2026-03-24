import SwiftUI

struct TVCountryBrowserScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let countryDataService: CountryDataService

    @State private var searchText = ""
    @State private var selectedContinent: Country.Continent?

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 32),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                continentFilter

                countryGrid
            }
            .padding(60)
        }
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search countries")
        .navigationDestination(for: Country.self) { country in
            TVCountryDetailScreen(country: country)
        }
    }
}

// MARK: - Continent Filter

private extension TVCountryBrowserScreen {
    var continentFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                continentChip(nil, label: "All")

                ForEach(Country.Continent.allCases, id: \.self) { continent in
                    continentChip(continent, label: continent.displayName)
                }
            }
        }
    }

    func continentChip(_ continent: Country.Continent?, label: String) -> some View {
        let isSelected = selectedContinent == continent
        return Button {
            selectedContinent = continent
        } label: {
            Text(label)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                    in: Capsule()
                )
        }
        .buttonStyle(.card)
    }
}

// MARK: - Country Grid

private extension TVCountryBrowserScreen {
    var countryGrid: some View {
        LazyVGrid(columns: columns, spacing: 32) {
            ForEach(filteredCountries) { country in
                NavigationLink(value: country) {
                    tvCountryCard(country)
                }
                .buttonStyle(.card)
            }
        }
    }

    func tvCountryCard(_ country: Country) -> some View {
        VStack(spacing: 16) {
            FlagView(countryCode: country.code, height: 80)

            Text(country.name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text(country.capital)
                .font(.system(size: 18))
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
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
