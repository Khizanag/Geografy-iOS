import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct ContinentStatsScreen: View {
    // MARK: - Init
    public init(
        continentName: String
    ) {
        self.continentName = continentName
    }
    #if !os(tvOS)
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    @State private var appeared = false

    public let continentName: String

    // MARK: - Body
    public var body: some View {
        loadedContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle(continentName)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                appeared = true
            }
    }
}

// MARK: - Subviews
private extension ContinentStatsScreen {
    @ViewBuilder
    var loadedContent: some View {
        if countryDataService.countries.isEmpty {
            ProgressView().tint(DesignSystem.Color.accent)
        } else {
            mainContent
        }
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                statsGridSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                countriesSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(continentEmoji)
                .font(DesignSystem.Font.display)
                .accessibilityHidden(true)
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(continentName)
                    .font(DesignSystem.Font.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("\(continentCountries.count) countries")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.md)
    }

    var statsGridSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Statistics")
                .accessibilityAddTraits(.isHeader)
            statsGrid
        }
    }

    var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            populationAndAreaTiles
            gdpAndLanguageTiles
            sizeComparisonTiles
        }
    }

    @ViewBuilder
    var populationAndAreaTiles: some View {
        statTile(
            title: "Total Population",
            value: totalPopulationFormatted,
            icon: "person.3.fill",
            color: DesignSystem.Color.blue
        )
        statTile(
            title: "Total Area",
            value: totalAreaFormatted,
            icon: "globe",
            color: DesignSystem.Color.ocean
        )
    }

    @ViewBuilder
    var gdpAndLanguageTiles: some View {
        statTile(
            title: "Avg GDP/Capita",
            value: avgGdpPerCapitaFormatted,
            icon: "dollarsign.circle.fill",
            color: DesignSystem.Color.warning
        )
        statTile(
            title: "Most Spoken Language",
            value: mostSpokenLanguage,
            icon: "bubble.left.fill",
            color: DesignSystem.Color.purple
        )
    }

    @ViewBuilder
    var sizeComparisonTiles: some View {
        statTile(
            title: "Largest Country",
            value: largestCountry?.name ?? "—",
            icon: "map.fill",
            color: DesignSystem.Color.accent
        )
        statTile(
            title: "Smallest Country",
            value: smallestCountry?.name ?? "—",
            icon: "smallcircle.filled.circle",
            color: DesignSystem.Color.orange
        )
    }

    func statTile(title: String, value: String, icon: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Image(systemName: icon)
                        .font(DesignSystem.Font.iconSmall)
                        .foregroundStyle(color)
                        .accessibilityHidden(true)
                    Spacer()
                }
                Spacer(minLength: DesignSystem.Spacing.xs)
                Text(value)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(title)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }
            .padding(DesignSystem.Spacing.sm)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title): \(value)")
        }
    }

    var countriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Countries by Population")
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(sortedByPopulation) { country in
                    Button {
                        #if !os(tvOS)
                        hapticsService.impact(.light)
                        #endif
                        coordinator.push(.countryDetail(country))
                    } label: {
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
                }
            }
        }
    }
}

// MARK: - Data
private extension ContinentStatsScreen {
    var continentCountries: [Country] {
        countryDataService.countries.filter { $0.continent.displayName == continentName }
    }

    var sortedByPopulation: [Country] {
        continentCountries.sorted(by: \.population, descending: true)
    }

    var totalPopulation: Int {
        continentCountries.reduce(0) { $0 + $1.population }
    }

    var totalArea: Double {
        continentCountries.reduce(0) { $0 + $1.area }
    }

    var avgGdpPerCapita: Double? {
        let values = continentCountries.compactMap(\.gdpPerCapita)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    var largestCountry: Country? {
        continentCountries.max(by: { $0.area < $1.area })
    }

    var smallestCountry: Country? {
        continentCountries.filter { $0.area > 0 }.min(by: { $0.area < $1.area })
    }

    var mostSpokenLanguage: String {
        var languageCounts: [String: Double] = [:]
        for country in continentCountries {
            for language in country.languages {
                languageCounts[language.name, default: 0] += language.percentage
            }
        }
        return languageCounts.max(by: { $0.value < $1.value })?.key ?? "—"
    }

    var totalPopulationFormatted: String {
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let value = Double(totalPopulation)
        if value >= billion {
            return String(format: "%.1fB", value / billion)
        } else if value >= million {
            return String(format: "%.0fM", value / million)
        }
        return "\(totalPopulation)"
    }

    var totalAreaFormatted: String {
        let million = 1_000_000.0
        if totalArea >= million {
            return String(format: "%.1fM km²", totalArea / million)
        }
        return String(format: "%.0f km²", totalArea)
    }

    var avgGdpPerCapitaFormatted: String {
        guard let value = avgGdpPerCapita else { return "—" }
        return String(format: "$%.0f", value)
    }

    var continentEmoji: String {
        switch continentName {
        case "Africa": "🌍"
        case "Asia": "🌏"
        case "Europe": "🗺️"
        case "North America": "🌎"
        case "South America": "🌎"
        case "Oceania": "🏝️"
        case "Antarctica": "🧊"
        default: "🌐"
        }
    }
}
