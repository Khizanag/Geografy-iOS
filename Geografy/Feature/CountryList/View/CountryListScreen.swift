import SwiftUI

// MARK: - Enums

enum GroupOption: String, CaseIterable {
    case none = "None"
    case firstLetter = "A–Z"
    case continent = "Continent"
    case government = "Government"
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case population = "Population"
    case area = "Area"
    case gdp = "GDP"
}

// MARK: - CountryListScreen

struct CountryListScreen: View {
    @Environment(FavoritesService.self) private var favoritesService
    @State private var countryDataService = CountryDataService()
    @State private var searchText = ""
    @State private var groupBy: GroupOption = .none
    @State private var sortBy: SortOption = .name
    @State private var sortAscending = true
    @State private var continentFilter: Country.Continent?
    @State private var expandedSections: Set<String> = []
    @State private var showFlag = true
    @State private var showCapital = true
    @State private var showArea = true
    @State private var showPopulation = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xs, pinnedViews: .sectionHeaders) {
                if groupBy == .none {
                    Section {
                        flatContent
                    }
                } else {
                    groupedContent
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Color.background)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search by name, capital, or currency")
        .toolbar { toolbarContent }
        .task { countryDataService.loadCountries() }
        .onChange(of: groupBy) { expandedSections = Set(sectionKeys) }
    }
}

// MARK: - Toolbar

private extension CountryListScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            sortOrderButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            filterMenu
        }
    }

    var sortOrderButton: some View {
        Button {
            sortAscending.toggle()
        } label: {
            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
    }

    var filterMenu: some View {
        Menu {
            groupBySubmenu
            sortBySubmenu
            Divider()
            continentFilterSubmenu
            Divider()
            displaySubmenu
            Divider()
            resetButton
        } label: {
            let filterIcon = hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease"
            Image(systemName: filterIcon)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
    }

    var hasActiveFilters: Bool {
        groupBy != .none || sortBy != .name || !sortAscending || continentFilter != nil
    }

    var displaySubmenu: some View {
        Menu("Display") {
            Toggle("Flag", isOn: $showFlag)
            Toggle("Capital", isOn: $showCapital)
            Toggle("Area", isOn: $showArea)
            Toggle("Population", isOn: $showPopulation)
        }
    }

    var resetButton: some View {
        Button(role: .destructive) {
            withAnimation {
                groupBy = .none
                sortBy = .name
                sortAscending = true
                continentFilter = nil
                searchText = ""
                showFlag = true
                showCapital = true
                showArea = true
                showPopulation = true
            }
        } label: {
            Label("Reset All", systemImage: "arrow.counterclockwise")
                .foregroundStyle(DesignSystem.Color.error)
        }
    }

    var groupBySubmenu: some View {
        Menu("Group by") {
            ForEach(GroupOption.allCases, id: \.self) { option in
                Button {
                    withAnimation { groupBy = option }
                } label: {
                    if groupBy == option {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        }
    }

    var sortBySubmenu: some View {
        Menu("Sort by") {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortBy = option
                } label: {
                    if sortBy == option {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        }
    }

    var continentFilterSubmenu: some View {
        Menu("Filter") {
            Button {
                continentFilter = nil
            } label: {
                if continentFilter == nil {
                    Label("All Continents", systemImage: "checkmark")
                } else {
                    Text("All Continents")
                }
            }

            Divider()

            ForEach(Country.Continent.allCases, id: \.self) { continent in
                Button {
                    continentFilter = continent
                } label: {
                    if continentFilter == continent {
                        Label(continent.displayName, systemImage: "checkmark")
                    } else {
                        Text(continent.displayName)
                    }
                }
            }
        }
    }
}

// MARK: - List Content

private extension CountryListScreen {
    var flatContent: some View {
        ForEach(sortedCountries) { country in
            countryCard(for: country)
        }
    }

    var groupedContent: some View {
        ForEach(groupedSections, id: \.key) { section in
            Section {
                if expandedSections.contains(section.key) {
                    ForEach(section.countries) { country in
                        countryCard(for: country)
                    }
                }
            } header: {
                sectionHeaderView(key: section.key, count: section.countries.count)
            }
        }
    }

    func sectionHeaderView(key: String, count: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                if expandedSections.contains(key) {
                    expandedSections.remove(key)
                } else {
                    expandedSections.insert(key)
                }
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(key)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer()

                Text("\(count)")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
                    .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())

                Image(systemName: expandedSections.contains(key) ? "chevron.up" : "chevron.down")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.background)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Country Card

private extension CountryListScreen {
    func countryCard(for country: Country) -> some View {
        NavigationLink(value: country) {
            GeoCard {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if showFlag {
                        FlagView(countryCode: country.code, height: DesignSystem.Size.md)
                    }

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(country.name)
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .lineLimit(1)

                        if showCapital {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(DesignSystem.Font.caption2)
                                    .foregroundStyle(DesignSystem.Color.accent)
                                Text(country.allCapitals.map(\.name).joined(separator: " · "))
                                    .font(DesignSystem.Font.caption)
                                    .foregroundStyle(DesignSystem.Color.textSecondary)
                                    .lineLimit(1)
                            }
                        }

                        if showArea || showPopulation {
                            statsRow(for: country)
                        }
                    }

                    Spacer(minLength: 0)

                    if favoritesService.isFavorite(code: country.code) {
                        Image(systemName: "heart.fill")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.error)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(GeoPressButtonStyle())
        .simultaneousGesture(TapGesture().onEnded {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        })
    }

    func statsRow(for country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if showArea {
                HStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Text(country.area.formatArea())
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }

            if showArea, showPopulation {
                Text("·")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            if showPopulation {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Text(country.population.formatPopulation())
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
        }
    }
}

// MARK: - Helpers

private extension CountryListScreen {
    var filteredCountries: [Country] {
        var countries = countryDataService.countries

        if let continentFilter {
            countries = countries.filter { $0.continent == continentFilter }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            countries = countries.filter {
                $0.name.lowercased().contains(query) ||
                $0.allCapitals.contains { $0.name.lowercased().contains(query) } ||
                $0.currency.name.lowercased().contains(query)
            }
        }

        return countries
    }

    var sortedCountries: [Country] {
        filteredCountries.sorted { lhs, rhs in
            let result = compareCountries(lhs, rhs)
            return sortAscending ? result : !result
        }
    }

    func compareCountries(_ lhs: Country, _ rhs: Country) -> Bool {
        switch sortBy {
        case .name: lhs.name < rhs.name
        case .population: lhs.population < rhs.population
        case .area: lhs.area < rhs.area
        case .gdp: (lhs.gdp ?? 0) < (rhs.gdp ?? 0)
        }
    }

    var sectionKeys: [String] {
        groupedSections.map(\.key)
    }

    var groupedSections: [(key: String, countries: [Country])] {
        let sorted = sortedCountries

        let grouped: [String: [Country]] = switch groupBy {
        case .none:
            [:]
        case .firstLetter:
            Dictionary(grouping: sorted) { String($0.name.prefix(1)).uppercased() }
        case .continent:
            Dictionary(grouping: sorted) { $0.continent.displayName }
        case .government:
            Dictionary(grouping: sorted) { $0.formOfGovernment }
        }

        return grouped
            .map { (key: $0.key, countries: $0.value) }
            .sorted { $0.key < $1.key }
    }
}
