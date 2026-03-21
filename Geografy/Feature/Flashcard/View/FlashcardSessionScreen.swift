import SwiftUI

struct FlashcardSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FlashcardService.self) private var flashcardService

    let deck: FlashcardDeck
    let cards: [FlashcardItem]

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showResults = false
    @State private var correctCount = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showQuitAlert = false
    @State private var blobAnimating = false

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
                .onAppear { startBlobAnimation() }
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
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    var resultsContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                FlashcardStatsView(
                    cardsReviewed: cards.count,
                    correctCount: correctCount,
                    totalCards: cards.count
                )
                doneButton
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton { showQuitAlert = true }
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
        HStack(spacing: DesignSystem.Spacing.sm) {
            progressBar
            counterPill
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Color.accent,
                                DesignSystem.Color.accent.opacity(0.7),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progressFraction)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8),
                        value: progressFraction
                    )
            }
        }
        .frame(height: 6)
    }

    var counterPill: some View {
        Text("\(currentIndex + 1)/\(cards.count)")
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: Capsule()
            )
    }
}

// MARK: - Card

private extension FlashcardSessionScreen {
    var cardSection: some View {
        GeometryReader { geometry in
            FlashcardCardView(
                card: currentCard,
                isFlipped: isFlipped,
                onTap: flipCard
            )
            .frame(
                width: geometry.size.width - DesignSystem.Spacing.xl * 2,
                height: geometry.size.height * 0.85
            )
            .offset(dragOffset)
            .rotationEffect(.degrees(dragRotation))
            .gesture(swipeGesture)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard isFlipped else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard isFlipped else { return }
                handleSwipeEnd(translation: value.translation.width)
            }
    }
}

// MARK: - Rating

private extension FlashcardSessionScreen {
    @ViewBuilder
    var ratingSection: some View {
        if isFlipped {
            ratingButtons
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, DesignSystem.Spacing.md)
        } else {
            Spacer(minLength: 0)
        }
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
        Button { dismiss() } label: {
            Label("Done", systemImage: "checkmark")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Background

private extension FlashcardSessionScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.22),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 420, height: 320)
                .blur(radius: 36)
                .offset(x: -80, y: -100)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.indigo.opacity(0.18),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 44)
                .offset(x: 140, y: 60)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.purple.opacity(0.14),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 40)
                .offset(x: -40, y: 400)
                .scaleEffect(blobAnimating ? 1.05 : 0.95)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Actions

private extension FlashcardSessionScreen {
    func flipCard() {
        guard !isFlipped else { return }
        withAnimation { isFlipped = true }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func recordReview(_ result: FlashcardReviewResult) {
        flashcardService.recordReview(
            cardID: currentCard.id,
            result: result
        )

        if result != .again {
            correctCount += 1
        }

        advanceToNext()
    }

    func advanceToNext() {
        if currentIndex + 1 < cards.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIndex += 1
                isFlipped = false
                dragOffset = .zero
            }
        } else {
            withAnimation {
                showResults = true
            }
        }
    }

    func handleSwipeEnd(translation: CGFloat) {
        let threshold: CGFloat = 100

        if translation > threshold {
            recordReview(.good)
        } else if translation < -threshold {
            recordReview(.again)
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dragOffset = .zero
        }
    }

    func startBlobAnimation() {
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
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
}
