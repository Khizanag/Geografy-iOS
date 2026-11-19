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
    @Environment(\.locale) private var locale

    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var appeared = false
    @State private var xpAwarded = false

    // MARK: - Body
    public var body: some View {
        GameResultLayout(
            title: Text(resultTitle),
            message: Text(message),
            xpEarned: xpAwarded ? XPRules.multiplayer(won: isWin) : 0,
            primaryAction: rematchAction,
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
            Button("Play Again") { coordinator.acceptRematch() }
            Button("Not Now", role: .cancel) { coordinator.declineRematch() }
        } message: {
            Text("\(opponentName) wants to play again with the same settings.")
        }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerResultScreen {
    @ViewBuilder
    var scores: some View {
        StatTile(
            value: scoreText(coordinator.playerScore),
            label: "You",
            icon: coordinator.playerScore > coordinator.opponentScore ? "crown.fill" : "person.fill",
            color: PairSide.left.color
        )
        StatTile(
            value: scoreText(coordinator.opponentScore),
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
    /// Right answers out of the questions in a quiz; points in Pin Drop.
    func scoreText(_ score: Int) -> String {
        switch coordinator.activeGame {
        case .quiz: "\(score)/\(coordinator.questions.count)"
        case .pinDrop: PinDropStyle.points(Double(score), locale: locale)
        }
    }

    var opponentName: String {
        coordinator.opponent?.displayName ?? String(localized: "Opponent", bundle: .module)
    }

    /// Rematch until the other player leaves; while waiting for their answer, a button that says so.
    var rematchAction: GameResultAction? {
        if coordinator.opponentLeftAfterMatch { return nil }
        if coordinator.isAwaitingRematch {
            return GameResultAction("Waiting...", systemImage: "hourglass") {}
        }
        return GameResultAction("Rematch", systemImage: "arrow.2.squarepath") {
            hapticsService.impact(.light)
            coordinator.requestRematch()
        }
    }

    var message: String {
        if coordinator.opponentLeftAfterMatch {
            return String(localized: "\(opponentName) left, so there's no rematch.", bundle: .module)
        }
        if coordinator.rematchDeclined {
            return String(localized: "\(opponentName) doesn't want a rematch right now.", bundle: .module)
        }
        if coordinator.isAwaitingRematch {
            return String(localized: "Asked \(opponentName) for a rematch.", bundle: .module)
        }
        return resultSubtitle
    }

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
