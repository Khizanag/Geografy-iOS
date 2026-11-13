import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct MultiplayerResultScreen: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .largeTitle) private var scoreFontSize: CGFloat = 40

    public let match: MultiplayerMatch
    public let onRematch: () -> Void
    public let onDone: () -> Void

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Match Result")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { actionButtons }
            .toolbar {
            }
            .onAppear {
                announceResult()
            }
    }
}

// MARK: - Subviews
private extension MultiplayerResultScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                resultHeader
                scoreComparison
                ratingChangeSection
                roundByRoundSection
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
            .phaseEntrance()
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
        IconBadge(resultSystemImage, color: resultColor, size: .hero)
            .accessibilityHidden(true)
    }

    var resultTitle: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(match.resultLabel)
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(resultColor)
                .accessibilityAddTraits(.isHeader)

            Text("vs \(match.opponent.name)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Score Comparison
private extension MultiplayerResultScreen {
    var scoreComparison: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.md))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.lg))
        return layout {
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
                    .font(DesignSystem.Font.system(size: scoreFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(
                    "\(match.playerCorrectCount)/\(match.totalQuestions) correct"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("You")
        .accessibilityValue(
            "\(match.playerScore) points, \(match.playerCorrectCount) of \(match.totalQuestions) correct"
        )
    }

    var vsLabel: some View {
        Text("VS")
            .font(DesignSystem.Font.roundedCaption2)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .accessibilityHidden(true)
    }

    var opponentScoreCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(match.opponent.name.components(separatedBy: " ").first ?? "")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)

                Text("\(match.opponentScore)")
                    .font(DesignSystem.Font.system(size: scoreFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.purple)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(
                    "\(match.opponentCorrectCount)/\(match.totalQuestions) correct"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(match.opponent.name)
        .accessibilityValue(
            "\(match.opponentScore) points, \(match.opponentCorrectCount) of \(match.totalQuestions) correct"
        )
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
                    .accessibilityHidden(true)

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
        .accessibilityElement(children: .combine)
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
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .frame(minWidth: DesignSystem.Spacing.lg)
                    .accessibilityLabel("Round \(index)")

                if let flagCode = round.question.promptFlag {
                    FlagView(countryCode: flagCode, height: DesignSystem.Spacing.lg)
                        .accessibilityHidden(true)
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
        .accessibilityElement(children: .combine)
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
                .accessibilityHidden(true)

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
        GlassButton("Rematch", systemImage: "arrow.counterclockwise", fullWidth: true) {
            onRematch()
        }
    }

    var doneButton: some View {
        GlassButton("Done", systemImage: "checkmark", role: .secondary, fullWidth: true) {
            onDone()
        }
    }
}

// MARK: - Actions
private extension MultiplayerResultScreen {
    func announceResult() {
        let scores = "You \(match.playerScore), \(match.opponent.name) \(match.opponentScore)."
        let announcement = "\(match.resultLabel) \(scores) \(ratingChangeText)."
        AccessibilityNotification.Announcement(announcement).post()
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
