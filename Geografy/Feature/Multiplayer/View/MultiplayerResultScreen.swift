import SwiftUI
import GeografyDesign
import GeografyCore

struct MultiplayerResultScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let match: MultiplayerMatch
    let onRematch: () -> Void
    let onDone: () -> Void

    @State private var showContent = false
    @State private var blobAnimating = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                resultHeader
                scoreComparison
                ratingChangeSection
                roundByRoundSection
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .safeAreaInset(edge: .bottom) { actionButtons }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Match Result")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
        }
        .onAppear {
            startBlobAnimation()
            animateContent()
        }
    }
}

// MARK: - Result Header
private extension MultiplayerResultScreen {
    var resultHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            resultIcon
            resultTitle
        }
    }

    var resultIcon: some View {
        ZStack {
            Circle()
                .fill(resultColor.opacity(0.15))
                .frame(width: 80, height: 80)

            Image(systemName: resultSystemImage)
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(resultColor)
        }
    }

    var resultTitle: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(match.resultLabel)
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(resultColor)

            Text("vs \(match.opponent.name)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Score Comparison
private extension MultiplayerResultScreen {
    var scoreComparison: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            playerScoreCard
            vsLabel
            opponentScoreCard
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var playerScoreCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("You")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                Text("\(match.playerScore)")
                    .font(DesignSystem.Font.roundedLarge)
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(
                    "\(match.playerCorrectCount)/\(match.totalQuestions) correct"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var vsLabel: some View {
        Text("VS")
            .font(DesignSystem.Font.roundedCaption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }

    var opponentScoreCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(match.opponent.name.components(separatedBy: " ").first ?? "")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)

                Text("\(match.opponentScore)")
                    .font(DesignSystem.Font.roundedLarge)
                    .foregroundStyle(DesignSystem.Color.purple)

                Text(
                    "\(match.opponentCorrectCount)/\(match.totalQuestions) correct"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Rating Change
private extension MultiplayerResultScreen {
    var ratingChangeSection: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Rating Change")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)

                    Text(ratingChangeText)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(ratingChangeColor)
                }

                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Round by Round
private extension MultiplayerResultScreen {
    var roundByRoundSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Round by Round", icon: "list.number")
                .padding(.horizontal, DesignSystem.Spacing.md)

            ForEach(
                Array(match.rounds.enumerated()),
                id: \.element.id
            ) { index, round in
                roundRow(index: index + 1, round: round)
            }
        }
    }

    func roundRow(index: Int, round: MultiplayerRound) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("\(index)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(width: DesignSystem.Spacing.lg)

                if let flagCode = round.question.promptFlag {
                    FlagView(countryCode: flagCode, height: DesignSystem.Spacing.lg)
                }

                Text(round.question.correctCountry.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                roundResultIndicator(round)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func roundResultIndicator(_ round: MultiplayerRound) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Circle()
                .fill(playerRoundColor(round))
                .frame(
                    width: DesignSystem.Spacing.xs,
                    height: DesignSystem.Spacing.xs
                )

            Text(roundResultLabel(round))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(playerRoundColor(round))
        }
    }
}

// MARK: - Action Buttons
private extension MultiplayerResultScreen {
    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            rematchButton
            doneButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    var rematchButton: some View {
        Button(action: onRematch) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "arrow.counterclockwise")
                    .font(DesignSystem.Font.headline)
                Text("Rematch")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
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
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Background
private extension MultiplayerResultScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [resultColor.opacity(0.20), DesignSystem.Color.background.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 420, height: 340)
                .blur(radius: 40)
                .offset(x: -40, y: -80)
                .scaleEffect(blobAnimating ? 1.08 : 0.92)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.purple.opacity(0.14), DesignSystem.Color.background.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 44)
                .offset(x: 100, y: 120)
                .scaleEffect(blobAnimating ? 0.90 : 1.08)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    func startBlobAnimation() {
        guard !reduceMotion else { blobAnimating = true; return }
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
        }
    }
}

// MARK: - Animations
private extension MultiplayerResultScreen {
    func animateContent() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            showContent = true
        }
    }
}

// MARK: - Helpers
private extension MultiplayerResultScreen {
    var resultColor: Color {
        if match.playerWon {
            DesignSystem.Color.success
        } else if match.opponentWon {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.warning
        }
    }

    var resultSystemImage: String {
        if match.playerWon {
            "trophy.fill"
        } else if match.opponentWon {
            "xmark.shield.fill"
        } else {
            "equal.circle.fill"
        }
    }

    var ratingChangeText: String {
        let change = match.playerRatingChange
        if change >= 0 {
            return "+\(change) ELO"
        }
        return "\(change) ELO"
    }

    var ratingChangeColor: Color {
        if match.playerRatingChange > 0 {
            DesignSystem.Color.success
        } else if match.playerRatingChange < 0 {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.warning
        }
    }

    func playerRoundColor(_ round: MultiplayerRound) -> Color {
        if round.playerWonRound {
            DesignSystem.Color.success
        } else if round.opponentWonRound {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.warning
        }
    }

    func roundResultLabel(_ round: MultiplayerRound) -> String {
        if round.playerWonRound {
            "Won"
        } else if round.opponentWonRound {
            "Lost"
        } else {
            "Draw"
        }
    }
}
