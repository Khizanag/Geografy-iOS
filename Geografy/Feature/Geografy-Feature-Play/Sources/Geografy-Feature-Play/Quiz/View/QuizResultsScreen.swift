import Accessibility
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftData
import SwiftUI

public struct QuizResultsScreen: View {
    // MARK: - Properties
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(DatabaseManager.self) private var database
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(PronunciationService.self) private var pronunciationService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    public let result: QuizResult
    public let onPlayAgain: () -> Void
    public let onDone: () -> Void

    @State private var xpEarned = 0

    // MARK: - Body
    public var body: some View {
        GameResultLayout(
            title: Text(scoreMessage),
            message: Text("\(result.correctCount) of \(result.answers.count) correct"),
            xpEarned: xpEarned,
            primaryAction: .playAgain {
                #if !os(tvOS)
                hapticsService.impact(.light)
                #endif
                onPlayAgain()
            },
            onDone: onDone,
            hero: { ScoreRingView(progress: result.accuracy) },
            stats: { stats },
            details: { answersSection }
        )
        .screenBackground()
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .task { processQuizResult() }
    }
}

// MARK: - Subviews
private extension QuizResultsScreen {
    @ViewBuilder
    var stats: some View {
        StatTile(
            value: "\(result.correctCount)",
            label: "Correct",
            icon: "checkmark.circle.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(result.incorrectCount)",
            label: "Wrong",
            icon: "xmark.circle.fill",
            color: DesignSystem.Color.error
        )
        StatTile(value: formattedTime, label: "Time", icon: "clock.fill", color: DesignSystem.Color.blue)
    }

    var answersSection: some View {
        LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Answers")

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
                    FlagView(countryCode: flagCode, height: DesignSystem.Spacing.lg, fixedWidth: true)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(index). \(answer.question.correctCountry.name), \(answer.isCorrect ? "correct" : "incorrect")"
        )
    }
}

// MARK: - Gamification
private extension QuizResultsScreen {
    func processQuizResult() {
        let difficulty = result.configuration.difficulty
        let earnedXP = XPRules.quiz(
            difficulty: difficulty,
            accuracy: result.accuracy,
            isTyping: result.configuration.answerMode == .typing
        )

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

        xpService.award(earnedXP, source: XPRules.quizSource(for: difficulty))
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

        #if !os(tvOS)
        if result.accuracy >= 0.7 {
            hapticsService.notification(.success)
        } else {
            hapticsService.notification(.warning)
        }
        #endif

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
        let totalSeconds = Int(result.totalTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)s"
    }
}
