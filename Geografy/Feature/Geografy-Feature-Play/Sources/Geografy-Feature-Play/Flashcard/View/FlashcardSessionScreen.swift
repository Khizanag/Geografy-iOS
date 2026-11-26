#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// A flashcard session: the cards as a stack to flip and rate, by swipe or by the bar under it, then the result.
/// A card rated Wrong comes back once at the end of the session, so it's seen again while it's fresh.
/// The answer is two-way, Wrong or Got It, and how sure it was comes from timing: a card known before it's turned is
/// Knew It, one turned after a long think is Struggled.
public struct FlashcardSessionScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(AchievementService.self) private var achievementService
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(SoundService.self) private var soundService
    @Environment(CountryDataService.self) private var countryDataService

    public let deck: FlashcardDeck
    public let cards: [FlashcardItem]

    @State private var queue: [FlashcardItem] = []
    @State private var flippedCardID: String?
    /// The card on its way off: the bar under it already asks about the next one.
    @State private var releasedCardID: String?
    @State private var pendingThrow: FlashcardThrow?
    @State private var firstAnswers: [String: Bool] = [:]
    @State private var requeuedIDs: Set<String> = []
    @State private var checkedAnswer: CheckedAnswer?
    @State private var showResults = false
    @State private var showQuitAlert = false
    @State private var cardShownAt: Date = .now
    @State private var thinkingTimes: [TimeInterval] = []

    // MARK: - Init
    public init(deck: FlashcardDeck, cards: [FlashcardItem]) {
        self.deck = deck
        self.cards = cards
    }

    // MARK: - Body
    public var body: some View {
        content
            .screenBackground()
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            // Give Up while studying and Done on the results replace the close and back buttons, as in a quiz.
            .hideNavigationCloseButton()
            .navigationBarBackButtonHidden()
            .alert("Give Up?", isPresented: $showQuitAlert) {
                Button("Give Up", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Cards you've already rated stay saved.")
            }
            .gameGuide(id: FlashcardGuide.id) { FlashcardGuideSheet() }
            .onAppear { if queue.isEmpty, !showResults { queue = cards } }
            .onDisappear { flashcardService.persistPendingChanges() }
            .answerHaptic(checkedAnswer)
            .haptic(.impact(weight: .light), trigger: flippedCardID)
    }
}

// MARK: - Content
private extension FlashcardSessionScreen {
    @ViewBuilder
    var content: some View {
        if showResults {
            FlashcardResultsView(
                deck: deck,
                cardCount: cards.count,
                correctCount: correctCount,
                averageThinkingTime: averageThinkingTime,
                onStudyAgain: restart,
                onDone: { dismiss() }
            )
            .transition(.opacity)
        } else {
            studyContent
        }
    }

    var studyContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            SessionProgressView(progress: progress, current: min(answeredCount + 1, cards.count), total: cards.count)
                .padding(.horizontal, DesignSystem.Spacing.md)
            FlashcardStack(
                cards: queue,
                flippedCardID: flippedCardID,
                pendingThrow: $pendingThrow,
                onFlip: flipTopCard,
                onRelease: release,
                onThrown: finishThrow,
                onShowDetails: showCountryDetail
            )
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.sm)
            FlashcardRatingBar(
                isFlipped: isTopFlipped && queue.first?.id != releasedCardID,
                onShowAnswer: flipTopCard,
                onAnswer: answerWithButton
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.sm)
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if !showResults {
            ToolbarItem(placement: .topBarLeading) {
                LeaveGameButton { showQuitAlert = true }
            }
        }
    }
}

// MARK: - Actions
private extension FlashcardSessionScreen {
    func flipTopCard() {
        guard let top = queue.first else { return }
        if flippedCardID != top.id {
            thinkingTimes.append(Date.now.timeIntervalSince(cardShownAt))
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            flippedCardID = flippedCardID == top.id ? nil : top.id
        }
    }

