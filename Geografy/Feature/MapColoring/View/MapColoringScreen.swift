import SwiftUI
import GeografyDesign
import GeografyCore

struct MapColoringScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var selectedScheme: ColoringScheme = .continent
    @State private var visibleGroups: Set<String> = []
    @State private var selectedCountry: Country?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                schemePicker
                    .padding(.horizontal, DesignSystem.Spacing.md)
                legendSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                countryGroupsList
                    .padding(.horizontal, DesignSystem.Spacing.md)
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.top, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Map Coloring Book")
        .navigationBarTitleDisplayMode(.inline)        .task {
            visibleGroups = Set(groupedCountries.keys)
        }
        .sheet(item: $selectedCountry) { country in
            countryDetailPopup(country)
        }
    }
}

// MARK: - Subviews
private extension MapColoringScreen {
    var schemePicker: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Color Scheme", icon: "paintpalette.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(ColoringScheme.allCases, id: \.self) { scheme in
                        schemeChip(scheme)
                    }
                }
            }
        }
    }

    func schemeChip(_ scheme: ColoringScheme) -> some View {
        Button {
            hapticsService.impact(.light)
            selectedScheme = scheme
            visibleGroups = Set(groupedCountries.keys)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: scheme.icon)
                    .font(DesignSystem.Font.caption)
                Text(scheme.displayName)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(selectedScheme == scheme ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                selectedScheme == scheme ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var legendSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Legend", icon: "info.circle.fill")
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: DesignSystem.Spacing.xs
            ) {
                ForEach(Array(colorMap.keys.sorted()), id: \.self) { key in
                    legendItem(label: key, color: colorMap[key] ?? DesignSystem.Color.accent)
                }
            }
        }
    }

    func legendItem(label: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
            Spacer()
        }
    }

    var countryGroupsList: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(Array(groupedCountries.keys.sorted()), id: \.self) { group in
                groupSection(group)
            }
        }
    }

    func groupSection(_ group: String) -> some View {
        let countries = groupedCountries[group] ?? []
        let groupColor = colorMap[group] ?? DesignSystem.Color.accent
        let isVisible = visibleGroups.contains(group)

        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            groupHeader(group, color: groupColor, isVisible: isVisible, count: countries.count)
            if isVisible {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(countries) { country in
                        countryRow(country, color: groupColor)
                    }
                }
            }
        }
    }

    func groupHeader(_ group: String, color: Color, isVisible: Bool, count: Int) -> some View {
        Button {
            hapticsService.impact(.light)
            if visibleGroups.contains(group) {
                visibleGroups.remove(group)
            } else {
                visibleGroups.insert(group)
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                Text(group)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Text("\(count)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Image(systemName: isVisible ? "chevron.up" : "chevron.down")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
        .buttonStyle(PressButtonStyle())
    }

    func countryRow(_ country: Country, color: Color) -> some View {
        Button {
            hapticsService.impact(.light)
            selectedCountry = country
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Circle()
                    .fill(color.opacity(0.6))
                    .frame(width: 8, height: 8)
                FlagView(countryCode: country.code, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                Text(country.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.micro)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(PressButtonStyle())
    }

    func countryDetailPopup(_ country: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            FlagView(countryCode: country.code, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                .geoShadow(.card)
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(groupLabel(for: country))
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.xl)
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
        .presentationDetents([.medium])
    }
}

// MARK: - Helpers
private extension MapColoringScreen {
    var groupedCountries: [String: [Country]] {
        var groups: [String: [Country]] = [:]
        for country in countryDataService.countries {
            let key = groupKey(for: country)
            groups[key, default: []].append(country)
        }
        return groups.mapValues { $0.sorted { $0.name < $1.name } }
    }

    func groupKey(for country: Country) -> String {
        switch selectedScheme {
        case .continent:
            country.continent.displayName
        case .incomeLevel:
            incomeLevel(for: country)
        case .populationSize:
            populationCategory(for: country)
        }
    }

    func groupLabel(for country: Country) -> String {
        "\(selectedScheme.displayName): \(groupKey(for: country))"
    }

    func incomeLevel(for country: Country) -> String {
        guard let gdpPerCapita = country.gdpPerCapita else { return "Unknown" }
        return switch gdpPerCapita {
        case 20_000...: "High Income"
        case 5_000..<20_000: "Upper Middle Income"
        case 1_000..<5_000: "Lower Middle Income"
        default: "Low Income"
        }
    }

    func populationCategory(for country: Country) -> String {
        switch country.population {
        case 100_000_000...: "100M+"
        case 10_000_000..<100_000_000: "10M–100M"
        case 1_000_000..<10_000_000: "1M–10M"
        default: "Under 1M"
        }
    }

    var colorMap: [String: Color] {
        switch selectedScheme {
        case .continent:
            return [
                "Africa": DesignSystem.Color.warning,
                "Asia": DesignSystem.Color.error,
                "Europe": DesignSystem.Color.blue,
                "North America": DesignSystem.Color.success,
                "South America": DesignSystem.Color.success,
                "Oceania": DesignSystem.Color.purple,
                "Antarctica": DesignSystem.Color.textTertiary,
            ]
        case .incomeLevel:
            return [
                "High Income": DesignSystem.Color.success,
                "Upper Middle Income": DesignSystem.Color.blue,
                "Lower Middle Income": DesignSystem.Color.warning,
                "Low Income": DesignSystem.Color.error,
                "Unknown": DesignSystem.Color.textTertiary,
            ]
        case .populationSize:
            return [
                "100M+": DesignSystem.Color.error,
                "10M–100M": DesignSystem.Color.warning,
                "1M–10M": DesignSystem.Color.blue,
                "Under 1M": DesignSystem.Color.success,
            ]
        }
    }
}

// MARK: - Supporting Types
extension MapColoringScreen {
    enum ColoringScheme: String, CaseIterable {
        case continent
        case incomeLevel
        case populationSize

        var displayName: String {
            switch self {
            case .continent: "By Continent"
            case .incomeLevel: "By Income Level"
            case .populationSize: "By Population"
            }
        }

        var icon: String {
            switch self {
            case .continent: "globe"
            case .incomeLevel: "chart.bar.fill"
            case .populationSize: "person.3.fill"
            }
        }
    }
}
