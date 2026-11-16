import Geografy_Core_DesignSystem
import SwiftUI
import UIKit

/// The signed-out state for every Game Center screen.
///
/// GameKit shows its sign-in sheet only once per launch, so the way back in is the Settings app.
struct GameCenterSignInPrompt: View {
    // MARK: - Properties
    @Environment(\.openURL) private var openURL

    let message: LocalizedStringKey

    // MARK: - Body
    var body: some View {
        EmptyStateView(
            icon: "gamecontroller.fill",
            title: "Sign in to Game Center",
            message: message,
            actionTitle: "Open Settings",
            action: openSettings
        )
    }
}

// MARK: - Actions
private extension GameCenterSignInPrompt {
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
