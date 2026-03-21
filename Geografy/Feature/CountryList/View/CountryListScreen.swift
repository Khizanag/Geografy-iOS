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
    @State private var groupBy: GroupOption = .firstLetter
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
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .background(DesignSystem.Color.background)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Countries")
        .searchable(text: $searchText, prompt: "Search by name, capital, or currency")
        .toolbar { toolbarContent }
        .task {
            countryDataService.loadCountries()
        }
        .onChange(of: groupBy) {
            expandedSections = Set(sectionKeys)
        }
        .onChange(of: countryDataService.countries.count) {
            if expandedSections.isEmpty {
                expandedSections = Set(sectionKeys)
            }
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
            let icon = hasActiveFilters
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease"
            Image(systemName: icon)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
        .tint(DesignSystem.Color.textPrimary)
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
                .foregroundStyle(DesignSystem.Color.error)
        }
    }

    var groupBySubmenu: some View {
        Menu {
            ForEach(GroupOption.allCases, id: \.self) { option in
                Button {
                    withAnimation { groupBy = option }
                } label: {
                    Label(option.rawValue, systemImage: groupIcon(for: option))
                }
            }
        } label: {
            Label("Group by", systemImage: "rectangle.3.group")
        }
    }

    var sortBySubmenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortBy = option
                } label: {
                    Label(option.rawValue, systemImage: sortIcon(for: option))
                }
            }
        } label: {
            Label("Sort by", systemImage: "arrow.up.arrow.down")
        }
    }

    var continentFilterSubmenu: some View {
        Menu {
            Button {
                continentFilter = nil
            } label: {
                Label("All Continents", systemImage: "globe")
            }

            Divider()

            ForEach(Country.Continent.allCases, id: \.self) { continent in
                Button {
                    continentFilter = continent
                } label: {
                    Label(continent.displayName, systemImage: continentIcon(for: continent))
                }
            }
        } label: {
            Label("Continent", systemImage: "globe.americas")
        }
    }

    func groupIcon(for option: GroupOption) -> String {
        switch option {
        case .none: "list.bullet"
        case .firstLetter: "textformat.abc"
        case .continent: "globe.americas"
        case .government: "building.columns"
        }
    }

    func sortIcon(for option: SortOption) -> String {
        switch option {
        case .name: "textformat"
        case .population: "person.3"
        case .area: "map"
        case .gdp: "chart.bar"
        }
    }

    func continentIcon(for continent: Country.Continent) -> String {
        switch continent {
        case .africa: "globe.europe.africa"
        case .asia: "globe.asia.australia"
        case .europe: "globe.europe.africa"
        case .northAmerica: "globe.americas"
        case .southAmerica: "globe.americas"
        case .oceania: "globe.asia.australia"
        case .antarctica: "snowflake"
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
                sectionHeader(key: section.key, count: section.countries.count)
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
        .buttonStyle(.plain)
    }

    func sectionHeaderLabel(key: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                Circle()
                    .strokeBorder(DesignSystem.Color.accent.opacity(0.3), lineWidth: 1)
                Text(String(key.prefix(1)).uppercased())
                    .font(.system(size: groupBy == .firstLetter ? 16 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .frame(width: groupBy == .firstLetter ? 36 : 30, height: groupBy == .firstLetter ? 36 : 30)

            if groupBy != .firstLetter {
                Text(key)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }

            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)

            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .monospacedDigit()
                Image(
                    systemName: expandedSections.contains(key) ? "chevron.up" : "chevron.down"
                )
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Country Card

private extension CountryListScreen {
    func countryCard(for country: Country) -> some View {
        let isFavorite = favoritesService.isFavorite(code: country.code)
        return NavigationLink(value: country) {
            cardContent(for: country)
        }
        .buttonStyle(GeoPressButtonStyle())
        .simultaneousGesture(TapGesture().onEnded {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        })
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
    }

    func cardContent(for country: Country) -> some View {
        HStack(spacing: 0) {
            accentStripe(for: country)

            HStack(spacing: DesignSystem.Spacing.sm) {
                if showFlag {
                    FlagView(countryCode: country.code, height: 36)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(country.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    if showCapital {
                        capitalLabel(for: country)
                    }

                    if showArea || showPopulation {
                        statsRow(for: country)
                    }
                }

                Spacer(minLength: 0)

                trailingContent(for: country)
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.trailing, DesignSystem.Spacing.sm)
            .padding(.leading, DesignSystem.Spacing.xs)
        }
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    func accentStripe(for country: Country) -> some View {
        let codeValue = country.code.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let color = DesignSystem.Color.mapColors[codeValue % DesignSystem.Color.mapColors.count]
        return color
            .frame(width: 3)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: DesignSystem.CornerRadius.medium,
                    bottomLeadingRadius: DesignSystem.CornerRadius.medium,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )
    }

    func capitalLabel(for country: Country) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "mappin.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(DesignSystem.Color.accent)
            Text(country.allCapitals.map(\.name).joined(separator: " · "))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    func trailingContent(for country: Country) -> some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
            continentBadge(for: country)
            favoriteButton(for: country)
        }
    }

    func favoriteButton(for country: Country) -> some View {
        let isFav = favoritesService.isFavorite(code: country.code)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesService.toggle(code: country.code)
            }
        } label: {
            Image(systemName: isFav ? "heart.fill" : "heart")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isFav ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                .symbolEffect(.bounce, value: isFav)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    func continentBadge(for country: Country) -> some View {
        Text(country.continent.displayName)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())
    }

    func statsRow(for country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if showArea {
                HStack(spacing: 3) {
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
                HStack(spacing: 3) {
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
