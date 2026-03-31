#if !os(tvOS)
import SwiftUI
import GeografyDesign

struct LocalMultiplayerResultScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(XPService.self) private var xpService

    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var appeared = false
    @State private var xpAwarded = false

    var body: some View {
        scrollContent
            .background { AmbientBlobsView(.standard) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .onAppear {
                appeared = true
                guard !xpAwarded else { return }
                xpAwarded = true
                if isWin {
                    xpService.award(25, source: .quizCompletedMedium)
                    hapticsService.notification(.success)
                } else {
                    xpService.award(10, source: .quizCompletedEasy)
                }
            }
            .alert("Rematch?", isPresented: $coordinator.rematchRequested) {
                Button("Accept") { coordinator.acceptRematch() }
                Button("Decline", role: .cancel) { coordinator.declineRematch() }
            } message: {
                Text("\(coordinator.opponent?.displayName ?? "Opponent") wants a rematch!")
            }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerResultScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                resultHeader
                scoreComparison
                actionButtons
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }

    var resultHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(resultColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: resultIcon)
                    .font(DesignSystem.Font.displayXXS)
                    .foregroundStyle(resultColor)
                    .symbolEffect(.bounce, value: appeared)
            }

            Text(resultTitle)
                .font(DesignSystem.Font.title)
                .fontWeight(.black)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(resultSubtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.8)
    }

    var scoreComparison: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            scoreCard(
                label: "You",
                score: coordinator.playerScore,
                total: coordinator.questions.count,
                color: DesignSystem.Color.accent,
                isWinner: coordinator.playerScore > coordinator.opponentScore
            )
            Text("vs")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            scoreCard(
                label: coordinator.opponent?.displayName ?? "Opponent",
                score: coordinator.opponentScore,
                total: coordinator.questions.count,
                color: DesignSystem.Color.error,
                isWinner: coordinator.opponentScore > coordinator.playerScore
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }

    func scoreCard(label: String, score: Int, total: Int, color: Color, isWinner: Bool) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.warning)
                }
                Text("\(score)/\(total)")
                    .font(DesignSystem.Font.roundedBody)
                    .foregroundStyle(color)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Rematch", systemImage: "arrow.2.squarepath", fullWidth: true) {
                hapticsService.impact(.medium)
                coordinator.requestRematch()
            }

            Button {
                coordinator.leave()
            } label: {
                Text("Leave")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xs)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
    }
}

// MARK: - Helpers
private extension LocalMultiplayerResultScreen {
    var isWin: Bool { coordinator.playerScore > coordinator.opponentScore }
    var isDraw: Bool { coordinator.playerScore == coordinator.opponentScore }

    var resultColor: Color {
        if isWin { DesignSystem.Color.success } else if isDraw { DesignSystem.Color.warning } else { DesignSystem.Color.error }
    }

    var resultIcon: String {
        if isWin { "trophy.fill" } else if isDraw { "equal.circle.fill" } else { "xmark.circle.fill" }
    }

    var resultTitle: String {
        if isWin { "Victory!" } else if isDraw { "It's a Draw!" } else { "Defeat" }
    }

    var resultSubtitle: String {
        if isWin { "You outplayed your opponent!" } else if isDraw { "Perfectly matched!" } else { "Better luck next time!" }
    }
}
#endif
