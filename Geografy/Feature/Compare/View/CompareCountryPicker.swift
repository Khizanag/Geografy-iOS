import GeografyCore
import GeografyDesign
import SwiftUI

struct CompareCountryPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(HapticsService.self) private var hapticsService

    @State private var searchText = ""

    let countries: [Country]
    let excludedCountry: Country?
    let onSelect: (Country) -> Void

    var body: some View {
        countryList
            .background(DesignSystem.Color.background)
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search countries")
    }
}

// MARK: - Subviews
private extension CompareCountryPicker {
    var countryList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(filteredCountries) { country in
                    countryButton(country)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    func countryButton(_ country: Country) -> some View {
        Button {
            hapticsService.impact(.light)
            onSelect(country)
            dismiss()
        } label: {
            CountryRowView(
                country: country,
                isFavorite: favoritesService.isFavorite(code: country.code),
                showStats: false,
                showContinent: true
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension CompareCountryPicker {
    var filteredCountries: [Country] {
        var result = countries
            .filter { $0.code != excludedCountry?.code }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.capital.lowercased().contains(query)
            }
        }

        return result.sorted { $0.name < $1.name }
    }
}
