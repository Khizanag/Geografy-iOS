import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TravelBucketListScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(TravelService.self) private var travelService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var selectedSort: BucketListSort = .continent
    @State private var priorities: [String: BucketListPriority] = [:]
    @State private var notes: [String: String] = [:]
    @State private var selectedCountry: Country?

    private let prioritiesKey = "bucketList_priorities"
    private let notesKey = "bucketList_notes"

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        let countries = bucketListCountries
        contentSwitcher(countries)
            .screenBackground()
            .closeButtonPlacementLeading()
            .toolbar { toolbarItems(countries) }
            .onAppear { loadPersistedData() }
            .sheet(item: $selectedCountry) { country in
                CoordinatedNavigationStack(showCloseButton: true) {
                    bucketListDetailSheet(for: country)
                }
            }
    }
}

// MARK: - Subviews
private extension TravelBucketListScreen {
    @ViewBuilder
    func contentSwitcher(_ countries: [Country]) -> some View {
        if countryDataService.countries.isEmpty {
            LoadingView()
        } else if countries.isEmpty {
            emptyState
        } else {
            mainContent(countries)
        }
    }

    func mainContent(_ countries: [Country]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                summaryHeader(countries)
                countrySections(countries)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    func summaryHeader(_ countries: [Country]) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "list.star")
                    .font(DesignSystem.Font.iconLarge)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("\(countries.count) countries on your bucket list")
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(continentSummary(countries))
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .accessibilityElement(children: .combine)
    }

    func countrySections(_ countries: [Country]) -> some View {
        ForEach(groupedSections(countries), id: \.title) { section in
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: section.title)
                ForEach(section.countries) { country in
                    bucketListRow(for: country)
                }
            }
        }
    }

    func bucketListRow(for country: Country) -> some View {
        let priority = priorities[country.code] ?? .someday
        return HStack(spacing: DesignSystem.Spacing.sm) {
            Button {
                selectedCountry = country
            } label: {
                CountryRowView(country: country, isFavorite: false)
            }
            .buttonStyle(PressButtonStyle())
            .countryContextMenu(country)
            priorityBadge(priority)
        }
    }

    func priorityBadge(_ priority: BucketListPriority) -> some View {
        Image(systemName: priority.icon)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(priority.color)
            .frame(width: 32, height: 32)
            .accessibilityLabel(priority.label)
    }

    var emptyState: some View {
        EmptyStateView(
            icon: "heart.slash",
            title: "No Bucket List Yet",
            message: "Mark countries as 'Want to Visit' in the Travel Tracker to add them here",
            actionTitle: "Open Travel Tracker"
        ) {
            coordinator.push(TravelRoute.travelTracker)
        }
    }

    @ViewBuilder
    func bucketListDetailSheet(for country: Country) -> some View {
        BucketListCountryDetailView(
            country: country,
            priority: Binding(
                get: { priorities[country.code] ?? .someday },
                set: { setPriority($0, for: country.code) }
            ),
            note: Binding(
                get: { notes[country.code] ?? "" },
                set: { setNote($0, for: country.code) }
            )
        )
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Toolbar
private extension TravelBucketListScreen {
    @ToolbarContentBuilder
    func toolbarItems(_ countries: [Country]) -> some ToolbarContent {
        ToolbarItem(placement: sortPlacement) {
            Menu {
                Picker(selection: $selectedSort) {
                    ForEach(BucketListSort.allCases) { sort in
                        Label(sort.label, systemImage: sort.icon)
                            .tag(sort)
                    }
                } label: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }
                .pickerStyle(.inline)
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
        }

        #if !os(tvOS)
        ToolbarItem(placement: .primaryAction) {
            ShareLink(item: shareableText(countries)) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
        }
        #endif
    }

    var sortPlacement: ToolbarItemPlacement {
        #if os(tvOS)
        .primaryAction
        #else
        .secondaryAction
        #endif
    }
}

// MARK: - Data
private extension TravelBucketListScreen {
    var bucketListCountries: [Country] {
        let codes = travelService.wantToVisitCodes
        return countryDataService.countries.filter { codes.contains($0.code) }
    }

    func continentSummary(_ countries: [Country]) -> String {
        let continentNames = Set(countries.map(\.continent.displayName))
        return continentNames.sorted().joined(separator: ", ")
    }

    func groupedSections(_ countries: [Country]) -> [(title: String, countries: [Country])] {
        let sorted = countries.sorted(by: \.name)
        switch selectedSort {
        case .continent:
            return groupedByContinent(sorted)
        case .priority:
            return groupedByPriority(sorted)
        case .alphabetical:
            return [("A – Z", sorted)]
        }
    }

    func groupedByContinent(_ sortedCountries: [Country]) -> [(title: String, countries: [Country])] {
        let byContinent = Dictionary(grouping: sortedCountries, by: \.continent)
        return byContinent.keys
            .sorted(by: \.displayName)
            .map { continent in (title: continent.displayName, countries: byContinent[continent] ?? []) }
    }

    func groupedByPriority(_ sortedCountries: [Country]) -> [(title: String, countries: [Country])] {
        let byPriority = Dictionary(grouping: sortedCountries) { priorities[$0.code] ?? .someday }
        return BucketListPriority.allCases.compactMap { priority in
            guard let countries = byPriority[priority], !countries.isEmpty else { return nil }
            return (title: priority.label, countries: countries)
        }
    }

    func setPriority(_ priority: BucketListPriority, for code: String) {
        priorities[code] = priority
        persistPriorities()
    }

    func setNote(_ note: String, for code: String) {
        if note.isEmpty {
            notes.removeValue(forKey: code)
        } else {
            notes[code] = note
        }
        persistNotes()
    }

    func loadPersistedData() {
        if let priorityData = UserDefaults.standard.data(forKey: UserScope.key(prioritiesKey)),
           let decoded = try? JSONDecoder().decode([String: String].self, from: priorityData) {
            priorities = decoded.compactMapValues { BucketListPriority(rawValue: $0) }
        }
        if let notesData = UserDefaults.standard.data(forKey: UserScope.key(notesKey)),
           let decoded = try? JSONDecoder().decode([String: String].self, from: notesData) {
            notes = decoded
        }
    }

    func persistPriorities() {
        let raw = priorities.mapValues(\.rawValue)
        guard let data = try? JSONEncoder().encode(raw) else { return }
        UserDefaults.standard.set(data, forKey: UserScope.key(prioritiesKey))
    }

    func persistNotes() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: UserScope.key(notesKey))
    }

    func shareableText(_ countries: [Country]) -> String {
        let lines = countries
            .sorted(by: \.name)
            .map { country in
                let priority = priorities[country.code] ?? .someday
                return "\(priority.emoji) \(country.flagEmoji) \(country.name)"
            }
        let header = "My Travel Bucket List (\(countries.count) countries):\n\n"
        return header + lines.joined(separator: "\n")
    }
}

