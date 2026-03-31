import Accessibility
import SwiftUI
import GeografyDesign
import GeografyCore
import SwiftData

struct QuizResultsScreen: View {
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(DatabaseManager.self) private var database
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(PronunciationService.self) private var pronunciationService

    let result: QuizResult
    let onPlayAgain: () -> Void
    let onDone: () -> Void

    @State private var xpEarned = 0
    @State private var showXPBadge = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                scoreSection
                statsRow
                answersSection
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Results")
        .navigationBarBackButtonHidden()
        .task { processQuizResult() }
    }
}

// MARK: - Subviews
private extension QuizResultsScreen {
    var scoreSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ScoreRingView(progress: result.accuracy)
                .accessibilityLabel("Score: \(Int(result.accuracy * 100)) percent")

            Text(scoreMessage)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)

            if showXPBadge, xpEarned > 0 {
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    Image(systemName: "star.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .accessibilityHidden(true)
                    Text("+\(xpEarned) XP")
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Color.accent.opacity(0.15), in: Capsule())
                .transition(.scale(scale: 0.7).combined(with: .opacity))
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7).delay(0.5),
                    value: showXPBadge
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Earned \(xpEarned) XP")
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            statItem(
                icon: "checkmark.circle.fill",
                value: "\(result.correctCount)",
                color: DesignSystem.Color.success
            )
            statItem(
                icon: "xmark.circle.fill",
                value: "\(result.incorrectCount)",
                color: DesignSystem.Color.error
            )
            statItem(
                icon: "clock.fill",
                value: formattedTime,
                color: DesignSystem.Color.warning
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func statItem(icon: String, value: String, color: Color) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)

                Text(value)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }

    var answersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Answers")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .accessibilityAddTraits(.isHeader)

            ForEach(Array(result.answers.enumerated()), id: \.element.id) { index, answer in
                answerRow(index: index + 1, answer: answer)
            }
        }
    }

    func answerRow(index: Int, answer: QuizAnswer) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("\(index)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(width: DesignSystem.Spacing.lg)

                if let flagCode = answer.question.promptFlag {
                    FlagView(countryCode: flagCode, height: DesignSystem.Spacing.lg)
                        .frame(width: 40, alignment: .center)
                }

                Text(answer.question.correctCountry.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(answer.isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error)
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(index). \(answer.question.correctCountry.name), \(answer.isCorrect ? "correct" : "incorrect")"
        )
    }

    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            playAgainButton
            doneButton
        }
    }

    var playAgainButton: some View {
        Button(action: onPlayAgain) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "arrow.counterclockwise")
                    .font(DesignSystem.Font.headline)

                Text("Play Again")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }

    var doneButton: some View {
        Button { onDone() } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "checkmark")
                    .font(DesignSystem.Font.headline)

                Text("Done")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Gamification
private extension QuizResultsScreen {
    func processQuizResult() {
        let difficulty = result.configuration.difficulty
        let base: Int
        let maxBonus: Int
        let source: XPSource
        switch difficulty {
        case .easy: base = 15; maxBonus = 10; source = .quizCompletedEasy
        case .medium: base = 25; maxBonus = 15; source = .quizCompletedMedium
        case .hard: base = 40; maxBonus = 20; source = .quizCompletedHard
        }
        let typingMultiplier = result.configuration.answerMode == .typing ? 1.5 : 1.0
        let earnedXP = Int(Double(base + Int(result.accuracy * Double(maxBonus))) * typingMultiplier)

        let record = QuizHistoryRecord(
            userID: xpService.currentUserID,
            quizType: result.configuration.type.rawValue,
            difficulty: difficulty.rawValue,
            region: result.configuration.region.rawValue,
            correctCount: result.correctCount,
            totalCount: result.answers.count,
            totalTimeSeconds: result.totalTime,
            xpEarned: earnedXP
        )
        database.mainContext.insert(record)
        try? database.mainContext.save()

        xpService.award(earnedXP, source: source)
        xpEarned = earnedXP

        let quizScore = Int(result.accuracy * 100)
        Task {
            await gameCenterService.submitScore(
                quizScore,
                to: GameCenterService.LeaderboardID.quizHighScore
            )
        }

        let userID = xpService.currentUserID
        var descriptor = FetchDescriptor<QuizHistoryRecord>(
            predicate: #Predicate { $0.userID == userID }
        )
        descriptor.fetchLimit = 200
        let history = (try? database.mainContext.fetch(descriptor)) ?? []
        achievementService.checkQuizAchievements(history: history)

        showXPBadge = true

        let announcement = "\(scoreMessage) \(result.correctCount) correct out of \(result.answers.count)"
        AccessibilityNotification.Announcement(announcement).post()
    }
}

// MARK: - Helpers
private extension QuizResultsScreen {
    var scoreMessage: String {
        if result.accuracy >= 0.9 {
            "Excellent!"
        } else if result.accuracy >= 0.7 {
            "Great Job!"
        } else if result.accuracy >= 0.5 {
            "Good Effort!"
        } else {
            "Keep Practicing!"
        }
    }

    var formattedTime: String {
        let minutes = Int(result.totalTime) / 60
        let seconds = Int(result.totalTime) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}
