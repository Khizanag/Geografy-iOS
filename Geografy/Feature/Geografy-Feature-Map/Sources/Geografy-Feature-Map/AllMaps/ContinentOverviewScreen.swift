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
                        coordinator.cover(.map(continentFilter: continent))
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
        coordinator.push(.countryDetail(country))
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
        statTile(
            icon: "flag.fill",
            label: "Countries",
            value: "\(countries.count)",
            color: DesignSystem.Color.accent
        )
        statTile(
            icon: "person.3.fill",
            label: "Total Population",
            value: totalPopulation.formatPopulation(),
            color: DesignSystem.Color.blue
        )
        if totalArea > 0 {
            statTile(
                icon: "map.fill",
                label: "Total Area",
                value: "\(Int(totalArea / 1_000_000))M km²",
                color: DesignSystem.Color.success
            )
        }
        if let largest = countries.max(by: { $0.area < $1.area }) {
            statTile(
                icon: "arrow.up.right.and.arrow.down.left.rectangle.fill",
                label: "Largest Country",
                value: "\(largest.name) (\(Int(largest.area / 1_000))K km²)",
                color: DesignSystem.Color.warning
            )
        }
    }

    @ViewBuilder
    func profileTiles(_ countries: [Country]) -> some View {
        if let smallest = countries.filter({ $0.area > 0 }).min(by: { $0.area < $1.area }) {
            statTile(
                icon: "smallcircle.filled.circle",
                label: "Smallest Country",
                value: smallest.name,
                color: DesignSystem.Color.orange
            )
        }
        if let average = averageGDPPerCapita(of: countries) {
            statTile(
                icon: "dollarsign.circle.fill",
                label: "Avg GDP per Capita",
                value: average.formatted(.currency(code: "USD").precision(.fractionLength(0))),
                color: DesignSystem.Color.purple
            )
        }
        if let language = mostSpokenLanguage(in: countries) {
            statTile(
                icon: "bubble.left.fill",
                label: "Most Spoken Language",
                value: language,
                color: DesignSystem.Color.indigo
            )
        }
    }

    func statTile(icon: String, label: String, value: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(color)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(value)
                    .font(DesignSystem.Font.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.sm)
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