// MARK: - Supporting Types
private enum BucketListSort: String, CaseIterable, Identifiable {
    case continent
    case priority
    case alphabetical

    var id: String { rawValue }

    var label: String {
        switch self {
        case .continent: "Continent"
        case .priority: "Priority"
        case .alphabetical: "A–Z"
        }
    }

    var icon: String {
        switch self {
        case .continent: "globe"
        case .priority: "star"
        case .alphabetical: "textformat.abc"
        }
    }
}

public enum BucketListPriority: String, CaseIterable, Codable {
    case dream
    case planningSoon
    case someday

    public var label: String {
        switch self {
        case .dream: "Dream Destination"
        case .planningSoon: "Planning Soon"
        case .someday: "Someday"
        }
    }

    public var icon: String {
        switch self {
        case .dream: "star.fill"
        case .planningSoon: "calendar"
        case .someday: "globe.europe.africa.fill"
        }
    }

    public var color: Color {
        switch self {
        case .dream: DesignSystem.Color.warning
        case .planningSoon: DesignSystem.Color.blue
        case .someday: DesignSystem.Color.textSecondary
        }
    }

    /// For the shared plain-text list, where an emoji reads better than a symbol name.
    public var emoji: String {
        switch self {
        case .dream: "⭐"
        case .planningSoon: "📅"
        case .someday: "🌍"
        }
    }
}

// MARK: - Bucket List Country Detail View
public struct BucketListCountryDetailView: View {
    // MARK: - Properties
    public let country: Country
    @Binding var priority: BucketListPriority
    @Binding var note: String

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(country.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension BucketListCountryDetailView {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                countryHeader
                prioritySection
                noteSection
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var countryHeader: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            FlagView(countryCode: country.code, height: 48)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(country.continent.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }

    var prioritySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Priority")
            ForEach(BucketListPriority.allCases, id: \.rawValue) { option in
                priorityRow(option)
            }
        }
    }

    func priorityRow(_ option: BucketListPriority) -> some View {
        let isSelected = priority == option
        return Button { priority = option } label: {
            priorityCard(option, isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel(option.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func priorityCard(_ option: BucketListPriority, isSelected: Bool) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: option.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(option.color)
                    .frame(width: DesignSystem.Size.lg)
                    .accessibilityHidden(true)
                Text(option.label)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .strokeBorder(isSelected ? DesignSystem.Color.accent : .clear, lineWidth: 2)
        )
    }

    var noteSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Notes")
            CardView {
                TextField(
                    "Add a note...",
                    text: $note,
                    axis: .vertical
                )
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(4...8)
                .padding(DesignSystem.Spacing.sm)
            }
        }
    }
}
