import Geografy_Core_DesignSystem
import SwiftUI

/// Shared end-of-session summary screen.
///
/// Renders:
/// - Confetti Lottie (falls back to a success symbol) when the session was
///   completed with >50% accuracy.
/// - Three stat cards: accuracy, best streak, XP earned (all `NumericTicker`).
/// - Average time per question.
/// - Retry / Continue CTAs.
///
/// Usage:
/// ```swift
/// QuizResultScreen(summary: summary,
///                  onRetry: { … },
///                  onContinue: { … })
/// ```
public struct QuizResultScreen: View {
    private let summary: QuizResultSummary
    private let onRetry: () -> Void
    private let onContinue: () -> Void

    public init(
        summary: QuizResultSummary,
        onRetry: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.summary = summary
        self.onRetry = onRetry
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            heroCelebration
                .phaseEntrance(index: 0)

            statsRow
                .phaseEntrance(index: 1)

            averageTimeCard
                .phaseEntrance(index: 2)

            Spacer(minLength: 0)

            actionStack
                .phaseEntrance(index: 3)
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Subviews
private extension QuizResultScreen {
    var heroCelebration: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if summary.completed, summary.accuracy >= 0.5 {
                GeoLottieView(.unlockConfetti, loopMode: .playOnce) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(DesignSystem.Color.success)
                }
                .frame(width: 180, height: 180)
            } else {
                Image(systemName: summary.completed ? "hand.thumbsup.fill" : "flag.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            Text(headline)
                .font(DesignSystem.Font.roundedHero)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(subtitle)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statCard(icon: "target", tint: DesignSystem.Color.success) {
                NumericTicker(
                    summary.accuracy * 100,
                    style: .integer,
                    font: DesignSystem.Font.title2
                )
                Text("Accuracy %")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            statCard(icon: "flame.fill", tint: DesignSystem.Color.orange) {
                NumericTicker(summary.bestStreak, font: DesignSystem.Font.title2)
                Text("Best streak")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            statCard(icon: "bolt.fill", tint: DesignSystem.Color.warning) {
                NumericTicker(summary.xpEarned, font: DesignSystem.Font.title2)
                Text("XP earned")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var averageTimeCard: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "clock")
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text("Avg. time per question")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            Text(formattedTime)
                .font(DesignSystem.Font.callout.monospacedDigit())
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                .fill(DesignSystem.Color.cardBackground)
        )
    }

    var actionStack: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Button(action: onContinue) {
                Text("Continue")
                    .font(DesignSystem.Font.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignSystem.Color.accent)

            Button(action: onRetry) {
                Text("Retry")
                    .font(DesignSystem.Font.callout)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(.plain)
            .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func statCard<Content: View>(
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .font(DesignSystem.Font.title3)
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                .fill(DesignSystem.Color.cardBackground)
        )
    }

    var headline: String {
        guard summary.completed else { return "Game over" }
        switch summary.accuracy {
        case 0.9...:    "Outstanding"
        case 0.7..<0.9: "Great job"
        case 0.5..<0.7: "Well done"
        default:        "Keep going"
        }
    }

    var subtitle: String {
        "\(summary.correct) of \(summary.totalQuestions) correct"
    }

    var formattedTime: String {
        let seconds = summary.averageTimePerQuestion
        return seconds > 0 ? String(format: "%.1fs", seconds) : "—"
    }
}
