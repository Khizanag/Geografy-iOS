#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

/// A match from lobby to result. The system back button is hidden throughout: leaving goes through Close in the
/// lobby or Give Up in a match, each confirmed while another player would be affected, so the other phone is told.
struct LocalMultiplayerFlowView: View {
    // MARK: - Properties
    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var isConfirmingExit = false

    // MARK: - Body
    var body: some View {
        content
            .navigationBarBackButtonHidden()
            .toolbar { exitToolbar }
            .alert(exitTitle, isPresented: $isConfirmingExit) {
                Button(exitButtonTitle, role: .destructive) { coordinator.leave() }
                Button(stayButtonTitle, role: .cancel) {}
            } message: {
                Text(exitMessage)
            }
    }
}

// MARK: - Subviews
private extension LocalMultiplayerFlowView {
    @ViewBuilder
    var content: some View {
        switch coordinator.state {
        case .idle:
            EmptyView()
        case .advertising, .browsing, .lobby:
            LocalMultiplayerLobbyScreen(coordinator: coordinator)
        case .countdown:
            LocalMultiplayerCountdownView(coordinator: coordinator)
        case .playing:
            switch coordinator.activeGame {
            case .quiz:
                LocalMultiplayerMatchScreen(coordinator: coordinator)
            case .pinDrop:
                PinDropScreen(configuration: coordinator.activePinDropConfiguration, match: coordinator)
            }
        case .finished:
            LocalMultiplayerResultScreen(coordinator: coordinator)
        case .disconnected:
            LocalMultiplayerEndingView(coordinator: coordinator)
        }
    }

    @ToolbarContentBuilder
    var exitToolbar: some ToolbarContent {
        switch coordinator.state {
        case .advertising, .browsing:
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", systemImage: "xmark") { coordinator.leave() }
            }
        case .lobby:
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", systemImage: "xmark") { isConfirmingExit = true }
            }
        case .countdown, .playing:
            ToolbarItem(placement: .topBarLeading) {
                LeaveGameButton { isConfirmingExit = true }
            }
        case .idle, .finished, .disconnected:
            ToolbarItem(placement: .topBarLeading) { EmptyView() }
        }
    }
}

// MARK: - Helpers
private extension LocalMultiplayerFlowView {
    var isInMatch: Bool {
        switch coordinator.state {
        case .countdown, .playing: true
        default: false
        }
    }

    var opponentName: String {
        coordinator.opponent?.displayName ?? String(localized: "the other player", bundle: .module)
    }

    var exitTitle: LocalizedStringKey {
        isInMatch ? "Give Up?" : "Leave the Lobby?"
    }

    var exitMessage: LocalizedStringKey {
        isInMatch
            ? "The match ends for both of you, and \(opponentName) sees that you gave up."
            : "\(opponentName) sees that you left."
    }

    var exitButtonTitle: LocalizedStringKey {
        isInMatch ? "Give Up" : "Leave"
    }

    var stayButtonTitle: LocalizedStringKey {
        isInMatch ? "Keep Playing" : "Stay"
    }
}
#endif
