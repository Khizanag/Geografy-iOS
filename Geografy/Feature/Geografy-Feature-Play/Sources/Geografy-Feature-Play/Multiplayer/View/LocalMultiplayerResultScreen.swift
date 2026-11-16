#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct LocalMultiplayerResultScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(XPService.self) private var xpService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var appeared = false
    @State private var xpAwarded = false

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .onAppear { awardXPOnce() }
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
            IconBadge(resultIcon, color: resultColor, size: .hero)
                .symbolEffect(.bounce, value: reduceMotion ? false : appeared)
                .accessibilityHidden(true)

            Text(resultTitle)
                .font(DesignSystem.Font.title)
                .fontWeight(.black)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(resultSubtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .phaseEntrance()
    }

    var scoreComparison: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.md))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.md))
        return layout {
            scoreCard(
                label: "You",
                score: coordinator.playerScore,
                total: coordinator.questions.count,
                color: DesignSystem.Color.accent,
                isWinner: coordinator.playerScore > coordinator.opponentScore
            )
            Text("vs")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .accessibilityHidden(true)
            scoreCard(
                label: coordinator.opponent?.displayName ?? "Opponent",
                score: coordinator.opponentScore,
                total: coordinator.questions.count,
                color: DesignSystem.Color.error,
                isWinner: coordinator.opponentScore > coordinator.playerScore
            )
        }
        .phaseEntrance(index: 1, stagger: 0.2)
    }

    func scoreCard(label: String, score: Int, total: Int, color: Color, isWinner: Bool) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.warning)
                        .accessibilityHidden(true)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(isWinner ? "\(score) of \(total), winner" : "\(score) of \(total)")
    }

    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Rematch", systemImage: "arrow.2.squarepath", fullWidth: true) {
                hapticsService.impact(.light)
                coordinator.requestRematch()
            }

            Button {
                coordinator.leave()
            } label: {
                Text("Leave")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xs)
            }
        }
        .phaseEntrance(index: 2, stagger: 0.2)
    }
}

// MARK: - Actions
private extension LocalMultiplayerResultScreen {
    func awardXPOnce() {
        appeared = true
        guard !xpAwarded else { return }
        xpAwarded = true
        let opponentName = coordinator.opponent?.displayName ?? "Opponent"
        let scores = "You \(coordinator.playerScore), \(opponentName) \(coordinator.opponentScore)."
        let announcement = "\(resultTitle) \(scores)"
        AccessibilityNotification.Announcement(announcement).post()
        if isWin {
            xpService.award(25, source: .quizCompletedMedium)
            hapticsService.notification(.success)
        } else {
            xpService.award(10, source: .quizCompletedEasy)
        }
    }
}

// MARK: - Helpers
private extension LocalMultiplayerResultScreen {
    var isWin: Bool { coordinator.playerScore > coordinator.opponentScore }
    var isDraw: Bool { coordinator.playerScore == coordinator.opponentScore }

    var resultColor: Color {
        switch resultOutcome {
        case .win: DesignSystem.Color.success
        case .draw: DesignSystem.Color.warning
        case .loss: DesignSystem.Color.error
        }
    }

    var resultIcon: String {
        switch resultOutcome {
        case .win: "trophy.fill"
        case .draw: "equal.circle.fill"
        case .loss: "xmark.circle.fill"
        }
    }

    var resultTitle: String {
        switch resultOutcome {
        case .win: "Victory!"
        case .draw: "It's a Draw!"
        case .loss: "Defeat"
        }
    }

    var resultSubtitle: String {
        switch resultOutcome {
        case .win: "You outplayed your opponent!"
        case .draw: "Perfectly matched!"
        case .loss: "Better luck next time!"
        }
    }

    enum ResultOutcome {
        case win
        case draw
        case loss
    }

    var resultOutcome: ResultOutcome {
        if isWin { .win } else if isDraw { .draw } else { .loss }
    }
}
#endif
