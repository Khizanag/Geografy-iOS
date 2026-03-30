import SwiftUI

struct ContinentStatsScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TabCoordinator.self) private var coordinator

    @State private var countryDataService = CountryDataService()
    @State private var appeared = false

    let continentName: String

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if countryDataService.countries.isEmpty {
                ProgressView().tint(DesignSystem.Color.accent)
            } else {
                mainContent
            }
        }
        .navigationTitle(continentName)
        .navigationBarTitleDisplayMode(.large)
        .task { countryDataService.loadCountries() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }
}

// MARK: - Subviews
private extension ContinentStatsScreen {
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
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DesignSystem.Spacing.sm
            ) {
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
        }
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
                        hapticsService.impact(.light)
                        coordinator.push(.countryDetail(country))
                    } label: {
                        CountryRowView(country: country, isFavorite: false)
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
        continentCountries.sorted { $0.population > $1.population }
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
