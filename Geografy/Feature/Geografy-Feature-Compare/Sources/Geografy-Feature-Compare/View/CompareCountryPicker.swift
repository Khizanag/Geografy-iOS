import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct CompareCountryPicker: View {
    // MARK: - Init
    public init(
        countries: [Country],
        excludedCountry: Country? = nil,
        onSelect: @escaping (Country) -> Void
    ) {
        self.countries = countries
        self.excludedCountry = excludedCountry
        self.onSelect = onSelect
    }
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @State private var searchText = ""

    public let countries: [Country]
    public let excludedCountry: Country?
    public let onSelect: (Country) -> Void

    // MARK: - Body
    public var body: some View {
        countryList
            .background(DesignSystem.Color.background)
            .navigationTitle("Select Country")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            onSelect(country)
            coordinator.dismiss()
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(country.name)
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(country.continent.displayName)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                }
                .padding(DesignSystem.Spacing.sm)
            }
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

        return result.sorted(by: \.name)
    }
}
