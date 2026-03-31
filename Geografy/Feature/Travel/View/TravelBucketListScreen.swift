import SwiftUI
import GeografyDesign
import GeografyCore

struct TravelBucketListScreen: View {
    @Environment(TravelService.self) private var travelService
    @Environment(HapticsService.self) private var hapticsService

    @State private var countryDataService = CountryDataService()
    @State private var selectedSort: BucketListSort = .continent
    @State private var priorities: [String: BucketListPriority] = [:]
    @State private var notes: [String: String] = [:]
    @State private var selectedCountry: Country?
    @State private var showShareSheet = false
    @State private var shareText = ""

    private let prioritiesKey = "bucketList_priorities"
    private let notesKey = "bucketList_notes"

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if countryDataService.countries.isEmpty {
                ProgressView().tint(DesignSystem.Color.accent)
            } else if bucketListCountries.isEmpty {
                emptyState
            } else {
                mainContent
            }
        }
        .navigationTitle("Bucket List")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarItems }
        .task { countryDataService.loadCountries() }
        .onAppear { loadPersistedData() }
        .sheet(item: $selectedCountry) { country in
            bucketListDetailSheet(for: country)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: shareText)
        }
    }
}

// MARK: - Subviews
private extension TravelBucketListScreen {
    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                summaryHeader
                sortPicker
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

    var sortPicker: some View {
        Picker("Sort by", selection: $selectedSort) {
            ForEach(BucketListSort.allCases) { sort in
                Text(sort.label).tag(sort)
            }
        }
        .pickerStyle(.segmented)
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
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "heart.slash")
                .font(DesignSystem.Font.displaySmall)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("No bucket list yet")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Mark countries as 'Want to Visit' in the Travel Tracker to add them here")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                hapticsService.impact(.light)
                prepareShareText()
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
            .buttonStyle(.plain)
        }
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

    func prepareShareText() {
        let lines = bucketListCountries.sorted { $0.name < $1.name }.map { country in
            let priority = priorities[country.code] ?? .someday
            return "\(priority.emoji) \(country.flagEmoji) \(country.name)"
        }
        let header = "My Travel Bucket List (\(bucketListCountries.count) countries):\n\n"
        shareText = header + lines.joined(separator: "\n")
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
}

enum BucketListPriority: String, CaseIterable, Codable {
    case dream
    case planningSoon
    case someday

    var label: String {
        switch self {
        case .dream: "Dream Destination"
        case .planningSoon: "Planning Soon"
        case .someday: "Someday"
        }
    }

    var emoji: String {
        switch self {
        case .dream: "⭐"
        case .planningSoon: "📅"
        case .someday: "💭"
        }
    }
}

// MARK: - Bucket List Country Detail View
struct BucketListCountryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let country: Country
    @Binding var priority: BucketListPriority
    @Binding var note: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                countryHeader
                prioritySection
                noteSection
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension BucketListCountryDetailView {
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

// MARK: - Share Sheet
private struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
