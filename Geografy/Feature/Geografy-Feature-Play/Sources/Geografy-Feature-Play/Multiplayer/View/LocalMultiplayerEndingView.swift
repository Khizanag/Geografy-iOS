#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

/// What happened when a lobby or match ends early: the other player gave up, closed the lobby, or dropped. It
/// offers the same role again, so a host can wait for someone new and a guest can look for another game.
struct LocalMultiplayerEndingView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let coordinator: LocalMultiplayerCoordinator

    // MARK: - Body
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PulsingCirclesView(icon: icon, isAnimating: !reduceMotion, color: LocalMultiplayerEntryScreen.color)
                .accessibilityHidden(true)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(message)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .navigationTitle("Local Play")
        .navigationBarTitleDisplayMode(.inline)
        .bottomActionBar { buttons }
        .onAppear {
            AccessibilityNotification.Announcement(title).post()
        }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerEndingView {
    var buttons: some View {
        ButtonRow {
            GlassButton("Done", systemImage: "checkmark", role: .secondary, fullWidth: true) {
                coordinator.leave()
            }
            GlassButton(
                coordinator.isHost ? "Host Again" : "Find a Game",
                systemImage: coordinator.isHost ? "antenna.radiowaves.left.and.right" : "magnifyingglass",
                fullWidth: true,
                action: playAgain
            )
        }
    }
}

// MARK: - Helpers
private extension LocalMultiplayerEndingView {
    var icon: String {
        switch coordinator.ending {
        case .opponentGaveUp: "flag.fill"
        case .hostClosedLobby: "door.left.hand.open"
        case .questionsFailed: "exclamationmark.triangle.fill"
        case .connectionLost, nil: "wifi.slash"
        }
    }

    var title: String {
        switch coordinator.ending {
        case .opponentGaveUp(let name): String(localized: "\(name) Gave Up", bundle: .module)
        case .hostClosedLobby(let name): String(localized: "\(name) Closed the Lobby", bundle: .module)
        case .questionsFailed: String(localized: "Couldn't Start the Match", bundle: .module)
        case .connectionLost, nil: String(localized: "Connection Lost", bundle: .module)
        }
    }

    var message: LocalizedStringKey {
        switch coordinator.ending {
        case .opponentGaveUp:
            "The match ended early, so it doesn't count."
        case .hostClosedLobby:
            "Look for another game nearby, or host one yourself."
        case .questionsFailed:
            "This phone couldn't load the host's questions. Make sure both phones have the latest Geografy."
        case .connectionLost(let name):
            "The connection to \(name) dropped. Stay close, on the same Wi-Fi or with Bluetooth on."
        case nil:
            "The connection to the other player dropped. Stay close, on the same Wi-Fi or with Bluetooth on."
        }
    }

    func playAgain() {
        let wasHost = coordinator.isHost
        coordinator.leave()
        if wasHost {
            coordinator.startHosting()
        } else {
            coordinator.startBrowsing()
        }
    }
}
#endif
