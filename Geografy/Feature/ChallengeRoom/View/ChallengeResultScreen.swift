import SwiftUI

struct ChallengeResultScreen: View {
    @Environment(\.dismiss) private var dismiss

    let room: ChallengeRoom
    let challengeRoomService: ChallengeRoomService
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            winnerSection
            scoresSection
            Spacer()
            actionButtons
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }
}

// MARK: - Subviews

private extension ChallengeResultScreen {
    var winnerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            trophyIcon
            winnerLabel
        }
    }

    var trophyIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.warning.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
            Image(systemName: isTie ? "equal.circle.fill" : "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Color.warning)
        }
    }

    var winnerLabel: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if isTie {
                Text("It's a Tie!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Both players scored equally")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else {
                Text("\(winnerName) wins!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Congratulations!")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }

    var scoresSection: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            scoreCard(
                name: room.player1Name,
                score: room.player1Score,
                isWinner: !isTie, winnerScore: room.player1Score > room.player2Score
            )
            Text("vs")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            scoreCard(
                name: room.player2Name,
                score: room.player2Score,
                isWinner: !isTie, winnerScore: room.player2Score > room.player1Score
            )
        }
    }

    func scoreCard(name: String, score: Int, isWinner: Bool, winnerScore: Bool) -> some View {
        let isThisWinner = isWinner && winnerScore
        return CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("\(score)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(isThisWinner ? DesignSystem.Color.warning : DesignSystem.Color.textPrimary)
                Text(name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                Text("out of \(room.totalRounds)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                if isThisWinner {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(DesignSystem.Color.warning)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .frame(maxWidth: .infinity)
    }

    var actionButtons: some View {
        GlassButton("Done", fullWidth: true) {
            onDismiss()
        }
    }
}

// MARK: - Helpers

private extension ChallengeResultScreen {
    var isTie: Bool { room.player1Score == room.player2Score }
    var winnerName: String { challengeRoomService.winnerName(for: room) ?? "" }
}
