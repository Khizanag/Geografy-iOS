import SwiftUI

enum FavoritesSortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case name = "Name"
    case continent = "Continent"
}

struct FavoritesScreen: View {
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(HapticsService.self) private var hapticsService

    @State private var countryDataService = CountryDataService()
    @State private var searchText = ""
    @State private var sortBy: FavoritesSortOption = .dateAdded
    @State private var sortAscending = false
    @State private var continentFilter: Country.Continent?

    var body: some View {
        ScrollView {
            if filteredCountries.isEmpty {
                emptyState
            } else {
                countryList
            }
        }
        .navigationTitle("Favorites")
        .searchable(text: $searchText, prompt: "Search favorites")
        .toolbar { toolbarContent }
        .task { countryDataService.loadCountries() }
    }
}

// MARK: - Toolbar

private extension FavoritesScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            countLabel
        }
        ToolbarItem(placement: .topBarTrailing) {
            CircleCloseButton()
        }
        ToolbarItem(placement: .topBarTrailing) {
            optionsMenu
        }
    }

    var countLabel: some View {
        let total = favoritesService.favoriteCodes.count
        let shown = filteredCountries.count
        let text = searchText.isEmpty && continentFilter == nil
            ? "\(total) \(total == 1 ? "country" : "countries")"
            : "\(shown) of \(total)"
        return Text(text)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var optionsMenu: some View {
        Menu {
            sortSection
            Divider()
            continentSection
        } label: {
            let hasActiveFilter = continentFilter != nil || sortBy != .dateAdded
            Image(
                systemName: hasActiveFilter
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease"
            )
            .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
    }

    var sortSection: some View {
        Group {
            Picker(selection: $sortBy) {
                ForEach(FavoritesSortOption.allCases, id: \.self) { option in
                    Label(option.rawValue, systemImage: sortIcon(for: option))
                        .tag(option)
                }
            } label: {
                Label("Sort by", systemImage: "arrow.up.arrow.down")
            }
            .pickerStyle(.menu)

            Button {
                sortAscending.toggle()
            } label: {
                Label(
                    sortAscending ? "Ascending" : "Descending",
                    systemImage: sortAscending ? "arrow.up" : "arrow.down"
                )
            }
        }
    }

    var continentSection: some View {
        Picker(selection: $continentFilter) {
            Label("All Continents", systemImage: "globe")
                .tag(Country.Continent?.none)
            Divider()
            ForEach(Country.Continent.allCases, id: \.self) { continent in
                Text(continent.displayName)
                    .tag(Country.Continent?.some(continent))
            }
        } label: {
            Label("Continent", systemImage: "globe.americas")
        }
        .pickerStyle(.menu)
    }

    func sortIcon(for option: FavoritesSortOption) -> String {
        switch option {
        case .dateAdded: "clock"
        case .name: "textformat"
        case .continent: "globe"
        }
    }
}

// MARK: - Content

private extension FavoritesScreen {
    var countryList: some View {
        LazyVStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(filteredCountries) { country in
                NavigationLink(value: country) {
                    CountryRowView(
                        country: country,
                        isFavorite: true,
                        showContinent: true,
                        onFavoriteTap: {
                            favoritesService.toggle(code: country.code)
                        }
                    )
                }
                .buttonStyle(PressButtonStyle())
                .simultaneousGesture(TapGesture().onEnded {
                    hapticsService.impact(.light)
                })
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    removeButton(for: country)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xxl)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    func removeButton(for country: Country) -> some View {
        Button(role: .destructive) {
            hapticsService.impact(.medium)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesService.toggle(code: country.code)
            }
        } label: {
            Label("Remove", systemImage: "heart.slash.fill")
        }
    }

    var emptyState: some View {
        let hasSearch = !searchText.isEmpty || continentFilter != nil
        return EmptyStateView(
            icon: hasSearch ? "magnifyingglass" : "heart.slash",
            title: hasSearch ? "No Results" : "No Favorites Yet",
            subtitle: hasSearch
                ? "Try a different search or filter."
                : "Tap the heart icon on any country to save it here."
        )
    }
}

// MARK: - Helpers

private extension FavoritesScreen {
    var filteredCountries: [Country] {
        var countries = countryDataService.countries.filter {
            favoritesService.isFavorite(code: $0.code)
        }

        if let continentFilter {
            countries = countries.filter { $0.continent == continentFilter }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            countries = countries.filter {
                $0.name.lowercased().contains(query) ||
                $0.allCapitals.contains { $0.name.lowercased().contains(query) }
            }
        }

        return countries.sorted { lhs, rhs in
            let ascending = compareCountries(lhs, rhs)
            return sortAscending ? ascending : !ascending
        }
    }

    func compareCountries(_ lhs: Country, _ rhs: Country) -> Bool {
        switch sortBy {
        case .dateAdded:
            let lhsDate = favoritesService.addedAt(code: lhs.code) ?? .distantPast
            let rhsDate = favoritesService.addedAt(code: rhs.code) ?? .distantPast
            return lhsDate < rhsDate
        case .name:
            return lhs.name < rhs.name
        case .continent:
            return lhs.continent.displayName < rhs.continent.displayName
        }
    }
}
