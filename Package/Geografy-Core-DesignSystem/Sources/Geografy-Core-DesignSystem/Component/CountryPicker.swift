import Geografy_Core_Common
import SwiftUI

/// A searchable, A–Z indexed country list: pick one, pick several, or act on each country in turn.
///
/// Present it inside `CoordinatedNavigationStack(showCloseButton: true)` for the shared title bar and close button.
public struct CountryPicker<Accessory: View>: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var searchText = ""
    @State private var continentFilter: Country.Continent?

    private let title: LocalizedStringKey
    private let countries: [Country]
    private let behavior: Behavior
    private let accessory: (Country) -> Accessory

    // MARK: - Body
    public var body: some View {
        countryList
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
    }
}

// MARK: - Initializers
public extension CountryPicker where Accessory == EmptyView {
    /// Picks one country and closes.
    init(
        _ title: LocalizedStringKey = "Choose a Country",
        countries: [Country],
        selectedCode: String? = nil,
        onSelect: @escaping (Country) -> Void
    ) {
        self.init(title, countries, .single(selectedCode: selectedCode, onSelect: onSelect)) { _ in EmptyView() }
    }

    /// Toggles countries in a set and stays open.
    init(
        _ title: LocalizedStringKey = "Choose Countries",
        countries: [Country],
        selection: Binding<Set<String>>
    ) {
        self.init(title, countries, .multiple(selection)) { _ in EmptyView() }
    }
}

public extension CountryPicker {
    /// Runs an action for each tapped country and stays open. Checked countries show a checkmark;
    /// the rest show `accessory`.
    init(
        _ title: LocalizedStringKey,
        countries: [Country],
        checkedCodes: Set<String>,
        onSelect: @escaping (Country) -> Void,
        @ViewBuilder accessory: @escaping (Country) -> Accessory
    ) {
        self.init(title, countries, .action(checkedCodes: checkedCodes, onSelect: onSelect), accessory: accessory)
    }
}

private extension CountryPicker {
    enum Behavior {
        case single(selectedCode: String?, onSelect: (Country) -> Void)
        case multiple(Binding<Set<String>>)
        case action(checkedCodes: Set<String>, onSelect: (Country) -> Void)
    }

    init(
        _ title: LocalizedStringKey,
        _ countries: [Country],
        _ behavior: Behavior,
        accessory: @escaping (Country) -> Accessory
    ) {
        self.title = title
        self.countries = countries
        self.behavior = behavior
        self.accessory = accessory
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
                if case .single(let selectedCode?, _) = behavior {
                    proxy.scrollTo(selectedCode, anchor: .center)
                }
            }
        }
    }

    func row(for country: Country) -> some View {
        Button { select(country) } label: {
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
                trailing(for: country)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .id(country.code)
        .accessibilityAddTraits(isChecked(country) ? .isSelected : [])
    }

    @ViewBuilder
    func trailing(for country: Country) -> some View {
        switch behavior {
        case .single:
            if isChecked(country) {
                checkmark
            }
        case .multiple:
            Image(systemName: isChecked(country) ? "checkmark.circle.fill" : "circle")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(isChecked(country) ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
                .accessibilityHidden(true)
        case .action:
            if isChecked(country) {
                checkmark
            } else {
                accessory(country)
            }
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                continentChip(nil, label: "All")
                ForEach(continents, id: \.self) { continent in
                    continentChip(continent, label: continent.displayName)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func continentChip(_ continent: Country.Continent?, label: String) -> some View {
        let isSelected = continentFilter == continent
        return Button {
            continentFilter = continent
        } label: {
            Text(label)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    var continents: [Country.Continent] {
        Country.Continent.allCases.filter { continent in countries.contains { $0.continent == continent } }
    }
}

// MARK: - Actions
private extension CountryPicker {
    func select(_ country: Country) {
        hapticsService.impact(.light)
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

    func isChecked(_ country: Country) -> Bool {
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
        let countries: [Country]
    }

    var sections: [LetterSection] {
        let sorted = visibleCountries.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        let grouped = Dictionary(grouping: sorted) { indexLetter(for: $0.name) }
        return grouped.keys.sorted().map { LetterSection(letter: $0, countries: grouped[$0] ?? []) }
    }

    var visibleCountries: [Country] {
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
