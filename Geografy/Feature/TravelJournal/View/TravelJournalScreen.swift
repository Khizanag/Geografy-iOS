import SwiftUI

struct TravelJournalScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var journalService = TravelJournalService()
    @State private var countryDataService = CountryDataService()
    @State private var activeSheet: ActiveSheet?
    @State private var searchText = ""
    @State private var appeared = false

    var body: some View {
        ZStack {
            if journalService.entries.isEmpty, !isSearching {
                emptyState
            } else {
                mainContent
            }
        }
        .navigationTitle("Travel Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { addEntryButton }
        .sheet(item: $activeSheet) { sheet in
            sheetContent(for: sheet)
        }
        .task { countryDataService.loadCountries() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

// MARK: - ActiveSheet
extension TravelJournalScreen {
    enum ActiveSheet: Identifiable {
        case newEntry
        case editEntry(TravelJournalEntry)
        case detail(TravelJournalEntry)

        var id: String {
            switch self {
            case .newEntry: "newEntry"
            case .editEntry(let entry): "edit-\(entry.id)"
            case .detail(let entry): "detail-\(entry.id)"
            }
        }
    }
}

// MARK: - Toolbar
private extension TravelJournalScreen {
    @ToolbarContentBuilder
    var addEntryButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                hapticsService.impact(.light)
                activeSheet = .newEntry
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Subviews
private extension TravelJournalScreen {
    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                statsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                searchBar
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                entriesSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
            }
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var statsSection: some View {
        TravelJournalStatsView(
            totalEntries: journalService.totalEntries,
            totalPhotos: journalService.totalPhotos,
            uniqueCountries: journalService.uniqueCountries,
            averageRating: journalService.averageRating,
            favoriteCountryCode: journalService.favoriteCountryCode
        )
    }

    var searchBar: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .font(DesignSystem.Font.subheadline)
            TextField(
                "Search journal entries...",
                text: $searchText
            )
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .tint(DesignSystem.Color.accent)
            .autocorrectionDisabled()
            if !searchText.isEmpty {
                clearSearchButton
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs + 2)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var clearSearchButton: some View {
        Button {
            withAnimation(
                .spring(response: 0.3, dampingFraction: 0.75)
            ) {
                searchText = ""
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var entriesSection: some View {
        Group {
            if filteredEntries.isEmpty, isSearching {
                noResultsState
            } else {
                timelineList
            }
        }
    }

    var timelineList: some View {
        LazyVStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(filteredEntries, id: \.id) { entry in
                TravelJournalEntryCard(
                    entry: entry,
                    countryName: countryName(
                        for: entry.countryCode
                    ),
                    onTap: {
                        activeSheet = .detail(entry)
                    }
                )
                .environment(journalService)
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "book.closed.fill")
                .font(DesignSystem.Font.displaySmall)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.top, DesignSystem.Spacing.xxl)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Start Your Travel Journal")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(
                        DesignSystem.Color.textPrimary
                    )
                Text(
                    "Capture memories from your travels "
                        + "with photos, notes, and ratings"
                )
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(
                    DesignSystem.Color.textSecondary
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            GeoButton(
                "Add First Entry",
                systemImage: "plus"
            ) {
                hapticsService.impact(.medium)
                activeSheet = .newEntry
            }
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .frame(maxWidth: .infinity)
    }

    var noResultsState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.top, DesignSystem.Spacing.xl)
            Text("No entries found")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Try a different search term")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(
                    DesignSystem.Color.textSecondary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxl)
    }

    @ViewBuilder
    func sheetContent(
        for sheet: ActiveSheet
    ) -> some View {
        switch sheet {
        case .newEntry:
            NavigationStack {
                TravelJournalEditorSheet(
                    activeSheet: $activeSheet,
                    countryDataService: countryDataService
                )
            }
            .environment(journalService)
        case .editEntry(let entry):
            NavigationStack {
                TravelJournalEditorSheet(
                    entry: entry,
                    activeSheet: $activeSheet,
                    countryDataService: countryDataService
                )
            }
            .environment(journalService)
        case .detail(let entry):
            NavigationStack {
                TravelJournalDetailScreen(
                    entry: entry,
                    activeSheet: $activeSheet,
                    countryDataService: countryDataService
                )
            }
            .environment(journalService)
        }
    }
}

// MARK: - Data
private extension TravelJournalScreen {
    var isSearching: Bool { !searchText.isEmpty }

    var filteredEntries: [TravelJournalEntry] {
        guard isSearching else {
            return journalService.entries
        }
        let query = searchText.lowercased()
        return journalService.entries.filter { entry in
            let name = countryName(
                for: entry.countryCode
            ).lowercased()
            let titleMatch = entry.title.lowercased()
                .contains(query)
            let notesMatch = entry.notes.lowercased()
                .contains(query)
            let countryMatch = name.contains(query)
            return titleMatch || notesMatch || countryMatch
        }
    }

    func countryName(for code: String) -> String {
        countryDataService.country(for: code)?.name ?? code
    }
}
