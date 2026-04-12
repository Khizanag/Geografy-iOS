import Geografy_Core_DesignSystem
import SwiftUI

/// Heads-up display shared by every quiz-style feature.
///
/// Observes a ``QuizSession`` and renders: progress pill, score ticker,
/// streak flame, and (when lives are enabled) heart indicators. Timer
/// rendering is delegated to ``QuizTimerRing`` which a caller can slot in
/// when ``QuizSession/Configuration/timePerQuestion`` is set.
public struct QuizHUD: View {
    private let session: QuizSession

    public init(session: QuizSession) {
        self.session = session
    }

    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            questionPill
            Spacer(minLength: 0)
            streakBadge
            scoreTicker
            if session.configuration.initialLives > 0 {
                livesIndicator
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            Capsule(style: .continuous)
                .fill(DesignSystem.Color.cardBackground)
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews
private extension QuizHUD {
    var questionPill: some View {
        HStack(spacing: 4) {
            Text("\(session.questionIndex + 1)")
                .monospacedDigit()
            Text("/")
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("\(session.configuration.totalQuestions)")
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .monospacedDigit()
        }
        .font(DesignSystem.Font.headline)
        .foregroundStyle(DesignSystem.Color.textPrimary)
        .accessibilityLabel("Question \(session.questionIndex + 1) of \(session.configuration.totalQuestions)")
    }

    var scoreTicker: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(DesignSystem.Color.warning)
                .font(DesignSystem.Font.callout)
            NumericTicker(session.score, font: DesignSystem.Font.headline)
        }
        .accessibilityLabel("Score \(session.score)")
    }

    var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(session.streak > 0 ? DesignSystem.Color.orange : DesignSystem.Color.textTertiary)
                .geoEffect(.streakIncrement(count: session.streak))
            NumericTicker(session.streak, font: DesignSystem.Font.headline)
                .foregroundStyle(session.streak > 0 ? DesignSystem.Color.textPrimary : DesignSystem.Color.textTertiary)
        }
        .opacity(session.streak > 0 ? 1 : 0.5)
        .accessibilityLabel(session.streak > 0 ? "Streak \(session.streak)" : "No streak")
    }

    var livesIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<session.configuration.initialLives, id: \.self) { index in
                let alive = index < session.livesRemaining
                Image(systemName: alive ? "heart.fill" : "heart")
                    .foregroundStyle(alive ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                    .font(DesignSystem.Font.footnote)
            }
        }
        .accessibilityLabel(
            "\(session.livesRemaining) of \(session.configuration.initialLives) lives remaining"
        )
    }
}
