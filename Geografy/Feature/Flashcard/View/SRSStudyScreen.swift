import GeografyDesign
import SwiftUI

struct SRSStudyScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var appeared = false

    var body: some View {
        contentView
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                appeared = true
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
                    startReviewButton
                    dueCountriesSection
                }
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.purple.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "clock.arrow.circlepath")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.purple)
            }
            Text("Spaced Repetition")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Review cards at the optimal time\nfor long-term memory retention")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
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
        .opacity(appeared ? 1 : 0)
    }

    func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(color)
                Text(value)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: value)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var startReviewButton: some View {
        Button {
            coordinator.cover(
                .flashcardSession(
                    deck: .makeDueForReviewDeck(cardType: .countryToCapital),
                    cards: dueCards
                )
            )
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "play.fill")
                Text("Start Review · \(dueCards.count) cards")
                    .fontWeight(.semibold)
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Color.purple)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(PressButtonStyle())
    }

    var dueCountriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Due Countries")
            ForEach(dueCards.prefix(5)) { card in
                dueCardRow(card)
            }
            if dueCards.count > 5 {
                Text("+ \(dueCards.count - 5) more")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .padding(.leading, DesignSystem.Spacing.xs)
            }
        }
    }

    func dueCardRow(_ card: FlashcardItem) -> some View {
        let srData = flashcardService.spacedRepetitionData(for: card.id)
        return CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: card.countryCode, height: DesignSystem.Size.sm, fixedWidth: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.countryName)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(card.capital)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
                masteryBadge(for: srData.masteryLevel)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    func masteryBadge(for level: SpacedRepetitionData.MasteryLevel) -> some View {
        Text(level.displayName)
            .font(DesignSystem.Font.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(level.badgeColor)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 3)
            .background(level.badgeColor.opacity(0.15))
            .clipShape(Capsule())
    }

    var allCaughtUpSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(DesignSystem.Font.displaySmall)
                .foregroundStyle(DesignSystem.Color.success)
            Text("All caught up!")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("No cards are due right now.\nCome back later or study new cards in Flashcards.")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

// MARK: - Helpers
private extension SRSStudyScreen {
    var allCards: [FlashcardItem] {
        countryDataService.countries.map { FlashcardItem.make(from: $0, type: .countryToCapital) }
    }

    var dueCards: [FlashcardItem] {
        flashcardService.dueCards(from: allCards)
    }
}

// MARK: - MasteryLevel Badge Color
private extension SpacedRepetitionData.MasteryLevel {
    var badgeColor: Color {
        switch self {
        case .new: DesignSystem.Color.textTertiary
        case .learning: DesignSystem.Color.warning
        case .familiar: DesignSystem.Color.blue
        case .mastered: DesignSystem.Color.success
        }
    }
}
