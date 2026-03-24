import SwiftUI

enum Destination: Hashable {
    case challengeResult(ChallengeRoom)
}

// MARK: - Content

extension Destination {
    @ViewBuilder
    var content: some View {
        switch self {
        case .challengeResult(let room):
            ChallengeResultScreen(room: room)
        }
    }
}
