import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SRSStudyScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(CountryDataService.self) private var countryDataService

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        contentView
            .screenBackground()
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if !dueCards.isEmpty {
                    startReviewButton
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.md)
                }
            }
            .onChange(of: dueCards.count) { _, newCount in
                announceDueCount(newCount)
            }
    }
}

// MARK: - Subviews
private extension SRSStudyScreen {
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                headerSection
                statsRow

                if dueCards.isEmpty {
                    allCaughtUpSection
                } else {
                    dueCountriesSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge("clock.arrow.circlepath", color: DesignSystem.Color.purple, size: .hero)

            Text("Spaced Repetition")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Review cards at the optimal time\nfor long-term memory retention")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statCard(
                value: "\(dueCards.count)",
                label: "Due Today",
                icon: "clock.badge.exclamationmark",
                color: dueCards.isEmpty ? DesignSystem.Color.success : DesignSystem.Color.purple
            )
            statCard(
                value: "\(flashcardService.reviewedTodayCount())",
                label: "Reviewed",
                icon: "checkmark.circle",
                color: DesignSystem.Color.blue
            )
            statCard(
                value: "\(flashcardService.currentStreak())",
                label: "Day Streak",
                icon: "flame",
                color: DesignSystem.Color.warning
            )
        }
    }

    func statCard(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
                Text(value)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.sm)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }

    var startReviewButton: some View {
        GlassButton(
            "Start Review · \(dueCards.count) cards",
            systemImage: "play.fill",
            fullWidth: true
        ) {
            coordinator.cover(
                .flashcardSession(
                    deck: .makeDueForReviewDeck(cardType: .countryToCapital),
                    cards: dueCards
                )
            )
        }
    }

    var dueCountriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Due Countries")

            ForEach(dueCards.prefix(5)) { card in
                if let country = countryDataService.country(for: card.countryCode) {
                    dueCardRow(card, country: country)
                }
            }

            if dueCards.count > 5 {
                Text("+ \(dueCards.count - 5) more")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .padding(.leading, DesignSystem.Spacing.xs)
            }
        }
    }

    func dueCardRow(_ card: FlashcardItem, country: Country) -> some View {
        let srData = flashcardService.spacedRepetitionData(for: card.id)
        return CardView {
            CountryListRow(country: country, subtitle: card.capital) {
                proficiencyBadge(for: srData.proficiencyLevel)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    func proficiencyBadge(
        for level: SpacedRepetitionData.ProficiencyLevel
    ) -> some View {
        Text(level.displayName)
            .font(DesignSystem.Font.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(level.badgeColor)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 3)
            .background(level.badgeColor.opacity(0.15), in: Capsule())
    }

    var allCaughtUpSection: some View {
        ContentUnavailableView(
            "All caught up!",
            systemImage: "checkmark.seal.fill",
            description: Text("No cards are due right now.\nCome back later or study new cards.")
        )
    }
}

// MARK: - Helpers
private extension SRSStudyScreen {
    var allCards: [FlashcardItem] {
        countryDataService.countries.map {
            FlashcardItem.make(from: $0, type: .countryToCapital)
        }
    }

    var dueCards: [FlashcardItem] {
        flashcardService.dueCards(from: allCards)
    }

    func announceDueCount(_ count: Int) {
        let message = count == 0 ? "All caught up. No cards are due." : "\(count) cards due for review."
        AccessibilityNotification.Announcement(message).post()
    }
}

// MARK: - Badge Color
private extension SpacedRepetitionData.ProficiencyLevel {
    var badgeColor: Color {
        switch self {
        case .new: DesignSystem.Color.textTertiary
        case .learning: DesignSystem.Color.warning
        case .familiar: DesignSystem.Color.blue
        case .proficient: DesignSystem.Color.success
        }
    }
}
