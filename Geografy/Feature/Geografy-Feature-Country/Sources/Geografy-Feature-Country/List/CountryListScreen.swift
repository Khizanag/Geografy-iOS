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
    // MARK: - Properties
    @Environment(\.locale) private var locale
    @Environment(Navigator.self) private var coordinator
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var state: CountryListState

    // MARK: - Init
    /// Pass a `state` the host keeps to have the list's choices outlive this screen.
    public init(state: CountryListState? = nil) {
        _state = State(initialValue: state ?? CountryListState())
    }

    // MARK: - Body
    public var body: some View {
        listContent
            .closeButtonPlacementLeading()
            .searchable(text: $state.searchText, prompt: "Search by name, capital, or currency")
            .overlay { searchEmptyOverlay }
            .toolbar { toolbarContent }
            .onAppear {
                // Only the first time, so groups collapsed before opening a country stay collapsed on return.
                if !state.hasSeededSections {
                    seedExpandedSections()
                }
            }
            .onChange(of: state.groupBy) { seedExpandedSections() }
            .onChange(of: countryDataService.countries.count) { seedExpandedSections() }
            .task(id: state.searchText) {
                try? await Task.sleep(for: .milliseconds(250))
                if !Task.isCancelled {
                    state.debouncedSearchText = state.searchText
                }
            }
    }

    @ViewBuilder
    private var searchEmptyOverlay: some View {
        if !state.debouncedSearchText.isEmpty, listing.sorted.isEmpty {
            NoSearchResultsView(query: state.debouncedSearchText)
        }
    }
}

// MARK: - Subviews
private extension CountryListScreen {
    var listContent: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                countryScrollView
                jumpIndex(proxy: proxy)
            }
        }
    }

    var countryScrollView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xs, pinnedViews: .sectionHeaders) {
                favoritesSection
                if state.groupBy == .none {
                    Section { flatContent }
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
        .screenBackground()
        .scrollDismissesKeyboard(.interactively)
    }

    @ViewBuilder
    func jumpIndex(proxy: ScrollViewProxy) -> some View {
        if showJumpIndex {
            AlphabetJumpIndex(letters: listing.sectionKeys) { letter in
                hapticsService.selection()
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    state.expandedSections.insert(letter)
                    proxy.scrollTo(letter, anchor: .top)
                }
            }
        }
    }
}

