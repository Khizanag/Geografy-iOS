#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct LocalMultiplayerResultScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(XPService.self) private var xpService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var appeared = false
    @State private var xpAwarded = false

    // MARK: - Body
    public var body: some View {
        GameResultLayout(
            title: Text(resultTitle),
            message: Text(resultSubtitle),
            xpEarned: xpAwarded ? XPRules.multiplayer(won: isWin) : 0,
            primaryAction: GameResultAction("Rematch", systemImage: "arrow.2.squarepath") {
                hapticsService.impact(.light)
                coordinator.requestRematch()
            },
            onDone: { coordinator.leave() },
            hero: {
                IconBadge(resultIcon, color: resultColor, size: .hero)
                    .symbolEffect(.bounce, value: reduceMotion ? false : appeared)
                    .accessibilityHidden(true)
            },
            stats: { scores }
        )
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
    @ViewBuilder
    var scores: some View {
        let total = coordinator.questions.count
        StatTile(
            value: "\(coordinator.playerScore)/\(total)",
            label: "You",
            icon: coordinator.playerScore > coordinator.opponentScore ? "crown.fill" : "person.fill",
            color: PairSide.left.color
        )
        StatTile(
            value: "\(coordinator.opponentScore)/\(total)",
            label: LocalizedStringKey(coordinator.opponent?.displayName ?? "Opponent"),
            icon: coordinator.opponentScore > coordinator.playerScore ? "crown.fill" : "person.fill",
            color: PairSide.right.color
        )
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
        xpService.award(XPRules.multiplayer(won: isWin), source: isWin ? .quizCompletedMedium : .quizCompletedEasy)
        if isWin {
            hapticsService.notification(.success)
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
