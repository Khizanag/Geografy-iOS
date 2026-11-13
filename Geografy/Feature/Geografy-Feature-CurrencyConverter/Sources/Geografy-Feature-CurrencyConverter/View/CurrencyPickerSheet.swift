import Geografy_Core_DesignSystem
import SwiftUI

/// A searchable list of currencies, major ones first. Present it inside `CoordinatedNavigationStack`.
struct CurrencyPickerSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    let title: String
    let currencies: [CurrencyEntry]
    let selectedCode: String?
    let side: PairSide
    let onSelect: (CurrencyEntry) -> Void

    @State private var searchText = ""

    // MARK: - Body
    var body: some View {
        currencyList
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Currency, code, or country"
            )
            .screenBackground()
            .presentationDetents([.large])
    }
}

// MARK: - Subviews
private extension CurrencyPickerSheet {
    var currencyList: some View {
        List {
            if isSearching {
                ForEach(searchResults) { row(for: $0) }
            } else {
                Section("Popular") {
                    ForEach(CurrencyCatalog.major(in: currencies, excluding: nil, limit: .max)) { row(for: $0) }
                }
                Section("All Currencies") {
                    ForEach(currencies) { row(for: $0) }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            if isSearching, searchResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    func row(for currency: CurrencyEntry) -> some View {
        let isSelected = currency.code == selectedCode
        return Button {
            select(currency)
        } label: {
            FlagListRow(
                flagCode: currency.flagCode,
                title: currency.name,
                subtitle: "\(currency.code) · \(currency.usageSummary)"
            ) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.body.weight(.semibold))
                        .foregroundStyle(side.color)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Actions
private extension CurrencyPickerSheet {
    func select(_ currency: CurrencyEntry) {
        hapticsService.selection()
        onSelect(currency)
        dismiss()
    }
}

// MARK: - Helpers
private extension CurrencyPickerSheet {
    var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    var isSearching: Bool {
        !query.isEmpty
    }

    var searchResults: [CurrencyEntry] {
        currencies.filter { currency in
            currency.code.localizedCaseInsensitiveContains(query)
                || currency.name.localizedStandardContains(query)
                || currency.countryNames.contains { $0.localizedStandardContains(query) }
        }
    }
}
