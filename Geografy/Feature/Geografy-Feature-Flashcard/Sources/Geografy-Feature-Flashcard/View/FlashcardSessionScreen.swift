#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct FlashcardSessionScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let deck: FlashcardDeck
    public let cards: [FlashcardItem]

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showResults = false
    @State private var correctCount = 0
    @State private var cardExit: FlashcardCardExit?
    @State private var showQuitAlert = false

    @State private var showGuide = false
    @State private var cardShownAt: Date = .now
    @State private var thinkingTimes: [TimeInterval] = []

    // MARK: - Init
    public init(deck: FlashcardDeck, cards: [FlashcardItem]) {
        self.deck = deck
        self.cards = cards
    }

    // MARK: - Body
    public var body: some View {
        sessionContent
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
            .sheet(isPresented: $showGuide) { FlashcardGuideSheet() }
            .alert("Quit Session?", isPresented: $showQuitAlert) {
                quitAlertActions
            } message: {
                Text("Your progress will be saved.")
            }
            .onDisappear { flashcardService.persistPendingChanges() }
    }
}

// MARK: - Body Subviews
private extension FlashcardSessionScreen {
    @ViewBuilder
    var sessionContent: some View {
        if showResults {
            resultsContent
                .transition(.opacity)
        } else {
            activeSessionContent
        }
    }

    var activeSessionContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            progressSection
            cardSection
            ratingSection
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .screenBackground()
    }

    var resultsContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                FlashcardStatsView(
                    cardsReviewed: cards.count,
                    correctCount: correctCount,
                    totalCards: cards.count,
                    averageThinkingTime: averageThinkingTime
                )
                doneButton
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .screenBackground()
        .onAppear {
            flashcardService.persistPendingChanges()
            submitFlashcardAccuracy()
            announceResults()
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { showGuide = true } label: {
                Label("Guide", systemImage: "questionmark.circle")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { dismiss() }
    }
}

// MARK: - Progress
private extension FlashcardSessionScreen {
    var progressSection: some View {
        SessionProgressView(progress: progressFraction, current: currentIndex + 1, total: cards.count)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .accessibilityLabel("Card \(currentIndex + 1) of \(cards.count)")
            .accessibilityValue("\(Int(progressFraction * 100)) percent complete")
    }
}

// MARK: - Card
private extension FlashcardSessionScreen {
    var cardSection: some View {
        FlashcardSwipeCard(
            card: currentCard,
            isFlipped: isFlipped,
            exit: cardExit,
            onTap: flipCard,
            onRate: rate
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Rating
private extension FlashcardSessionScreen {
    @ViewBuilder
    var ratingSection: some View {
        if isFlipped {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ratingButtons
                countryInfoButton
            }
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            .padding(.bottom, DesignSystem.Spacing.md)
        } else {
            Spacer(minLength: 0)
        }
    }

    var countryInfoButton: some View {
        Button { showCountryDetail() } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "info.circle")
                    .font(DesignSystem.Font.caption)
                Text("Country Details")
                    .font(DesignSystem.Font.caption)
            }
            .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .buttonStyle(.plain)
    }

    var ratingButtons: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(FlashcardReviewResult.allCases) { result in
                ratingButton(for: result)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func ratingButton(for result: FlashcardReviewResult) -> some View {
        Button { recordReview(result) } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: result.icon)
                    .font(DesignSystem.Font.subheadline)
                Text(result.displayName)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(result.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                result.color.opacity(0.12),
                in: RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
                .strokeBorder(result.color.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    var doneButton: some View {
        GlassButton("Done", systemImage: "checkmark", fullWidth: true) { dismiss() }
    }
}

// MARK: - Actions
private extension FlashcardSessionScreen {
    func showCountryDetail() {
        let code = currentCard.countryCode
        guard let country = countryDataService.country(for: code) else { return }
        coordinator.sheet(.countryDetail(country))
    }

    func flipCard() {
        if !isFlipped {
            let thinkingTime = Date.now.timeIntervalSince(cardShownAt)
            thinkingTimes.append(thinkingTime)
        }
        isFlipped.toggle()
        hapticsService.impact(.light)
    }

    func recordReview(_ result: FlashcardReviewResult) {
        flashcardService.recordReview(
            cardID: currentCard.id,
            result: result
        )

        if result != .again {
            correctCount += 1
        }

        let exitRight = result != .again
        advanceToNext(exitRight: exitRight)
    }

    func advanceToNext(exitRight: Bool = false) {
        exitCard(towards: exitRight ? 400 : -400, duration: 0.2, delay: 0.35)
    }

    func rate(_ feedback: SwipeFeedback) {
        showSwipeFeedback(feedback)
        flyOffAndAdvance(direction: feedback == .wrong ? .left : .right, result: feedback.reviewResult)
    }

    func flyOffAndAdvance(direction: SwipeDirection, result: FlashcardReviewResult) {
        flashcardService.recordReview(cardID: currentCard.id, result: result)
        if result != .again { correctCount += 1 }
        exitCard(towards: direction == .right ? 500 : -500, duration: 0.25, delay: 0.4)
    }

    func exitCard(towards offscreenX: CGFloat, duration: Double, delay: Double) {
        cardExit = FlashcardCardExit(offscreenX: offscreenX, duration: duration)

        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.15 : delay)) {
            showNextCard()
        }
    }

    func showNextCard() {
        guard currentIndex + 1 < cards.count else {
            showResults = true
            return
        }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            currentIndex += 1
            isFlipped = false
            cardShownAt = .now
            cardExit = nil
        }
    }

    func announceResults() {
        let message = "Session complete. \(correctCount) of \(cards.count) cards correct."
        AccessibilityNotification.Announcement(message).post()
    }

    enum SwipeDirection { case left, right }

    func showSwipeFeedback(_ type: SwipeFeedback) {
        hapticsService.notification(type == .wrong ? .warning : .success)
    }

    func submitFlashcardAccuracy() {
        guard !cards.isEmpty else { return }
        let accuracyPercent = Int(
            (Double(correctCount) / Double(cards.count)) * 100
        )
        Task {
            await gameCenterService.submitScore(
                accuracyPercent,
                to: GameCenterService.LeaderboardID.quizHighScore
            )
        }
    }
}

// MARK: - Helpers
private extension FlashcardSessionScreen {
    var currentCard: FlashcardItem {
        cards[min(currentIndex, cards.count - 1)]
    }

    var progressFraction: CGFloat {
        guard !cards.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(cards.count)
    }

    var averageThinkingTime: TimeInterval {
        guard !thinkingTimes.isEmpty else { return 0 }
        return thinkingTimes.reduce(0, +) / Double(thinkingTimes.count)
    }
}

// MARK: - Swipe Feedback
public enum SwipeFeedback {
    case correct
    case wrong
    case knewIt

    var reviewResult: FlashcardReviewResult {
        switch self {
        case .correct: .good
        case .wrong: .again
        case .knewIt: .easy
        }
    }
}
#endif
