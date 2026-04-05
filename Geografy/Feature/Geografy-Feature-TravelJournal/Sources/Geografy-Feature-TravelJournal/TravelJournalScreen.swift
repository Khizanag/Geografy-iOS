import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TravelJournalScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var journalService = TravelJournalService()
    @State private var activeSheet: ActiveSheet?
    @State private var searchText = ""
    @State private var appeared = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        contentSwitcher
            .navigationTitle("Travel Journal")
            .closeButtonPlacementLeading()
            .searchable(
                text: $searchText,
                prompt: "Search journal entries..."
            )
            .toolbar { addEntryButton }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
            .sheet(item: $activeSheet) { sheet in
                sheetContent(for: sheet)
            }
    }
}

// MARK: - ActiveSheet
extension TravelJournalScreen {
    public enum ActiveSheet: Identifiable {
        case newEntry
        case editEntry(TravelJournalEntry)
        case detail(TravelJournalEntry)

        public var id: String {
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
        ToolbarItem(placement: .primaryAction) {
            Button {
                hapticsService.impact(.light)
                activeSheet = .newEntry
            } label: {
                Label("Add", systemImage: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Subviews
private extension TravelJournalScreen {
    var contentSwitcher: some View {
        ZStack {
            if journalService.entries.isEmpty, !isSearching {
                emptyState
            } else {
                mainContent
            }
        }
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                statsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
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
        .overlay {
            if filteredEntries.isEmpty, isSearching {
                ContentUnavailableView.search(text: searchText)
            }
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

    var entriesSection: some View {
        timelineList
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
                .accessibilityHidden(true)

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

    @ViewBuilder
    func sheetContent(
        for sheet: ActiveSheet
    ) -> some View {
        NavigationStack {
            sheetView(for: sheet)
                .environment(journalService)
        }
    }

    @ViewBuilder
    func sheetView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .newEntry:
            #if !os(tvOS)
            TravelJournalEditorSheet(
                activeSheet: $activeSheet,
                countryDataService: countryDataService
            )
            #else
            EmptyView()
            #endif
        case .editEntry(let entry):
            #if !os(tvOS)
            TravelJournalEditorSheet(
                entry: entry,
                activeSheet: $activeSheet,
                countryDataService: countryDataService
            )
            #else
            EmptyView()
            #endif
        case .detail(let entry):
            TravelJournalDetailScreen(
                entry: entry,
                activeSheet: $activeSheet,
                countryDataService: countryDataService
            )
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
