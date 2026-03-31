import SwiftUI
import GeografyDesign
import GeografyCore

struct FlashcardSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(HapticsService.self) private var hapticsService

    let deck: FlashcardDeck
    let cards: [FlashcardItem]

    @State private var countryDataService = CountryDataService()
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showResults = false
    @State private var correctCount = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showQuitAlert = false
    @State private var detailCountry: Country?
    @State private var showGuide = false
    @State private var cardShownAt: Date = .now
    @State private var thinkingTimes: [TimeInterval] = []
    var body: some View {
        NavigationStack {
            sessionContent
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .alert("Quit Session?", isPresented: $showQuitAlert) {
                    quitAlertActions
                } message: {
                    Text("Your progress will be saved.")
                }
                .sheet(isPresented: $showGuide) { FlashcardGuideSheet() }
                .sheet(item: $detailCountry) { country in
                    NavigationStack {
                        CountryDetailScreen(country: country)
                    }
                }
                .task { countryDataService.loadCountries() }
        }
    }
}

// MARK: - Body Subviews
private extension FlashcardSessionScreen {
    @ViewBuilder
    var sessionContent: some View {
        if showResults {
            resultsContent
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
        .background { AmbientBlobsView(.rich) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
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
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .onAppear { submitFlashcardAccuracy() }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { showGuide = true } label: {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(.plain)
        }
        ToolbarItem(placement: .topBarTrailing) {
            CircleCloseButton { showQuitAlert = true }
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
        GeometryReader { geometry in
            ZStack {
                FlashcardCardView(
                    card: currentCard,
                    isFlipped: isFlipped,
                    onTap: flipCard,
                    swipeColor: swipeTintColor,
                    swipeOpacity: swipeTintOpacity
                )
                .frame(
                    width: max(geometry.size.width - DesignSystem.Spacing.xl * 2, 0),
                    height: max(geometry.size.height * 0.85, 0)
                )
                .offset(dragOffset)
                .rotationEffect(.degrees(dragRotation))
                .gesture(swipeGesture)
                .overlay(alignment: .bottomTrailing) { swipeHintRight }
                .overlay(alignment: .bottomLeading) { swipeHintLeft }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    @ViewBuilder
    var swipeHintRight: some View {
        if dragOffset.width > 30 {
            Label(
                isFlipped ? "Correct" : "Knew It",
                systemImage: isFlipped ? "checkmark.circle.fill" : "bolt.circle.fill"
            )
            .font(DesignSystem.Font.title2)
            .fontWeight(.black)
            .foregroundStyle(DesignSystem.Color.success)
            .padding(DesignSystem.Spacing.lg)
            .rotationEffect(.degrees(15))
            .opacity(min(Double(dragOffset.width) / 100.0, 1.0))
            .scaleEffect(min(Double(dragOffset.width) / 100.0, 1.0))
        }
    }

    @ViewBuilder
    var swipeHintLeft: some View {
        if isFlipped, dragOffset.width < -30 {
            Label("Wrong", systemImage: "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .fontWeight(.black)
                .foregroundStyle(DesignSystem.Color.error)
                .padding(DesignSystem.Spacing.lg)
                .rotationEffect(.degrees(-15))
                .opacity(min(Double(-dragOffset.width) / 100.0, 1.0))
                .scaleEffect(min(Double(-dragOffset.width) / 100.0, 1.0))
        }
    }

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if isFlipped || value.translation.width > 20 {
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                if isFlipped {
                    handleSwipeEnd(translation: value.translation.width)
                } else if value.translation.width > 100 {
                    showSwipeFeedback(.knewIt)
                    flyOffAndAdvance(direction: .right, result: .easy)
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = .zero
                    }
                }
            }
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
            .transition(.move(edge: .bottom).combined(with: .opacity))
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
        let country = countryDataService.countries.first { $0.code == code }
        detailCountry = country
    }

    func flipCard() {
        if !isFlipped {
            let thinkingTime = Date.now.timeIntervalSince(cardShownAt)
            thinkingTimes.append(thinkingTime)
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isFlipped.toggle()
        }
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
        let exitX: CGFloat = exitRight ? 400 : -400

        withAnimation(.easeIn(duration: 0.2)) {
            dragOffset = CGSize(width: exitX, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if currentIndex + 1 < cards.count {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    currentIndex += 1
                    isFlipped = false
                    cardShownAt = .now
                    dragOffset = CGSize(width: 400, height: 0)
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    dragOffset = .zero
                }
            } else {
                withAnimation { showResults = true }
            }
        }
    }

    func handleSwipeEnd(translation: CGFloat) {
        let threshold: CGFloat = 100

        if translation > threshold {
            showSwipeFeedback(.correct)
            flyOffAndAdvance(direction: .right, result: .good)
        } else if translation < -threshold {
            showSwipeFeedback(.wrong)
            flyOffAndAdvance(direction: .left, result: .again)
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dragOffset = .zero
            }
        }
    }

    func flyOffAndAdvance(direction: SwipeDirection, result: FlashcardReviewResult) {
        let offscreenX: CGFloat = direction == .right ? 500 : -500

        withAnimation(.easeIn(duration: 0.25)) {
            dragOffset = CGSize(width: offscreenX, height: 0)
        }

        flashcardService.recordReview(cardID: currentCard.id, result: result)
        if result != .again { correctCount += 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if currentIndex + 1 < cards.count {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    currentIndex += 1
                    isFlipped = false
                    cardShownAt = .now
                    dragOffset = CGSize(width: 400, height: 0)
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    dragOffset = .zero
                }
            } else {
                withAnimation { showResults = true }
            }
        }
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

    var dragRotation: Double {
        Double(dragOffset.width) / 20.0
    }

    var swipeTintColor: Color {
        dragOffset.width >= 0 ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    var swipeTintOpacity: Double {
        let offset = dragOffset.width
        if offset > 0 {
            return min(offset / 150.0, 0.35)
        } else if isFlipped {
            return min(-offset / 150.0, 0.35)
        }
        return 0
    }

    var averageThinkingTime: TimeInterval {
        guard !thinkingTimes.isEmpty else { return 0 }
        return thinkingTimes.reduce(0, +) / Double(thinkingTimes.count)
    }
}

// MARK: - Swipe Feedback
enum SwipeFeedback {
    case correct
    case wrong
    case knewIt
}
