import Accessibility
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftData
import SwiftUI

public struct QuizResultsScreen: View {
    // MARK: - Properties
    @Environment(XPService.self) private var xpService
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(Navigator.self) private var coordinator
    @Environment(AchievementService.self) private var achievementService
    @Environment(DatabaseManager.self) private var database
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(PronunciationService.self) private var pronunciationService

    public let result: QuizResult
    public let onPlayAgain: () -> Void
    public let onDone: () -> Void

    @State private var xpEarned = 0
    /// The task runs again when the screen comes back, such as after reviewing misses; the quiz counts once.
    @State private var hasProcessed = false

    // MARK: - Body
    public var body: some View {
        GameResultLayout(
            title: Text(scoreMessage),
            message: Text("\(result.correctCount) of \(result.answers.count) correct"),
            xpEarned: xpEarned,
            primaryAction: .playAgain { onPlayAgain() },
            share: resultShare,
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
        .haptic(trigger: hasProcessed) { _, isProcessed in
            guard isProcessed else { return nil }
            return result.accuracy >= 0.7 ? .success : .warning
        }
    }
}

// MARK: - Share
private extension QuizResultsScreen {
    var resultShare: ResultShare {
        ResultShare(
            game: result.configuration.type.displayName,
            score: "\(result.correctCount)/\(result.answers.count)",
            caption: String(localized: "\(Int((result.accuracy * 100).rounded()))% correct"),
            fraction: result.accuracy,
            details: [
                ResultShare.Detail(result.configuration.region.displayName, systemImage: "globe"),
                ResultShare.Detail(
                    Duration.seconds(result.totalTime).formatted(.time(pattern: .minuteSecond)),
                    systemImage: "clock"
                ),
            ],
            onShare: achievementService.recordShare
        )
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
            HStack {
                SectionHeaderView(title: "Answers")
                Spacer()
                reviewMissedButton
            }

            ForEach(Array(result.answers.enumerated()), id: \.element.id) { index, answer in
                answerRow(index: index + 1, answer: answer)
            }
        }
    }

    /// Opens the missed answers as flashcards, for quizzes whose questions match a card.
    @ViewBuilder
    var reviewMissedButton: some View {
        if let cardType = FlashcardType(quizType: result.configuration.type), !missedCountries.isEmpty {
            Button("Review \(missedCountries.count) Missed", systemImage: "rectangle.on.rectangle.angled") {
                let cards = missedCountries.map { FlashcardItem.make(from: $0, type: cardType) }
                coordinator.push(PlayLocalRoute.flashcardSession(deck: .missed(cardType: cardType), cards: cards))
            }
            .buttonStyle(.glass)
            .controlSize(.small)
        }
    }

    var missedCountries: [Country] {
        var seen = Set<String>()
        return result.answers
            .filter { !$0.isCorrect }
            .map(\.question.correctCountry)
            .filter { seen.insert($0.code).inserted }
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
        guard !hasProcessed else { return }
        hasProcessed = true
        countAnswersInReviews()
        let difficulty = result.configuration.difficulty
        let earnedXP = XPRules.quiz(
            difficulty: difficulty,
            accuracy: result.accuracy,
            isTyping: result.configuration.answerMode == .typing,
            finished: !result.gaveUp
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
        database.mainContext.saveOrLog()

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

        let announcement = "\(scoreMessage) \(result.correctCount) correct out of \(result.answers.count)"
        AccessibilityNotification.Announcement(announcement).post()
    }
}

// MARK: - Helpers
private extension QuizResultsScreen {
    var scoreMessage: String {
        if result.accuracy >= 0.9 {
            "Excellent"
        } else if result.accuracy >= 0.7 {
            "Great Job"
        } else if result.accuracy >= 0.5 {
            "Good Effort"
        } else {
            "Keep Practicing"
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

// MARK: - Reviews
private extension QuizResultsScreen {
    /// Every answer counts toward the matching flashcard, so quizzes and reviews build one record per country.
    func countAnswersInReviews() {
        guard let cardType = FlashcardType(quizType: result.configuration.type) else { return }
        for answer in result.answers {
            flashcardService.recordGameAnswer(
                countryCode: answer.question.correctCountry.code,
                type: cardType,
                isCorrect: answer.isCorrect
            )
        }
        flashcardService.persistPendingChanges()
    }
}
