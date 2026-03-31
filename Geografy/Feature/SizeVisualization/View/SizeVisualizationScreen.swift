import SwiftUI
import GeografyDesign
import GeografyCore

struct SizeVisualizationScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var sortMode: SortMode = .area
    @State private var searchQuery = ""
    @State private var referenceCountry: Country?
    @State private var selectedCountry: Country?
    @State private var showCompare = false

    var body: some View {
        mainContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Size Visualization")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, prompt: "Search countries...")
            .sheet(isPresented: $showCompare) {
                if let selected = selectedCountry, let reference = referenceCountry {
                    SizeCompareView(
                        referenceCountry: reference,
                        comparisonCountry: selected
                    )
                }
            }
    }
}

// MARK: - Subviews
private extension SizeVisualizationScreen {
    var mainContent: some View {
        VStack(spacing: 0) {
            searchAndSortHeader
            countryList
        }
    }

    var searchAndSortHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            sortPicker
            if let reference = referenceCountry {
                referenceRow(reference)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    var sortPicker: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(SortMode.allCases) { mode in
                sortChip(for: mode)
            }
            Spacer()
        }
    }

    func sortChip(for mode: SortMode) -> some View {
        Button {
            hapticsService.impact(.light)
            sortMode = mode
        } label: {
            Text(mode.displayName)
                .font(DesignSystem.Font.caption)
                .fontWeight(sortMode == mode ? .bold : .regular)
                .foregroundStyle(sortMode == mode ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    sortMode == mode ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                    in: Capsule()
                )
        }
    }

    func referenceRow(_ country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 20)
            Text("Reference: \(country.name)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Button("Change") {
                referenceCountry = nil
            }
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.accent.opacity(0.1),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }

    var countryList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(Array(filteredCountries.enumerated()), id: \.element.id) { index, country in
                    countryRow(country: country, rank: index + 1)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
    }

    func countryRow(country: Country, rank: Int) -> some View {
        Button {
            hapticsService.impact(.medium)
            if referenceCountry == nil {
                referenceCountry = country
            } else {
                selectedCountry = country
                showCompare = true
            }
        } label: {
            CountryRowContent(
                country: country,
                rank: rank,
                sortMode: sortMode,
                referenceCountry: referenceCountry,
                maxValue: maxValue
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension SizeVisualizationScreen {
    enum SortMode: String, CaseIterable, Identifiable {
        case area
        case population
        case density

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .area: "Area"
            case .population: "Population"
            case .density: "Density"
            }
        }
    }

    var filteredCountries: [Country] {
        let base = countryDataService.countries
        let searched = searchQuery.isEmpty ? base : base.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
        }
        return searched.sorted { lhs, rhs in
            switch sortMode {
            case .area: lhs.area > rhs.area
            case .population: lhs.population > rhs.population
            case .density: lhs.populationDensity > rhs.populationDensity
            }
        }
    }

    var maxValue: Double {
        switch sortMode {
        case .area:
            filteredCountries.first?.area ?? 1
        case .population:
            Double(filteredCountries.first?.population ?? 1)
        case .density:
            filteredCountries.first?.populationDensity ?? 1
        }
    }
}

// MARK: - CountryRowContent
private struct CountryRowContent: View {
    let country: Country
    let rank: Int
    let sortMode: SizeVisualizationScreen.SortMode
    let referenceCountry: Country?
    let maxValue: Double

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                headerRow
                barRow
                if let reference = referenceCountry, reference.code != country.code {
                    comparisonRow(reference: reference)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text("\(rank)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(width: 24, alignment: .leading)
            FlagView(countryCode: country.code, height: 24)
            Text(country.name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Spacer()
            Text(formattedValue)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var barRow: some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 3)
                    .fill(DesignSystem.Color.accent)
                    .frame(width: max(6, geometryReader.size.width * barFraction), height: 6)
            }
        }
        .frame(height: 6)
    }

    func comparisonRow(reference: Country) -> some View {
        let multiplier = comparisonMultiplier(reference: reference)
        let larger = currentValue > referenceValue(reference: reference)
        let text = larger
            ? String(format: "%.1fx larger than %@", multiplier, reference.name)
            : String(format: "%.1fx smaller than %@", 1.0 / multiplier, reference.name)
        return Text(text)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }

    var currentValue: Double {
        switch sortMode {
        case .area: country.area
        case .population: Double(country.population)
        case .density: country.populationDensity
        }
    }

    var formattedValue: String {
        switch sortMode {
        case .area:
            let km = country.area
            if km >= 1_000_000 {
                return String(format: "%.2fM km²", km / 1_000_000)
            }
            return String(format: "%.0f km²", km)
        case .population:
            let pop = country.population
            if pop >= 1_000_000_000 {
                return String(format: "%.2fB", Double(pop) / 1_000_000_000)
            } else if pop >= 1_000_000 {
                return String(format: "%.1fM", Double(pop) / 1_000_000)
            }
            return String(format: "%.0fK", Double(pop) / 1_000)
        case .density:
            return String(format: "%.1f/km²", country.populationDensity)
        }
    }

    var barFraction: Double {
        guard maxValue > 0 else { return 0 }
        let logMax = log10(maxValue + 1)
        let logVal = log10(currentValue + 1)
        guard logMax > 0 else { return 0 }
        return min(1.0, logVal / logMax)
    }

    func referenceValue(reference: Country) -> Double {
        switch sortMode {
        case .area: reference.area
        case .population: Double(reference.population)
        case .density: reference.populationDensity
        }
    }

    func comparisonMultiplier(reference: Country) -> Double {
        let refVal = referenceValue(reference: reference)
        guard refVal > 0 else { return 0 }
        return max(currentValue, refVal) / min(currentValue, refVal)
    }
}

// MARK: - Preview
#Preview {
    SizeVisualizationScreen()
        .environment(HapticsService())
}
