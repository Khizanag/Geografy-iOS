import SwiftUI

struct CountryListScreen: View {
    @State private var countryDataService = CountryDataService()
    @State private var searchText = ""
    @State private var selectedContinent: Country.Continent?

    var body: some View {
        List {
            continentFilterSection
            ForEach(groupedCountries, id: \.continent) { group in
                countrySection(for: group)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Color.background)
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search by name or capital")
        .task { countryDataService.loadCountries() }
    }
}

// MARK: - Models

private extension CountryListScreen {
    struct CountryGroup {
        let continent: Country.Continent
        let countries: [Country]
    }
}

// MARK: - Subviews

private extension CountryListScreen {
    var continentFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                continentChip(title: "All", continent: nil)
                ForEach(Country.Continent.allCases, id: \.self) { continent in
                    continentChip(title: continent.displayName, continent: continent)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    func continentChip(title: String, continent: Country.Continent?) -> some View {
        let isSelected = selectedContinent == continent
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedContinent = continent
            }
        } label: {
            Text(title)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    func countrySection(for group: CountryGroup) -> some View {
        Section {
            ForEach(group.countries) { country in
                countryRow(for: country)
            }
        } header: {
            Text(group.continent.displayName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    func countryRow(for country: Country) -> some View {
        NavigationLink(value: country) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(country.flagEmoji)
                    .font(DesignSystem.Font.title)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(country.name)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Label(country.capital, systemImage: "star.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .listRowBackground(DesignSystem.Color.cardBackground)
    }
}

// MARK: - Helpers

private extension CountryListScreen {
    var filteredCountries: [Country] {
        var countries = countryDataService.countries

        if let selectedContinent {
            countries = countries.filter { $0.continent == selectedContinent }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            countries = countries.filter {
                $0.name.lowercased().contains(query) ||
                $0.capital.lowercased().contains(query)
            }
        }

        return countries
    }

    var groupedCountries: [CountryGroup] {
        let grouped = Dictionary(grouping: filteredCountries, by: \.continent)

        return Country.Continent.allCases.compactMap { continent in
            guard let countries = grouped[continent], !countries.isEmpty else { return nil }
            return CountryGroup(
                continent: continent,
                countries: countries.sorted { $0.name < $1.name }
            )
        }
    }
}
