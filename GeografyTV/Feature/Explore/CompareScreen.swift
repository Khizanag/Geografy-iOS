import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct CompareScreen: View {
    let countryDataService: CountryDataService

    @State private var countryA: Country?
    @State private var countryB: Country?
    @State private var showPickerA = false
    @State private var showPickerB = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
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
            CountryPickerSheet(countries: countryDataService.countries) { country in
                countryA = country
            }
        }
        .sheet(isPresented: $showPickerB) {
            CountryPickerSheet(countries: countryDataService.countries) { country in
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
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            countrySlot(country: countryB, label: "Country B") {
                showPickerB = true
            }
        }
    }

    func countrySlot(country: Country?, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.md) {
                if let country {
                    FlagView(countryCode: country.code, height: 80)

                    Text(country.name)
                        .font(DesignSystem.Font.system(size: 24, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(DesignSystem.Font.system(size: 48))
                        .foregroundStyle(DesignSystem.Color.accent)

                    Text(label)
                        .font(DesignSystem.Font.system(size: 22))
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
            )
        }
        .buttonStyle(.card)
    }

    var emptyPrompt: some View {
        Text("Select two countries to compare")
            .font(DesignSystem.Font.system(size: 24))
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(maxHeight: .infinity)
    }
}

// MARK: - Comparison Grid
private extension CompareScreen {
    func comparisonGrid(_ firstCountry: Country, _ secondCountry: Country) -> some View {
        // swiftlint:disable:next closure_body_length
        ScrollView {
            // swiftlint:disable:next closure_body_length
            VStack(spacing: DesignSystem.Spacing.md) {
                comparisonRow(
                    label: "Capital",
                    icon: "building.columns",
                    valueA: firstCountry.capital,
                    valueB: secondCountry.capital
                )
                comparisonRow(
                    label: "Population",
                    icon: "person.3",
                    valueA: firstCountry.population.formatted(),
                    valueB: secondCountry.population.formatted(),
                    highlightHigher: Double(firstCountry.population) > Double(secondCountry.population)
                )
                comparisonRow(
                    label: "Area",
                    icon: "map",
                    valueA: "\(firstCountry.area.formatted()) km\u{00B2}",
                    valueB: "\(secondCountry.area.formatted()) km\u{00B2}",
                    highlightHigher: firstCountry.area > secondCountry.area
                )
                comparisonRow(
                    label: "Currency",
                    icon: "dollarsign.circle",
                    valueA: firstCountry.currency.name,
                    valueB: secondCountry.currency.name
                )
                comparisonRow(
                    label: "Continent",
                    icon: "globe",
                    valueA: firstCountry.continent.displayName,
                    valueB: secondCountry.continent.displayName
                )

                if let gdpA = firstCountry.gdpPerCapita, let gdpB = secondCountry.gdpPerCapita {
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
                .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    highlightHigher == true
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.system(size: 20))
                    .foregroundStyle(DesignSystem.Color.textTertiary)

                Text(label)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(width: 140)

            Text(valueB)
                .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    highlightHigher == false
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Country Picker Sheet
struct CountryPickerSheet: View {
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
                    HStack(spacing: DesignSystem.Spacing.md) {
                        FlagView(countryCode: country.code, height: 36)

                        Text(country.name)
                            .font(DesignSystem.Font.system(size: 22))

                        Spacer()

                        Text(country.continent.displayName)
                            .font(DesignSystem.Font.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Select Country")
        }
        .onExitCommand { dismiss() }
    }
}
