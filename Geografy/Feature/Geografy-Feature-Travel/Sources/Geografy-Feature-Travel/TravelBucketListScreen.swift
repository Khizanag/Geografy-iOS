import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_CountryList
import SwiftUI

public struct TravelBucketListScreen: View {
    // MARK: - Properties
    @Environment(TravelService.self) private var travelService
    @Environment(HapticsService.self) private var hapticsService
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
        contentSwitcher
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Bucket List")
            .closeButtonPlacementLeading()
            .toolbar { toolbarItems }
            .onAppear { loadPersistedData() }
            .sheet(item: $selectedCountry) { country in
                bucketListDetailSheet(for: country)
            }
    }
}

// MARK: - Subviews
private extension TravelBucketListScreen {
    @ViewBuilder
    var contentSwitcher: some View {
        if countryDataService.countries.isEmpty {
            ProgressView().tint(DesignSystem.Color.accent)
        } else if bucketListCountries.isEmpty {
            emptyState
        } else {
            mainContent
        }
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                summaryHeader
                countrySections
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var summaryHeader: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "list.star")
                    .font(DesignSystem.Font.iconLarge)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("\(bucketListCountries.count) countries on your bucket list")
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(continentSummary)
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

    var countrySections: some View {
        ForEach(groupedSections, id: \.title) { section in
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
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
                hapticsService.impact(.light)
                selectedCountry = country
            } label: {
                CountryRowView(country: country, isFavorite: false)
            }
            .buttonStyle(PressButtonStyle())
            priorityBadge(priority)
        }
    }

    func priorityBadge(_ priority: BucketListPriority) -> some View {
        Text(priority.emoji)
            .font(DesignSystem.Font.title3)
            .frame(width: 32, height: 32)
            .accessibilityLabel(priority.label)
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label("No Bucket List Yet", systemImage: "heart.slash")
        } description: {
            Text("Mark countries as 'Want to Visit' in the Travel Tracker to add them here")
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
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
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
            ShareLink(item: shareableText) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
        }
        #endif
    }
}

// MARK: - Data
private extension TravelBucketListScreen {
    var bucketListCountries: [Country] {
        let codes = travelService.wantToVisitCodes
        return countryDataService.countries.filter { codes.contains($0.code) }
    }

    var continentSummary: String {
        let continentNames = Set(bucketListCountries.map(\.continent.displayName))
        return continentNames.sorted().joined(separator: ", ")
    }

    var groupedSections: [(title: String, countries: [Country])] {
        switch selectedSort {
        case .continent:
            return groupedByContinent
        case .priority:
            return groupedByPriority
        case .alphabetical:
            return [("A – Z", bucketListCountries.sorted { $0.name < $1.name })]
        }
    }

    var groupedByContinent: [(title: String, countries: [Country])] {
        let continents = Array(Set(bucketListCountries.map(\.continent))).sorted { $0.displayName < $1.displayName }
        return continents.map { continent in
            let countries = bucketListCountries
                .filter { $0.continent == continent }
                .sorted { $0.name < $1.name }
            return (title: continent.displayName, countries: countries)
        }
    }

    var groupedByPriority: [(title: String, countries: [Country])] {
        BucketListPriority.allCases.compactMap { priority in
            let countries = bucketListCountries
                .filter { (priorities[$0.code] ?? .someday) == priority }
                .sorted { $0.name < $1.name }
            guard !countries.isEmpty else { return nil }
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
        if let priorityData = UserDefaults.standard.data(forKey: prioritiesKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: priorityData) {
            priorities = decoded.compactMapValues { BucketListPriority(rawValue: $0) }
        }
        if let notesData = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: notesData) {
            notes = decoded
        }
    }

    func persistPriorities() {
        let raw = priorities.mapValues(\.rawValue)
        guard let data = try? JSONEncoder().encode(raw) else { return }
        UserDefaults.standard.set(data, forKey: prioritiesKey)
    }

    func persistNotes() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(data, forKey: notesKey)
    }

    var shareableText: String {
        let lines = bucketListCountries
            .sorted { $0.name < $1.name }
            .map { country in
                let priority = priorities[country.code] ?? .someday
                return "\(priority.emoji) \(country.flagEmoji) \(country.name)"
            }
        let header = "My Travel Bucket List (\(bucketListCountries.count) countries):\n\n"
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
    @Environment(\.dismiss) private var dismiss

    public let country: Country
    @Binding var priority: BucketListPriority
    @Binding var note: String

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
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
        return CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(option.emoji)
                    .font(DesignSystem.Font.iconDefault)
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
        .onTapGesture { priority = option }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
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
