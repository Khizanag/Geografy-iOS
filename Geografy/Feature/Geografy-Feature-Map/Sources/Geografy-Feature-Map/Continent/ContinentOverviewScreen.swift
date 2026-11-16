import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

private enum SortOption: String, CaseIterable {
    case name = "Name"
    case population = "Population"
    case area = "Area"
    case gdp = "GDP"

    var icon: String {
        switch self {
        case .name: "textformat"
        case .population: "person.3"
        case .area: "map"
        case .gdp: "chart.bar"
        }
    }
}

public struct ContinentOverviewScreen: View {
    // MARK: - Init
    public init(
        continent: Country.Continent
    ) {
        self.continent = continent
    }
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    public let continent: Country.Continent

    @State private var sortBy: SortOption = .name

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(continent.displayName)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        coordinator.cover(MapRoute.map(continentFilter: continent))
                    } label: {
                        Label("Map", systemImage: "map.fill")
                            .foregroundStyle(DesignSystem.Color.iconPrimary)
                    }
                }
            }
    }
}

// MARK: - Navigation
private extension ContinentOverviewScreen {
    func navigateToCountry(_ country: Country) {
        coordinator.push(CountryRoute.countryDetail(country))
    }
}

// MARK: - Computed Properties
private extension ContinentOverviewScreen {
    var continentCountries: [Country] {
        countryDataService.countries.filter { $0.continent == continent }
    }

    func sorted(_ countries: [Country]) -> [Country] {
        countries.sorted { lhs, rhs in
            switch sortBy {
            case .name: lhs.name < rhs.name
            case .population: lhs.population > rhs.population
            case .area: lhs.area > rhs.area
            case .gdp: (lhs.gdpPerCapita ?? 0) > (rhs.gdpPerCapita ?? 0)
            }
        }
    }

    func averageGDPPerCapita(of countries: [Country]) -> Double? {
        let values = countries.compactMap(\.gdpPerCapita)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    func mostSpokenLanguage(in countries: [Country]) -> String? {
        var weights: [String: Double] = [:]
        for country in countries {
            for language in country.languages {
                weights[language.name, default: 0] += language.percentage
            }
        }
        return weights.max { $0.value < $1.value }?.key
    }
}

// MARK: - Subviews
private extension ContinentOverviewScreen {
    var scrollContent: some View {
        let countries = continentCountries
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                statsGrid(countries)
                countryListSection(sorted(countries))
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Stats Grid
private extension ContinentOverviewScreen {
    func statsGrid(_ countries: [Country]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            sizeTiles(countries)
            profileTiles(countries)
        }
    }

    @ViewBuilder
    func sizeTiles(_ countries: [Country]) -> some View {
        let totalPopulation = countries.reduce(0) { $0 + $1.population }
        let totalArea = countries.reduce(0.0) { $0 + $1.area }
        StatTile(
            value: "\(countries.count)",
            label: "Countries",
            icon: "flag.fill",
            color: DesignSystem.Color.accent
        )
        StatTile(
            value: totalPopulation.formatPopulation(),
            label: "Total Population",
            icon: "person.3.fill",
            color: DesignSystem.Color.blue
        )
        if totalArea > 0 {
            StatTile(
                value: "\(Int(totalArea / 1_000_000))M km²",
                label: "Total Area",
                icon: "map.fill",
                color: DesignSystem.Color.success
            )
        }
        if let largest = countries.max(by: { $0.area < $1.area }) {
            StatTile(
                value: "\(largest.name) (\(Int(largest.area / 1_000))K km²)",
                label: "Largest Country",
                icon: "arrow.up.right.and.arrow.down.left.rectangle.fill",
                color: DesignSystem.Color.warning
            )
        }
    }

    @ViewBuilder
    func profileTiles(_ countries: [Country]) -> some View {
        if let smallest = countries.filter({ $0.area > 0 }).min(by: { $0.area < $1.area }) {
            StatTile(
                value: smallest.name,
                label: "Smallest Country",
                icon: "smallcircle.filled.circle",
                color: DesignSystem.Color.orange
            )
        }
        if let average = averageGDPPerCapita(of: countries) {
            StatTile(
                value: average.formatted(.currency(code: "USD").precision(.fractionLength(0))),
                label: "Avg GDP per Capita",
                icon: "dollarsign.circle.fill",
                color: DesignSystem.Color.purple
            )
        }
        if let language = mostSpokenLanguage(in: countries) {
            StatTile(
                value: language,
                label: "Most Spoken Language",
                icon: "bubble.left.fill",
                color: DesignSystem.Color.indigo
            )
        }
    }
}

// MARK: - Country List
private extension ContinentOverviewScreen {
    func countryListSection(_ countries: [Country]) -> some View {
        LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            countryListHeader
            countryListRows(countries)
        }
    }

    var countryListHeader: some View {
        HStack {
            SectionHeaderView(title: "Countries", icon: "list.bullet")
            Spacer()
            MenuPicker("Sort by", selection: $sortBy, selectedTitle: Text(sortBy.rawValue)) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Label(option.rawValue, systemImage: option.icon)
                        .tag(option)
                }
            }
        }
    }

    func countryListRows(_ countries: [Country]) -> some View {
        ForEach(Array(countries.enumerated()), id: \.element.code) { index, country in
            Button { navigateToCountry(country) } label: {
                CardView {
                    CountryListRow(country: country) {
                        RowChevron()
                    }
                    .padding(DesignSystem.Spacing.sm)
                }
            }
            .buttonStyle(PressButtonStyle())
            .phaseEntrance(index: index, stagger: 0.03)
        }
    }
}
