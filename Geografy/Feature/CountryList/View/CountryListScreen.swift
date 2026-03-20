import SwiftUI

// MARK: - Enums

enum GroupOption: String, CaseIterable {
    case none = "None"
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
        List {
            if groupBy == .none {
                flatList
            } else {
                groupedList
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Color.background)
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search by name, capital, or currency")
        .toolbar { toolbarContent }
        .task {
            countryDataService.loadCountries()
        }
        .onChange(of: groupBy) {
            expandedSections = Set(sectionKeys)
        }
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
                .foregroundStyle(DesignSystem.Color.accent)
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
            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease")
                .foregroundStyle(DesignSystem.Color.accent)
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
    var flatList: some View {
        ForEach(sortedCountries) { country in
            countryRow(for: country)
        }
    }

    var groupedList: some View {
        ForEach(groupedSections, id: \.key) { section in
            sectionView(key: section.key, countries: section.countries)
        }
    }

    func sectionView(key: String, countries: [Country]) -> some View {
        Section(isExpanded: sectionBinding(for: key)) {
            ForEach(countries) { country in
                countryRow(for: country)
            }
        } header: {
            HStack {
                Text(key)

                Spacer()

                Text("\(countries.count)")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
                    .background(
                        DesignSystem.Color.cardBackgroundHighlighted,
                        in: Capsule()
                    )
            }
        }
    }

    func sectionBinding(for key: String) -> Binding<Bool> {
        Binding(
            get: { expandedSections.contains(key) },
            set: { isExpanded in
                if isExpanded {
                    expandedSections.insert(key)
                } else {
                    expandedSections.remove(key)
                }
            }
        )
    }
}

// MARK: - Country Row

private extension CountryListScreen {
    func countryRow(for country: Country) -> some View {
        NavigationLink(value: country) {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
                if showFlag {
                    flagView(for: country)
                }
                countryDetails(for: country)
            }
            .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .listRowBackground(DesignSystem.Color.cardBackground)
    }

    func flagView(for country: Country) -> some View {
        Text(country.flagEmoji)
            .font(DesignSystem.IconSize.large)
            .frame(
                width: DesignSystem.Size.xl,
                height: DesignSystem.Size.xl
            )
    }

    func countryDetails(for country: Country) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(country.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            if showCapital {
                capitalLabel(for: country)
            }
            if showArea || showPopulation {
                statsLabel(for: country)
            }
        }
    }

    func capitalLabel(for country: Country) -> some View {
        Label {
            Text(country.capital)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        } icon: {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    func statsLabel(for country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if showArea {
                Label {
                    Text(country.area.formatArea())
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                } icon: {
                    Image(systemName: "map")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }

            if showArea, showPopulation {
                Text("\u{00B7}")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            if showPopulation {
                Label {
                    Text(country.population.formatPopulation())
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                } icon: {
                    Image(systemName: "person.2")
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
                $0.capital.lowercased().contains(query) ||
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
