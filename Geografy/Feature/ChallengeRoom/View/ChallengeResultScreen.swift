import SwiftUI
import GeografyDesign

struct ChallengeResultScreen: View {
    @Environment(Navigator.self) private var coordinator

    let room: ChallengeRoom
    var onPlayAgain: (() -> Void)?

    var body: some View {
        scrollContent
            .safeAreaInset(edge: .bottom) { actionButtons }
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Subviews
private extension ChallengeResultScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                winnerSection

                scoresSection

                statsSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if let onPlayAgain {
                GlassButton("Play Again", systemImage: "arrow.counterclockwise", fullWidth: true) {
                    onPlayAgain()
                }
            }

            GlassButton("Done", systemImage: "checkmark", fullWidth: true) {
                coordinator.dismiss()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    var winnerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.warning.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: isTie ? "equal.circle.fill" : "trophy.fill")
                    .font(DesignSystem.Font.displayXS)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .symbolEffect(.bounce)
            }

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(isTie ? "It's a Tie!" : "\(winnerName) Wins!")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text(isTie ? "Both players scored equally" : "Congratulations!")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.xl)
    }

    var scoresSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            scoreCard(
                name: room.player1Name,
                score: room.player1Score,
                isWinner: room.player1Score > room.player2Score
            )

            Text("vs")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            scoreCard(
                name: room.player2Name,
                score: room.player2Score,
                isWinner: room.player2Score > room.player1Score
            )
        }
    }

    func scoreCard(name: String, score: Int, isWinner: Bool) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.warning)
                }

                Text("\(score)")
                    .font(DesignSystem.Font.roundedTitle)
                    .foregroundStyle(isWinner ? DesignSystem.Color.warning : DesignSystem.Color.textPrimary)

                Text(name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)

                Text("out of \(String(room.totalRounds))")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .frame(maxWidth: .infinity)
    }

    var statsSection: some View {
        CardView {
            HStack(spacing: 0) {
                ResultStatItem(
                    icon: "questionmark.circle.fill",
                    value: "\(String(room.totalRounds * 2))",
                    label: "Questions"
                )

                ResultStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(String(room.player1Score + room.player2Score))",
                    label: "Total Correct",
                    color: DesignSystem.Color.success
                )

                ResultStatItem(
                    icon: "chart.bar.fill",
                    value: "\(String(accuracy))%",
                    label: "Accuracy",
                    color: DesignSystem.Color.indigo
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Helpers
private extension ChallengeResultScreen {
    var isTie: Bool { room.player1Score == room.player2Score }

    var winnerName: String {
        if room.player1Score > room.player2Score { room.player1Name } else if room.player2Score > room.player1Score { room.player2Name } else { "" }
    }

    var accuracy: Int {
        let total = room.totalRounds * 2
        guard total > 0 else { return 0 }
        return Int(Double(room.player1Score + room.player2Score) / Double(total) * 100)
    }
}
