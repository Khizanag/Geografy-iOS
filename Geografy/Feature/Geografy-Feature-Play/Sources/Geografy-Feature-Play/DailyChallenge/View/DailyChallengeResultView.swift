import Accessibility
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct DailyChallengeResultView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(AchievementService.self) private var achievementService

    public let score: Int
    public let maxScore: Int
    public let challengeType: DailyChallengeType
    public let timeSpent: Double
    public let streak: Int

    // MARK: - Init
    public init(
        score: Int,
        maxScore: Int,
        challengeType: DailyChallengeType,
        timeSpent: Double,
        streak: Int
    ) {
        self.score = score
        self.maxScore = maxScore
        self.challengeType = challengeType
        self.timeSpent = timeSpent
        self.streak = streak
    }

    // MARK: - Body
    public var body: some View {
        resultContent
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .onAppear { announceScore() }
    }
}

// MARK: - Content
private extension DailyChallengeResultView {
    var resultContent: some View {
        GameResultLayout(
            title: Text(scoreMessage),
            message: Text("\(score) of \(maxScore) points"),
            xpEarned: XPRules.dailyChallenge(score: score, maxScore: maxScore),
            primaryAction: nil,
            share: resultShare,
            onDone: { dismiss() },
            hero: {
                ScoreRingView(progress: Double(score) / Double(maxScore))
                    .accessibilityLabel("Score: \(score) out of \(maxScore) points")
            },
            stats: { stats },
            details: { streakBadge }
        )
        .screenBackground()
    }

    @ViewBuilder
    var stats: some View {
        StatTile(value: "\(score)", label: "Score", icon: "star.fill", color: DesignSystem.Color.orange)
        StatTile(value: formattedTime, label: "Time", icon: "clock.fill", color: DesignSystem.Color.blue)
        StatTile(
            value: challengeType.title,
            label: "Challenge",
            icon: challengeType.iconName,
            color: DesignSystem.Color.indigo
        )
    }
}

// MARK: - Streak Badge
private extension DailyChallengeResultView {
    var streakBadge: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                IconBadge("flame.fill", color: DesignSystem.Color.orange, size: .medium)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Challenge Streak")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(streak)-day streak")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Challenge Streak: \(streak)-day streak")
    }
}

// MARK: - Share
private extension DailyChallengeResultView {
    var resultShare: ResultShare {
        ResultShare(
            game: challengeType.title,
            score: "\(score)",
            caption: String(localized: "out of \(maxScore)"),
            fraction: Double(score) / Double(maxScore),
            details: [ResultShare.Detail(String(localized: "\(streak)-day streak"), systemImage: "flame.fill")],
            onShare: achievementService.recordShare
        )
    }
}

// MARK: - Helpers
private extension DailyChallengeResultView {
    var scoreMessage: String {
        let accuracy = Double(score) / Double(maxScore)
        if accuracy >= 0.9 {
            return "Outstanding!"
        } else if accuracy >= 0.7 {
            return "Great Job!"
        } else if accuracy >= 0.5 {
            return "Good Effort!"
        } else {
            return "Keep Trying!"
        }
    }

    var formattedTime: String {
        let minutes = Int(timeSpent) / 60
        let seconds = Int(timeSpent) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    func announceScore() {
        AccessibilityNotification.Announcement("\(scoreMessage) \(score) out of \(maxScore) points").post()
    }
}
