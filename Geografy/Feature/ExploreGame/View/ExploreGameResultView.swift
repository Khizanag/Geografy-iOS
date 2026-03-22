import SwiftUI

/// Shows the result after a game round — score, country reveal, stats.
struct ExploreGameResultView: View {
    let result: ExploreGameResult
    let onPlayAgain: () -> Void
    let onDone: () -> Void

    @State private var scoreAnimated = false
    @State private var contentVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                resultHeader
                countryReveal
                statsSection
                actionButtons
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .onAppear { animateIn() }
    }
}

// MARK: - Subviews

private extension ExploreGameResultView {
    var resultHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            resultIcon
            scoreDisplay
            resultMessage
        }
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 20)
    }

    var resultIcon: some View {
        ZStack {
            Circle()
                .fill(resultColor.opacity(0.15))
                .frame(width: 80, height: 80)

            Image(systemName: result.wasRevealed ? "eye.fill" : "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(resultColor)
                .scaleEffect(scoreAnimated ? 1.0 : 0.5)
        }
    }

    var scoreDisplay: some View {
        Text("\(scoreAnimated ? result.score : 0)")
            .font(.system(size: 56, weight: .black, design: .rounded))
            .foregroundStyle(resultColor)
            .contentTransition(.numericText())
    }

    var resultMessage: some View {
        Text(messageText)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .multilineTextAlignment(.center)
    }

    var countryReveal: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(
                    countryCode: result.country.code,
                    height: DesignSystem.Size.xxl
                )

                Text(result.country.name)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                HStack(spacing: DesignSystem.Spacing.md) {
                    statPill(
                        icon: "lightbulb.fill",
                        value: "\(result.cluesUsed) clues"
                    )
                    statPill(
                        icon: "xmark.circle",
                        value: "\(result.wrongGuesses) wrong"
                    )
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 30)
    }

    var statsSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Round Summary")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                summaryRow(
                    label: "Clues Used",
                    value: "\(result.cluesUsed) / 5"
                )
                summaryRow(
                    label: "Wrong Guesses",
                    value: "\(result.wrongGuesses)"
                )
                summaryRow(
                    label: "Final Score",
                    value: "\(result.score) pts"
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
        .opacity(contentVisible ? 1 : 0)
    }

    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true, action: onPlayAgain)
            GlassButton("Done", systemImage: "checkmark", role: .secondary, fullWidth: true, action: onDone)
        }
        .opacity(contentVisible ? 1 : 0)
    }
}

// MARK: - Helper Subviews

private extension ExploreGameResultView {
    func statPill(icon: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
            Text(value)
                .font(DesignSystem.Font.caption)
        }
        .foregroundStyle(DesignSystem.Color.textSecondary)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: Capsule()
        )
    }

    func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            Text(value)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Helpers

private extension ExploreGameResultView {
    var resultColor: Color {
        if result.wasRevealed {
            DesignSystem.Color.warning
        } else if result.score >= 800 {
            DesignSystem.Color.success
        } else if result.score >= 400 {
            DesignSystem.Color.accent
        } else {
            DesignSystem.Color.orange
        }
    }

    var messageText: String {
        if result.wasRevealed {
            "The answer was revealed"
        } else if result.score >= 800 {
            "Excellent! You really know your geography!"
        } else if result.score >= 400 {
            "Good job! Keep exploring!"
        } else {
            "Nice try! Practice makes perfect!"
        }
    }
}

// MARK: - Animations

private extension ExploreGameResultView {
    func animateIn() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            contentVisible = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            scoreAnimated = true
        }

        if !result.wasRevealed, result.score > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.success)
            }
        }
    }
}
