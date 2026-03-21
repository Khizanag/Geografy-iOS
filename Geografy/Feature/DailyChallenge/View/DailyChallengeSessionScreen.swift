import SwiftUI

struct DailyChallengeSessionScreen: View {
    @Environment(\.dismiss) private var dismiss

    let challenge: DailyChallenge
    let service: DailyChallengeService

    @State private var score: Int = 1000
    @State private var startTime = Date()
    @State private var showQuitAlert = false
    @State private var showResult = false
    @State private var blobAnimating = false

    // Challenge-specific step indices (bound to child views)
    @State private var revealedClueCount = 1
    @State private var mysteryGuess = ""
    @State private var mysteryGuessSubmitted = false
    @State private var currentFlagIndex = 0
    @State private var currentChainStep = 0

    var body: some View {
        NavigationStack {
            challengeContent
                .navigationTitle(challenge.type.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .alert("Quit Challenge?", isPresented: $showQuitAlert) {
                    quitAlertActions
                } message: {
                    Text("Your progress will be lost.")
                }
                .sheet(isPresented: $showResult) { resultSheet }
                .onAppear { startBlobAnimation() }
        }
    }
}

// MARK: - Toolbar

private extension DailyChallengeSessionScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) { scorePill }
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton { showQuitAlert = true }
        }
    }

    var scorePill: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("\(score)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.accent.opacity(0.15),
            in: Capsule()
        )
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { dismiss() }
    }
}

// MARK: - Content Router

private extension DailyChallengeSessionScreen {
    var challengeContent: some View {
        Group {
            switch challenge.content {
            case .mysteryCountry(let content):
                MysteryCountryView(
                    content: content,
                    score: $score,
                    revealedClueCount: $revealedClueCount,
                    guess: $mysteryGuess,
                    guessSubmitted: $mysteryGuessSubmitted,
                    onFinish: finishChallenge
                )
            case .flagSequence(let content):
                FlagSequenceView(
                    content: content,
                    seed: challenge.seed,
                    score: $score,
                    currentIndex: $currentFlagIndex,
                    onFinish: finishChallenge
                )
            case .capitalChain(let content):
                CapitalChainView(
                    content: content,
                    score: $score,
                    currentStep: $currentChainStep,
                    onFinish: finishChallenge
                )
            }
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    var resultSheet: some View {
        DailyChallengeResultView(
            score: score,
            maxScore: 1000,
            challengeType: challenge.type,
            timeSpent: Date().timeIntervalSince(startTime),
            streak: service.streak + 1,
            onDismiss: { dismiss() }
        )
    }
}

// MARK: - Background

private extension DailyChallengeSessionScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        DesignSystem.Color.accent.opacity(0.20),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 420, height: 320)
                .blur(radius: 36)
                .offset(x: -80, y: -100)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        DesignSystem.Color.indigo.opacity(0.16),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 300)
                .blur(radius: 44)
                .offset(x: 140, y: 200)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    func startBlobAnimation() {
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
        }
    }
}

// MARK: - Actions

private extension DailyChallengeSessionScreen {
    func finishChallenge() {
        let timeSpent = Date().timeIntervalSince(startTime)
        service.saveResult(score: score, timeSpent: timeSpent)
        showResult = true
    }
}
