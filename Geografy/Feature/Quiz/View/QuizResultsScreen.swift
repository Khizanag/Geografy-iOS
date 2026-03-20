import SwiftUI

struct QuizResultsScreen: View {
    @Environment(\.dismiss) private var dismiss

    let result: QuizResult
    let onPlayAgain: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                scoreSection
                statsRow
                answersSection
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Results")
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Subviews

private extension QuizResultsScreen {
    var scoreSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ScoreRingView(progress: result.accuracy)

            Text(scoreMessage)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
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
        GeoCard {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(color)

                Text(value)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var answersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Answers")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)

            ForEach(Array(result.answers.enumerated()), id: \.element.id) { index, answer in
                answerRow(index: index + 1, answer: answer)
            }
        }
    }

    func answerRow(index: Int, answer: QuizAnswer) -> some View {
        GeoCard {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("\(index)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(width: DesignSystem.Spacing.lg)

                if let flagCode = answer.question.promptFlag {
                    FlagView(countryCode: flagCode, height: DesignSystem.Spacing.lg)
                }

                Text(answer.question.correctCountry.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(answer.isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
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
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(.glass)
    }

    var doneButton: some View {
        Button { dismiss() } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "checkmark")
                    .font(DesignSystem.Font.headline)

                Text("Done")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(.glass)
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
