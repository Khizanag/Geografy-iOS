import GameKit
import SwiftUI

@available(iOS, deprecated: 26.0, message: "Migrate to native GameCenter UI when available")
struct GameCenterViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var leaderboardID: String? = nil

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let vc: GKGameCenterViewController
        if let id = leaderboardID {
            vc = GKGameCenterViewController(leaderboardID: id, playerScope: .global, timeScope: .allTime)
        } else {
            vc = GKGameCenterViewController(state: .default)
        }
        vc.gameCenterDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        @Binding var isPresented: Bool

        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            isPresented = false
        }
    }
}
