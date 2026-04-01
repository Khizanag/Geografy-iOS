import GeografyCore
import Geografy_Core_Service
import GeografyDesign
import SwiftUI

struct DailyChallengeSessionScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(GameCenterService.self) private var gameCenterService

    let challenge: DailyChallenge
    let service: DailyChallengeService

    @State private var score: Int = 1000
    @State private var startTime = Date()
    @State private var showQuitAlert = false
    @State private var blobAnimating = false

    @State private var revealedClueCount = 1
    @State private var mysteryGuess = ""
    @State private var mysteryGuessSubmitted = false
    @State private var currentFlagIndex = 0
    @State private var currentChainStep = 0

    var body: some View {
        challengeContent
            .navigationTitle(challenge.type.title)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Quit Challenge?", isPresented: $showQuitAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Quit", role: .destructive) { coordinator.dismiss() }
            } message: {
                Text("Your progress will be lost.")
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
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
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
            .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
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

        Task {
            await gameCenterService.submitScore(
                score,
                to: GameCenterService.LeaderboardID.dailyChallengesWon
            )
        }

        coordinator.push(
            .dailyChallengeResult(
                score: score,
                maxScore: 1000,
                challengeType: challenge.type,
                timeSpent: timeSpent,
                streak: service.streak + 1
            )
        )
    }
}
