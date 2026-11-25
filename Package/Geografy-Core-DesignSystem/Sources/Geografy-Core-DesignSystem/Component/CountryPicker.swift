import Geografy_Core_Common
import SwiftUI

/// What the country picker lists: a country, or a place on the map that isn't one, such as a territory.
public protocol CountryPickerPlace: Identifiable where ID == String {
    var code: String { get }
    var name: String { get }
    var capital: String { get }
    var continent: Country.Continent { get }
}

extension Country: CountryPickerPlace {}

/// A searchable, A–Z indexed country list: pick one, pick several, or act on each country in turn.
///
/// Present it inside `CoordinatedNavigationStack(showCloseButton: true)` for the shared title bar and close button.
public struct CountryPicker<Place: CountryPickerPlace, Accessory: View>: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var continentFilter: Country.Continent?

    private let title: LocalizedStringKey
    private let countries: [Place]
    private let behavior: Behavior
    private let accessory: (Place) -> Accessory

    // MARK: - Body
    public var body: some View {
        countryList(sections)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Name, capital, or code"
            )
            .safeAreaInset(edge: .top, spacing: 0) {
                if case .multiple(let selection) = behavior {
                    multipleSelectionBar(selection)
                }
            }
            .screenBackground()
            .presentationDetents([.large])
            .haptic(.selection, trigger: multipleSelection)
    }
}

// MARK: - Initializers
public extension CountryPicker where Accessory == EmptyView {
    /// Picks one country and closes.
    init(
        _ title: LocalizedStringKey = "Choose a Country",
        countries: [Place],
        selectedCode: String? = nil,
        onSelect: @escaping (Place) -> Void
    ) {
        self.init(title, countries, .single(selectedCode: selectedCode, onSelect: onSelect)) { _ in EmptyView() }
    }

    /// Toggles countries in a set and stays open.
    init(
        _ title: LocalizedStringKey = "Choose Countries",
        countries: [Place],
        selection: Binding<Set<String>>
    ) {
        self.init(title, countries, .multiple(selection)) { _ in EmptyView() }
    }
}

public extension CountryPicker {
    /// Runs an action for each tapped country and stays open. `accessory` draws each row's mark, such as a
    /// `SelectionMark` that turns from a plus into a check; `checkedCodes` tells VoiceOver which are chosen.
    init(
        _ title: LocalizedStringKey,
        countries: [Place],
        checkedCodes: Set<String>,
        onSelect: @escaping (Place) -> Void,
        @ViewBuilder accessory: @escaping (Place) -> Accessory
    ) {
        self.init(title, countries, .action(checkedCodes: checkedCodes, onSelect: onSelect), accessory: accessory)
    }
}

private extension CountryPicker {
    enum Behavior {
        case single(selectedCode: String?, onSelect: (Place) -> Void)
        case multiple(Binding<Set<String>>)
        case action(checkedCodes: Set<String>, onSelect: (Place) -> Void)
    }

    init(
        _ title: LocalizedStringKey,
        _ countries: [Place],
        _ behavior: Behavior,
        accessory: @escaping (Place) -> Accessory
    ) {
        self.title = title
        self.countries = countries
        self.behavior = behavior
        self.accessory = accessory
    }
}

// MARK: - Subviews
private extension CountryPicker {
    /// Takes the sections from `body`, which works them out once per render for both the list and its empty state.
    func countryList(_ sections: [LetterSection]) -> some View {
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
                    NoSearchResultsView(query: searchText)
                }
            }
            .onAppear {
                if case .single(let selectedCode?, _) = behavior {
                    proxy.scrollTo(selectedCode, anchor: .center)
                }
            }
        }
    }

    func row(for country: Place) -> some View {
        Button { select(country) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                    Text(country.name)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(subtitle(for: country))
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                trailing(for: country)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .id(country.code)
        .accessibilityAddTraits(isChecked(country) ? .isSelected : [])
    }

    /// The capital and continent; a territory with no capital shows its continent alone.
    func subtitle(for country: Place) -> String {
        let continent = country.continent.displayName
        return country.capital.isEmpty ? continent : "\(country.capital) · \(continent)"
    }

    @ViewBuilder
    func trailing(for country: Place) -> some View {
        switch behavior {
        case .single:
            if isChecked(country) {
                checkmark
            }
        case .multiple:
            SelectionMark(isSelected: isChecked(country))
        case .action:
            accessory(country)
        }
    }

    var checkmark: some View {
        Image(systemName: "checkmark")
            .font(DesignSystem.Font.body.weight(.semibold))
            .foregroundStyle(DesignSystem.Color.accent)
            .accessibilityHidden(true)
    }
}

// MARK: - Multiple Selection
private extension CountryPicker {
    func multipleSelectionBar(_ selection: Binding<Set<String>>) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            continentChips
            HStack {
                Text("\(selection.wrappedValue.count) selected")
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer()
                Button("Select All") {
                    selection.wrappedValue.formUnion(visibleCountries.map(\.code))
                }
                Text("·")
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Button("None") {
                    selection.wrappedValue.subtract(visibleCountries.map(\.code))
                }
            }
            .font(DesignSystem.Font.caption)
            .tint(DesignSystem.Color.accent)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    var continentChips: some View {
        ChipScrollRow(inset: DesignSystem.Spacing.md) {
            SelectableChip("All", isSelected: continentFilter == nil) { continentFilter = nil }
            ForEach(continents, id: \.self) { continent in
                SelectableChip(continent.displayName, isSelected: continentFilter == continent) {
                    continentFilter = continent
                }
            }
        }
    }

    var continents: [Country.Continent] {
        Country.Continent.allCases.filter { continent in countries.contains { $0.continent == continent } }
    }
}

// MARK: - Actions
private extension CountryPicker {
    /// The codes picked so far when several can be; a pick or an unpick plays the selection haptic.
    var multipleSelection: Set<String> {
        guard case .multiple(let selection) = behavior else { return [] }
        return selection.wrappedValue
    }

    func select(_ country: Place) {
        switch behavior {
        case .single(_, let onSelect):
            onSelect(country)
            dismiss()
        case .multiple(let selection):
            if selection.wrappedValue.contains(country.code) {
                selection.wrappedValue.remove(country.code)
            } else {
                selection.wrappedValue.insert(country.code)
            }
        case .action(_, let onSelect):
            onSelect(country)
        }
    }

    func isChecked(_ country: Place) -> Bool {
        switch behavior {
        case .single(let selectedCode, _): country.code == selectedCode
        case .multiple(let selection): selection.wrappedValue.contains(country.code)
        case .action(let checkedCodes, _): checkedCodes.contains(country.code)
        }
    }
}

// MARK: - Data
private extension CountryPicker {
    struct LetterSection {
        let letter: String
        let countries: [Place]
    }

    var sections: [LetterSection] {
        let sorted = visibleCountries.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        let grouped = Dictionary(grouping: sorted) { indexLetter(for: $0.name) }
        return grouped.keys.sorted().map { LetterSection(letter: $0, countries: grouped[$0] ?? []) }
    }

    var visibleCountries: [Place] {
        let inContinent = continentFilter.map { continent in countries.filter { $0.continent == continent } }
            ?? countries
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return inContinent }
        return inContinent.filter {
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
