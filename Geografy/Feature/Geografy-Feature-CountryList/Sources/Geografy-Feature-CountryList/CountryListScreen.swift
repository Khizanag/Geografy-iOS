import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

// MARK: - Enums
public enum GroupOption: String, CaseIterable {
    case none = "None"
    case firstLetter = "A–Z"
    case continent = "Continent"
    case government = "Government"
}

public enum SortOption: String, CaseIterable {
    case name = "Name"
    case population = "Population"
    case area = "Area"
    case gdp = "GDP"

    public var icon: String {
        switch self {
        case .name: "textformat"
        case .population: "person.3"
        case .area: "map"
        case .gdp: "chart.bar"
        }
    }
}

// MARK: - CountryListScreen
public struct CountryListScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var searchText = ""
    @State private var groupBy: GroupOption = .firstLetter
    @State private var sortBy: SortOption = .name
    @State private var sortAscending = true
    @State private var continentFilter: Country.Continent?
    @State private var expandedSections: Set<String> = []
    @State private var showFlag = true
    @State private var showCapital = true
    @State private var showArea = true
    @State private var showPopulation = true

    public init() {}

    public var body: some View {
        listContent
            .navigationTitle("Countries")
            .closeButtonPlacementLeading()
            .searchable(text: $searchText, prompt: "Search by name, capital, or currency")
            .toolbar { toolbarContent }
            .onAppear { expandedSections = Set(sectionKeys) }
            .onChange(of: groupBy) { expandedSections = Set(sectionKeys) }
            .onChange(of: countryDataService.countries.count) { expandedSections = Set(sectionKeys) }
    }
}

// MARK: - Subviews
private extension CountryListScreen {
    var listContent: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
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
                    .padding(.leading, DesignSystem.Spacing.md)
                    .padding(.trailing, showJumpIndex ? DesignSystem.Spacing.md + 18 : DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                    .padding(.top, DesignSystem.Spacing.xs)
                    .readableContentWidth()
                }
                .background(DesignSystem.Color.background)
                .scrollDismissesKeyboard(.interactively)

                if showJumpIndex {
                    AlphabetJumpIndex(letters: sectionKeys) { letter in
                        hapticsService.selection()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedSections.insert(letter)
                            proxy.scrollTo(letter, anchor: .top)
                        }
                    }
                    .padding(.trailing, DesignSystem.Spacing.xxs)
                }
            }
        }
    }
}