    func answerWithButton(knewIt: Bool) {
        pendingThrow = knewIt ? .right : .left
    }

    /// The card has been let go: the right-or-wrong sound and haptic play now, as it leaves.
    func release(_ direction: FlashcardThrow) {
        releasedCardID = queue.first?.id
        let knewIt = direction == .right
        checkedAnswer = AnswerFeedback(soundService: soundService).play(
            isCorrect: knewIt,
            announcement: knewIt
                ? String(localized: "Got it.", bundle: .module)
                : String(localized: "Again soon.", bundle: .module)
        )
    }

    /// The card has flown off: record its rating, and bring the next one forward.
    func finishThrow(_ direction: FlashcardThrow) {
        guard let card = queue.first else { return }
        let result = result(for: direction)
        flashcardService.recordReview(cardID: card.id, result: result)
        if firstAnswers[card.id] == nil {
            firstAnswers[card.id] = result != .again
        }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            queue.removeFirst()
            if result == .again, !requeuedIDs.contains(card.id) {
                requeuedIDs.insert(card.id)
                queue.append(card)
            }
        }
        flippedCardID = nil
        releasedCardID = nil
        cardShownAt = .now
        if queue.isEmpty { finishSession() }
    }

    func result(for direction: FlashcardThrow) -> FlashcardReviewResult {
        FlashcardRecall.result(
            knewIt: direction == .right,
            isFlipped: isTopFlipped,
            thinkingTime: isTopFlipped ? thinkingTimes.last : nil
        )
    }

    func finishSession() {
        xpService.award(XPRules.flashcardSession(cardsReviewed: cards.count), source: .flashcardSession)
        achievementService.checkFlashcardAchievements(proficientCount: flashcardService.proficientCount)
        flashcardService.persistPendingChanges()
        submitAccuracy()
        withAnimation(.easeInOut(duration: 0.3)) { showResults = true }
    }

    func showCountryDetail() {
        guard let code = queue.first?.countryCode, let country = countryDataService.country(for: code) else { return }
        coordinator.sheet(CountryRoute.countryDetail(country))
    }

    func restart() {
        queue = cards
        flippedCardID = nil
        firstAnswers = [:]
        requeuedIDs = []
        thinkingTimes = []
        cardShownAt = .now
        withAnimation(.easeInOut(duration: 0.3)) { showResults = false }
    }

    func submitAccuracy() {
        guard !cards.isEmpty else { return }
        let accuracy = Int(Double(correctCount) / Double(cards.count) * 100)
        Task { await gameCenterService.submitScore(accuracy, to: GameCenterService.LeaderboardID.quizHighScore) }
    }
}

// MARK: - Helpers
private extension FlashcardSessionScreen {
    var isTopFlipped: Bool {
        guard let top = queue.first else { return false }
        return flippedCardID == top.id
    }

    var answeredCount: Int { firstAnswers.count }

    var correctCount: Int { firstAnswers.values.filter { $0 }.count }

    var progress: CGFloat {
        guard !cards.isEmpty else { return 0 }
        return CGFloat(answeredCount) / CGFloat(cards.count)
    }

    var averageThinkingTime: TimeInterval {
        guard !thinkingTimes.isEmpty else { return 0 }
        return thinkingTimes.reduce(0, +) / Double(thinkingTimes.count)
    }
}

// MARK: - Recall
/// How well a card was known, read from what was done rather than asked: the direction it went, and how long the
/// answer took to come.
enum FlashcardRecall {
    /// A think this long before turning the card means the answer was a struggle.
    static let struggleThreshold: TimeInterval = 10

    static func result(knewIt: Bool, isFlipped: Bool, thinkingTime: TimeInterval?) -> FlashcardReviewResult {
        guard knewIt else { return .again }
        guard isFlipped else { return .easy }
        guard let thinkingTime, thinkingTime >= struggleThreshold else { return .good }
        return .hard
    }
}
#endif
