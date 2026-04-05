import Geografy_Core_Navigation
#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct DistanceCountryPickerSheet: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator

    let title: String
    let countries: [Country]
    let onSelect: (Country) -> Void

    @State private var searchText = ""

    // MARK: - Body
    var body: some View {
        extractedContent
            .searchable(text: $searchText, prompt: "Search countries…")
            .navigationTitle(title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbarContent }
    }
}

// MARK: - Subviews
private extension DistanceCountryPickerSheet {
    var extractedContent: some View {
        List(filteredCountries) { country in
            Button {
                onSelect(country)
                coordinator.dismiss()
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(country.name)
                            .font(DesignSystem.Font.body)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(country.capital)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Toolbar
private extension DistanceCountryPickerSheet {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { coordinator.dismiss() }
        }
    }
}

// MARK: - Helpers
private extension DistanceCountryPickerSheet {
    var filteredCountries: [Country] {
        let all = countries
        guard !searchText.isEmpty else { return all }
        let query = searchText.lowercased()
        return all.filter {
            $0.name.lowercased().contains(query) ||
            $0.capital.lowercased().contains(query)
        }
    }
}
#endif