// MARK: - Toolbar
private extension CountryListScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        #if !os(tvOS)
        ToolbarItem(placement: .secondaryAction) {
            sortOrderButton
        }
        #endif
        ToolbarItem(placement: .primaryAction) {
            filterMenu
        }
    }

    var sortOrderButton: some View {
        Button {
            sortAscending.toggle()
        } label: {
            Label(
                sortAscending ? "Sort Ascending" : "Sort Descending",
                systemImage: sortAscending ? "arrow.up" : "arrow.down"
            )
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
            resetButton
        } label: {
            Label(
                "Filter",
                systemImage: hasActiveFilters
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease"
            )
        }
        .tint(DesignSystem.Color.onAccent)
    }

    var hasActiveFilters: Bool {
        groupBy != .firstLetter || sortBy != .name || !sortAscending || continentFilter != nil
    }

    var displaySubmenu: some View {
        Menu {
            Toggle(isOn: $showFlag) { Label("Flag", systemImage: "flag.fill") }
            Toggle(isOn: $showCapital) { Label("Capital", systemImage: "mappin") }
            Toggle(isOn: $showArea) { Label("Area", systemImage: "map") }
            Toggle(isOn: $showPopulation) { Label("Population", systemImage: "person.2") }
        } label: {
            Label("Display", systemImage: "eye")
        }
    }

    var resetButton: some View {
        Button(role: .destructive) {
            withAnimation {
                groupBy = .firstLetter
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
        Picker(selection: $groupBy.animation()) {
            ForEach(GroupOption.allCases, id: \.self) { option in
                Label(option.rawValue, systemImage: groupIcon(for: option))
                    .tag(option)
            }
        } label: {
            Label("Group by", systemImage: "rectangle.3.group")
        }
        .pickerStyle(.menu)
    }

    var sortBySubmenu: some View {
        Picker(selection: $sortBy) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Label(option.rawValue, systemImage: option.icon)
                    .tag(option)
            }
        } label: {
            Label("Sort by", systemImage: "arrow.up.arrow.down")
        }
        .pickerStyle(.menu)
    }

    var continentFilterSubmenu: some View {
        Picker(selection: $continentFilter) {
            Label("All Continents", systemImage: "globe")
                .tag(Country.Continent?.none)

            Divider()

            ForEach(Country.Continent.allCases, id: \.self) { continent in
                Label(continent.displayName, systemImage: continentIcon(for: continent))
                    .tag(Country.Continent?.some(continent))
            }
        } label: {
            Label("Continent", systemImage: "globe.americas")
        }
        .pickerStyle(.menu)
    }

    func groupIcon(for option: GroupOption) -> String {
        switch option {
        case .none: "list.bullet"
        case .firstLetter: "textformat.abc"
        case .continent: "globe.americas"
        case .government: "building.columns"
        }
    }

    func continentIcon(for continent: Country.Continent) -> String {
        continent.icon
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
                sectionHeader(key: section.key, count: section.countries.count)
                    .id(section.key)
            }
        }
    }

    func sectionHeader(key: String, count: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if expandedSections.contains(key) {
                    expandedSections.remove(key)
                } else {
                    expandedSections.insert(key)
                }
            }
        } label: {
            sectionHeaderLabel(key: key, count: count)
        }
        .buttonStyle(PressButtonStyle())
    }

    func sectionHeaderLabel(key: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            sectionKeyBadge(key: key)

            if groupBy != .firstLetter {
                Text(key)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }

            Rectangle()
                .fill(DesignSystem.Color.dividerSubtle)
                .frame(height: 1)

            sectionCountChevron(key: key, count: count)
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity)
    }

    func sectionKeyBadge(key: String) -> some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
            Circle()
                .strokeBorder(DesignSystem.Color.accent.opacity(0.3), lineWidth: 1)
            Text(String(key.prefix(1)).uppercased())
                .font(
                    DesignSystem.Font.system(
                        size: groupBy == .firstLetter ? 16 : 13,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .frame(width: groupBy == .firstLetter ? 36 : 30, height: groupBy == .firstLetter ? 36 : 30)
    }

    func sectionCountChevron(key: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text("\(count)")
                .font(DesignSystem.Font.micro.weight(.semibold))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .monospacedDigit()
            Image(
                systemName: expandedSections.contains(key) ? "chevron.up" : "chevron.down"
            )
            .font(DesignSystem.Font.nano.bold())
            .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())
    }
}

// MARK: - Country Card
private extension CountryListScreen {
    func countryCard(for country: Country) -> some View {
        let isFavorite = favoritesService.isFavorite(code: country.code)
        return Button {
            coordinator.push(.countryDetail(country))
            hapticsService.impact(.light)
        } label: {
            CountryRowView(
                country: country,
                isFavorite: isFavorite,
                showFlag: showFlag,
                showCapital: showCapital,
                showStats: showArea || showPopulation,
                showContinent: true,
                onFavoriteTap: { favoritesService.toggle(code: country.code) }
            )
        }
        .buttonStyle(PressButtonStyle())
        .simultaneousGesture(TapGesture().onEnded {
            hapticsService.impact(.light)
        })
        #if !os(tvOS)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                hapticsService.impact(.medium)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesService.toggle(code: country.code)
                }
            } label: {
                Label(
                    isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: isFavorite ? "heart.slash.fill" : "heart.fill"
                )
            }
            .tint(isFavorite ? DesignSystem.Color.textSecondary : DesignSystem.Color.error)
        }
        #endif
    }
}

// MARK: - Helpers
private extension CountryListScreen {
    var showJumpIndex: Bool {
        groupBy == .firstLetter && !sectionKeys.isEmpty && searchText.isEmpty
    }

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
