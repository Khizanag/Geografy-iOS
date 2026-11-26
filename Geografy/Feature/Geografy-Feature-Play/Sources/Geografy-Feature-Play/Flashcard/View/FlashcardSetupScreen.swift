import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// Flashcards' setup, as every game opens (Geografy article 102): what the cards ask and where from, how many to
/// study, today's progress, and the countries waiting, then Study.
public struct FlashcardSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(CountryDataService.self) private var countryDataService

    @AppStorage("flashcards_cardType") private var cardType: FlashcardType = .countryToCapital
    @AppStorage("flashcards_region") private var region: QuizRegion = .world
    @AppStorage("flashcards_sessionSize") private var sessionSize: FlashcardSessionSize = .ten

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(id: FlashcardGuide.id) { FlashcardGuideSheet() }
            .bottomActionBar { studyButton }
            .onChange(of: dueCards.count) { _, count in announceDueCount(count) }
    }
}

// MARK: - Sections
private extension FlashcardSetupScreen {
    enum Section: Hashable {
        case cardType
        case region
        case session
    }

    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                header
                todayStats
                cardTypeSection
                regionSection
                sessionSection
                dueSection
                KnowledgeMapSection()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
        .sectionScrolling()
    }

    var header: some View {
        GameIntroHeader(
            title: "Flashcards",
            subtitle: "Each card comes back just before you'd forget it, so what you learn stays.",
            systemImage: "rectangle.on.rectangle.angled",
            color: FlashcardStyle.color,
            facts: [
                GameIntroHeader.Fact(cardType.displayName, systemImage: cardType.icon, showing: Section.cardType),
                GameIntroHeader.Fact(region.displayName, systemImage: "globe", showing: Section.region),
                GameIntroHeader.Fact(
                    "\(sessionCards.count) cards",
                    systemImage: "rectangle.stack",
                    showing: Section.session
                ),
            ]
        )
    }

    var todayStats: some View {
        StatTileRow {
            StatTile(
                value: "\(dueCards.count)",
                label: "Due",
                icon: "clock.badge.exclamationmark",
                color: FlashcardStyle.color
            )
            StatTile(
                value: "\(flashcardService.reviewedTodayCount())",
                label: "Reviewed Today",
                icon: "checkmark.circle",
                color: DesignSystem.Color.blue
            )
            StatTile(
                value: "\(flashcardService.currentStreak())",
                label: "Day Streak",
                icon: "flame",
                color: DesignSystem.Color.orange
            )
        }
    }

    var cardTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Card Type")
                .id(Section.cardType)
            TypeSelectionGrid(
                items: FlashcardType.allCases,
                selectedIDs: [cardType.id],
                color: FlashcardStyle.color,
                layout: .grid,
                onSelect: { cardType = $0 }
            )
        }
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
                .id(Section.region)
            RegionPicker(selectedRegion: $region, color: FlashcardStyle.color)
        }
    }

    var sessionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Session")
                .id(Section.session)
            CardView {
                OptionPickerRow(
                    "Cards",
                    selection: $sessionSize,
                    options: FlashcardSessionSize.allCases,
                    note: sessionNote,
                    label: \.title
                )
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    @ViewBuilder
    var dueSection: some View {
        if dueCountries.isEmpty {
            EmptyStateView(
                icon: "checkmark.seal.fill",
                title: "All Caught Up",
                message: "No cards are due here. Try another card type or region, or come back later."
            )
        } else {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "Up Next")
                CountryRowListCard(Array(dueCountries.prefix(Self.previewCount)), open: openCountry)
                if dueCountries.count > Self.previewCount {
                    Text("and \(dueCountries.count - Self.previewCount) more")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .padding(.leading, DesignSystem.Spacing.xs)
                }
            }
        }
    }

    var studyButton: some View {
        GlassButton(studyTitle, systemImage: "play.fill", fullWidth: true) {
            coordinator.cover(
                PlayLocalRoute.flashcardSession(
                    deck: .review(cardType: cardType, region: region),
                    cards: sessionCards
                )
            )
        }
        .disabled(sessionCards.isEmpty)
    }
}

// MARK: - Helpers
private extension FlashcardSetupScreen {
    static let previewCount = 5

    var dueCards: [FlashcardItem] {
        flashcardService.dueCards(of: cardType, in: region.filter(countryDataService.countries))
    }

    var sessionCards: [FlashcardItem] {
        guard let limit = sessionSize.limit else { return dueCards }
        return Array(dueCards.prefix(limit))
    }

    var dueCountries: [Country] {
        sessionCards.compactMap { countryDataService.country(for: $0.countryCode) }
    }

    var studyTitle: LocalizedStringKey {
        sessionCards.isEmpty ? "Nothing Due" : "Study \(sessionCards.count) Cards"
    }

    var sessionNote: String {
        String(localized: "\(dueCards.count) due in \(region.displayName)", bundle: .module)
    }

    func openCountry(_ country: Country) {
        coordinator.sheet(CountryRoute.countryDetail(country))
    }

    func announceDueCount(_ count: Int) {
        let message = count == 0 ? "All caught up. No cards are due." : "\(count) cards due."
        AccessibilityNotification.Announcement(message).post()
    }
}

// MARK: - Session Size
/// How many due cards one session studies.
enum FlashcardSessionSize: String, CaseIterable, Identifiable {
    case ten
    case twenty
    case all

    var id: String { rawValue }

    var limit: Int? {
        switch self {
        case .ten: 10
        case .twenty: 20
        case .all: nil
        }
    }

    var title: String {
        switch self {
        case .ten: "10"
        case .twenty: "20"
        case .all: String(localized: "All Due", bundle: .module)
        }
    }
}
