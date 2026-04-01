import Geografy_Core_Navigation
import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Core_DesignSystem
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
    public init(
        continent: Country.Continent
    ) {
        self.continent = continent
    }
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    public let continent: Country.Continent

    @State private var sortBy: SortOption = .name
    @State private var appeared = false

    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle(continent.displayName)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.large)
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
            .onAppear {
                appeared = true
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
    var countries: [Country] {
        countryDataService.countries
            .filter { $0.continent == continent }
            .sorted { lhs, rhs in
                switch sortBy {
                case .name: lhs.name < rhs.name
                case .population: lhs.population > rhs.population
                case .area: lhs.area > rhs.area
                case .gdp: (lhs.gdpPerCapita ?? 0) > (rhs.gdpPerCapita ?? 0)
                }
            }
    }

    var totalPopulation: Int {
        countries.reduce(0) { $0 + $1.population }
    }

    var totalArea: Double {
        countries.reduce(0.0) { $0 + $1.area }
    }

    var largestCountry: Country? {
        countries.max { $0.area < $1.area }
    }

    var mostPopulousCountry: Country? {
        countries.first
    }
}

// MARK: - Subviews
private extension ContinentOverviewScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                statsGrid
                countryListSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Stats Grid
private extension ContinentOverviewScreen {
    var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
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
            if let largest = largestCountry {
                statTile(
                    icon: "arrow.up.right.and.arrow.down.left.rectangle.fill",
                    label: "Largest Country",
                    value: "\(largest.name) (\(Int(largest.area / 1000))K km²)",
                    color: DesignSystem.Color.warning
                )
            }
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
    var countryListSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title: "Countries", icon: "list.bullet")
                Spacer()
                Picker(selection: $sortBy) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Label(option.rawValue, systemImage: option.icon)
                            .tag(option)
                    }
                } label: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }
                .pickerStyle(.menu)
                .tint(DesignSystem.Color.iconPrimary)
            }
            ForEach(Array(countries.enumerated()), id: \.element.code) { index, country in
                Button { navigateToCountry(country) } label: {
                    CardView {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                            Text(country.name)
                                .font(DesignSystem.Font.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(DesignSystem.Color.textTertiary)
                        }
                        .padding(DesignSystem.Spacing.sm)
                    }
                }
                .buttonStyle(PressButtonStyle())
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.03 + 0.15),
                    value: appeared
                )
            }
        }
    }
}
