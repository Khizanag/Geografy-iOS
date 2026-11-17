import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct DailyChallengeSessionScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService
    @Environment(GameCenterService.self) private var gameCenterService

    public let challenge: DailyChallenge
    public let service: DailyChallengeService

    @State private var score: Int = 1_000
    @State private var startTime = Date()
    @State private var showQuitAlert = false
    @State private var blobAnimating = false

    @State private var revealedClueCount = 1
    @State private var mysteryGuess = ""
    @State private var mysteryGuessSubmitted = false
    @State private var currentFlagIndex = 0
    @State private var currentChainStep = 0

    // MARK: - Body
    public var body: some View {
        challengeContent
            .navigationTitle(challenge.type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    GiveUpButton { showQuitAlert = true }
                }
            }
            .alert("Give Up?", isPresented: $showQuitAlert) {
                Button("Give Up", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Today's challenge stays open; you can try it again.")
            }
    }
}

// MARK: - Content
private extension DailyChallengeSessionScreen {
    var challengeContent: some View {
        VStack(spacing: 0) {
            scoreBanner

            challengeRouter
        }
        .screenBackground()
    }

    var scoreBanner: some View {
        HStack {
            Spacer()

            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)

                Text("\(String(score)) pts")
                    .font(DesignSystem.Font.roundedMicro2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.accent.opacity(DesignSystem.Opacity.tint), in: Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Score: \(score) points")

            Spacer()
        }
        .padding(.top, DesignSystem.Spacing.xs)
    }

    var challengeRouter: some View {
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
    }
}

// MARK: - Actions
private extension DailyChallengeSessionScreen {
    func finishChallenge() {
        let timeSpent = Date().timeIntervalSince(startTime)
        service.saveResult(score: score, timeSpent: timeSpent)
        xpService.award(XPRules.dailyChallenge(score: score, maxScore: 1_000), source: .dailyChallengeCompleted)

        // The leaderboard ranks how many challenges people have completed, not one day's score.
        let completedCount = service.history.count
        Task {
            await gameCenterService.submitScore(
                completedCount,
                to: GameCenterService.LeaderboardID.dailyChallengesWon
            )
        }

        coordinator.push(
            PlayLocalRoute.dailyChallengeResult(
                score: score,
                maxScore: 1_000,
                challengeType: challenge.type,
                timeSpent: timeSpent,
                streak: service.streak
            )
        )
    }
}
