import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// A searchable list of the countries on a map; picking one shows it on the map.
/// Present it inside `CoordinatedNavigationStack`.
struct MapCountryFinder: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(HapticsService.self) private var hapticsService

    let shapes: [CountryShape]
    let onSelect: (CountryShape) -> Void

    @State private var searchText = ""

    // MARK: - Body
    var body: some View {
        countryList
            .navigationTitle("Find a Country")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Country or capital"
            )
            .screenBackground()
            .presentationDetents([.medium, .large])
    }
}

// MARK: - Subviews
private extension MapCountryFinder {
    var countryList: some View {
        List(results) { place in
            Button { select(place.shape) } label: {
                FlagListRow(
                    flagCode: place.shape.id,
                    title: place.name,
                    subtitle: place.capital.isEmpty ? nil : place.capital
                ) {
                    EmptyView()
                }
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            if results.isEmpty, !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }
}

// MARK: - Places
private extension MapCountryFinder {
    struct Place: Identifiable {
        let shape: CountryShape
        let name: String
        let capital: String

        var id: String { shape.id }
    }

    var places: [Place] {
        shapes
            .map { shape in
                let country = countryDataService.country(for: shape.id)
                return Place(
                    shape: shape,
                    name: country?.name ?? shape.name,
                    capital: country?.capital ?? MapTerritory.info(for: shape.id)?.capital ?? ""
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var results: [Place] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return places }
        return places.filter { $0.name.localizedStandardContains(query) || $0.capital.localizedStandardContains(query) }
    }

    func select(_ shape: CountryShape) {
        hapticsService.selection()
        onSelect(shape)
        dismiss()
    }
}
