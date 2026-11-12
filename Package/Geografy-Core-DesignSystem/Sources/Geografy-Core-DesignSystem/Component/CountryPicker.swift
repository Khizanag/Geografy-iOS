import Geografy_Core_Common
import SwiftUI

/// A searchable, A–Z indexed sheet for choosing one country.
public struct CountryPicker: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var searchText = ""

    private let title: LocalizedStringKey
    private let countries: [Country]
    private let selectedCode: String?
    private let onSelect: (Country) -> Void

    // MARK: - Init
    public init(
        _ title: LocalizedStringKey = "Choose a Country",
        countries: [Country],
        selectedCode: String? = nil,
        onSelect: @escaping (Country) -> Void
    ) {
        self.title = title
        self.countries = countries
        self.selectedCode = selectedCode
        self.onSelect = onSelect
    }

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            countryList
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Name, capital, or code"
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .close) { dismiss() }
                    }
                }
                .screenBackground()
        }
        .presentationDetents([.large])
    }
}

// MARK: - Subviews
private extension CountryPicker {
    var countryList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(sections, id: \.letter) { section in
                    Section(section.letter) {
                        ForEach(section.countries) { country in
                            row(for: country)
                        }
                    }
                    .sectionIndexLabel(section.letter)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .overlay {
                if sections.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .onAppear {
                if let selectedCode {
                    proxy.scrollTo(selectedCode, anchor: .center)
                }
            }
        }
    }

    func row(for country: Country) -> some View {
        Button {
            hapticsService.impact(.light)
            onSelect(country)
            dismiss()
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(country.capital) · \(country.continent.displayName)")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if country.code == selectedCode {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.body.weight(.semibold))
                        .foregroundStyle(DesignSystem.Color.accent)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .id(country.code)
        .accessibilityAddTraits(country.code == selectedCode ? .isSelected : [])
    }
}

// MARK: - Data
private extension CountryPicker {
    struct LetterSection {
        let letter: String
        let countries: [Country]
    }

    var sections: [LetterSection] {
        let matches = filteredCountries.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        let grouped = Dictionary(grouping: matches) { indexLetter(for: $0.name) }
        return grouped.keys.sorted().map { LetterSection(letter: $0, countries: grouped[$0] ?? []) }
    }

    var filteredCountries: [Country] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return countries }
        return countries.filter {
            $0.name.localizedStandardContains(query)
                || $0.capital.localizedStandardContains(query)
                || $0.code.localizedCaseInsensitiveCompare(query) == .orderedSame
        }
    }

    func indexLetter(for name: String) -> String {
        let folded = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        return folded.first.map { String($0).uppercased() } ?? "#"
    }
}
