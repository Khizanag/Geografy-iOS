import SwiftUI
import GeografyDesign
import GeografyCore

struct CompareScreen: View {
    let countryDataService: CountryDataService

    @State private var countryA: Country?
    @State private var countryB: Country?
    @State private var showPickerA = false
    @State private var showPickerB = false

    var body: some View {
        VStack(spacing: 48) {
            slotsRow

            if let countryA, let countryB {
                comparisonGrid(countryA, countryB)
            } else {
                emptyPrompt
            }
        }
        .padding(60)
        .navigationTitle("Compare Countries")
        .sheet(isPresented: $showPickerA) {
            TVCountryPickerSheet(countries: countryDataService.countries) { country in
                countryA = country
            }
        }
        .sheet(isPresented: $showPickerB) {
            TVCountryPickerSheet(countries: countryDataService.countries) { country in
                countryB = country
            }
        }
    }
}

// MARK: - Slots
private extension CompareScreen {
    var slotsRow: some View {
        HStack(spacing: 40) {
            countrySlot(country: countryA, label: "Country A") {
                showPickerA = true
            }

            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 36))
                .foregroundStyle(DesignSystem.Color.textTertiary)

            countrySlot(country: countryB, label: "Country B") {
                showPickerB = true
            }
        }
    }

    func countrySlot(country: Country?, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 16) {
                if let country {
                    FlagView(countryCode: country.code, height: 80)

                    Text(country.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(DesignSystem.Color.accent)

                    Text(label)
                        .font(.system(size: 22))
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.card)
    }

    var emptyPrompt: some View {
        Text("Select two countries to compare")
            .font(.system(size: 24))
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(maxHeight: .infinity)
    }
}

// MARK: - Comparison Grid
private extension CompareScreen {
    func comparisonGrid(_ a: Country, _ b: Country) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                comparisonRow(
                    label: "Capital",
                    icon: "building.columns",
                    valueA: a.capital,
                    valueB: b.capital
                )
                comparisonRow(
                    label: "Population",
                    icon: "person.3",
                    valueA: a.population.formatted(),
                    valueB: b.population.formatted(),
                    highlightHigher: Double(a.population) > Double(b.population)
                )
                comparisonRow(
                    label: "Area",
                    icon: "map",
                    valueA: "\(a.area.formatted()) km²",
                    valueB: "\(b.area.formatted()) km²",
                    highlightHigher: a.area > b.area
                )
                comparisonRow(
                    label: "Currency",
                    icon: "dollarsign.circle",
                    valueA: a.currency.name,
                    valueB: b.currency.name
                )
                comparisonRow(
                    label: "Continent",
                    icon: "globe",
                    valueA: a.continent.displayName,
                    valueB: b.continent.displayName
                )

                if let gdpA = a.gdpPerCapita, let gdpB = b.gdpPerCapita {
                    comparisonRow(
                        label: "GDP per Capita",
                        icon: "chart.bar",
                        valueA: "$\(Int(gdpA).formatted())",
                        valueB: "$\(Int(gdpB).formatted())",
                        highlightHigher: gdpA > gdpB
                    )
                }
            }
        }
    }

    func comparisonRow(
        label: String,
        icon: String,
        valueA: String,
        valueB: String,
        highlightHigher: Bool? = nil
    ) -> some View {
        HStack(spacing: 0) {
            Text(valueA)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    highlightHigher == true
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(DesignSystem.Color.textTertiary)

                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(width: 140)

            Text(valueB)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    highlightHigher == false
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Country Picker Sheet
struct TVCountryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let countries: [Country]
    let onSelect: (Country) -> Void

    @State private var searchText = ""

    private var filteredCountries: [Country] {
        guard !searchText.isEmpty else {
            return countries.sorted { $0.name < $1.name }
        }
        let query = searchText.lowercased()
        return countries
            .filter { $0.name.lowercased().contains(query) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    onSelect(country)
                    dismiss()
                } label: {
                    HStack(spacing: 16) {
                        FlagView(countryCode: country.code, height: 36)

                        Text(country.name)
                            .font(.system(size: 22))

                        Spacer()

                        Text(country.continent.displayName)
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Select Country")
        }
    }
}