// MARK: - Toolbar
private extension CountryListScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            filterMenu
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
    }

    var hasActiveFilters: Bool {
        state.groupBy != .none || state.sortBy != .name || !state.sortAscending || state.continentFilter != nil
    }

    var displaySubmenu: some View {
        Menu {
            Toggle(isOn: $state.showFlag) { Label("Flag", systemImage: "flag.fill") }
            Toggle(isOn: $state.showCapital) { Label("Capital", systemImage: "star") }
            Toggle(isOn: $state.showArea) { Label("Area", systemImage: "map") }
            Toggle(isOn: $state.showPopulation) { Label("Population", systemImage: "person.2") }
        } label: {
            Label("Display", systemImage: "eye")
        }
    }

    var resetButton: some View {
        Button(role: .destructive) {
            withAnimation(reduceMotion ? nil : .default) {
                state.groupBy = .none
                state.sortBy = .name
                state.sortAscending = true
                state.continentFilter = nil
                state.searchText = ""
                state.showFlag = true
                state.showCapital = true
                state.showArea = true
                state.showPopulation = true
            }
        } label: {
            Label("Reset All", systemImage: "arrow.counterclockwise")
        }
        // The menu tints icons with the primary color; a destructive item keeps its icon red.
        .tint(DesignSystem.Color.destructive)
    }

    var groupBySubmenu: some View {
        Picker(selection: $state.groupBy.animation(reduceMotion ? nil : .default)) {
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
        Menu {
            Picker(selection: $state.sortBy) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Label(option.rawValue, systemImage: option.icon)
                        .tag(option)
                }
            } label: {
                Label("Field", systemImage: "textformat")
            }
            .pickerStyle(.inline)

            Divider()

            Picker(selection: $state.sortAscending) {
                Label("Ascending", systemImage: "arrow.up")
                    .tag(true)
                Label("Descending", systemImage: "arrow.down")
                    .tag(false)
            } label: {
                Label("Direction", systemImage: "arrow.up.arrow.down")
            }
            .pickerStyle(.inline)
        } label: {
            Label("Sort by", systemImage: "arrow.up.arrow.down")
        }
    }

    var continentFilterSubmenu: some View {
        Picker(selection: $state.continentFilter) {
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
    @ViewBuilder
    var favoritesSection: some View {
        let favorites = favoriteCountries
        if !favorites.isEmpty {
            FavoriteCountriesStrip(countries: favorites) { coordinator.push(CountryRoute.countryDetail($0)) }
                .padding(.bottom, DesignSystem.Spacing.md)
                .transition(.opacity)
            if state.groupBy == .none {
                SectionHeaderView(title: String(localized: "All Countries", bundle: .module, in: locale))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, DesignSystem.Spacing.xxs)
            }
        }
    }

    var flatContent: some View {
        ForEach(listing.sorted) { country in
            countryCard(for: country)
        }
    }

    var groupedContent: some View {
        ForEach(listing.sections, id: \.key) { section in
            Section {
                if state.expandedSections.contains(section.key) {
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
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.75)) {
                if state.expandedSections.contains(key) {
                    state.expandedSections.remove(key)
                } else {
                    state.expandedSections.insert(key)
                }
            }
        } label: {
            sectionHeaderLabel(key: key, count: count)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(key), \(count) countries")
        .accessibilityValue(state.expandedSections.contains(key) ? "Expanded" : "Collapsed")
        .accessibilityAddTraits([.isButton, .isHeader])
    }

    func sectionHeaderLabel(key: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            sectionKeyBadge(key: key)

            if state.groupBy != .firstLetter {
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
                .fill(DesignSystem.Color.cardBackgroundHighlighted)
            Circle()
                .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
            Text(String(key.prefix(1)).uppercased())
                .font(
                    DesignSystem.Font.system(
                        size: state.groupBy == .firstLetter ? 16 : 13,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .frame(width: state.groupBy == .firstLetter ? 36 : 30, height: state.groupBy == .firstLetter ? 36 : 30)
    }

    func sectionCountChevron(key: String, count: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text("\(count)")
                .font(DesignSystem.Font.micro.weight(.semibold))
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .monospacedDigit()
            Image(
                systemName: state.expandedSections.contains(key) ? "chevron.up" : "chevron.down"
            )
            .font(DesignSystem.Font.nano.bold())
            .foregroundStyle(DesignSystem.Color.textSecondary)
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
            coordinator.push(CountryRoute.countryDetail(country))
        } label: {
            CountryRowView(
                country: country,
                isFavorite: isFavorite,
                showFlag: state.showFlag,
                showCapital: state.showCapital,
                showArea: state.showArea,
                showPopulation: state.showPopulation,
                showContinent: true,
                onFavoriteTap: { favoritesService.toggle(code: country.code) }
            )
        }
        .buttonStyle(PressButtonStyle())
        .countryContextMenu(country, isFavorite: isFavorite)
        #if !os(tvOS)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                hapticsService.impact(.light)
                withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6)) {
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
    var listing: CountryListing {
        state.listing(of: countryDataService.countries)
    }

    var showJumpIndex: Bool {
        state.groupBy == .firstLetter && !listing.sectionKeys.isEmpty && state.debouncedSearchText.isEmpty
    }

    /// Hidden while searching, where favorites already show among the results.
    var favoriteCountries: [Country] {
        guard state.debouncedSearchText.isEmpty else { return [] }
        let codes = favoritesService.favoriteCodes
        return listing.sorted.filter { codes.contains($0.code) }
    }

    func seedExpandedSections() {
        state.expandedSections = Set(listing.sectionKeys)
        state.hasSeededSections = true
    }
}
