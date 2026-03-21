import Foundation

/// A single progressive clue revealed during an Explore Game round.
struct ExploreClue: Identifiable {
    let id = UUID()
    let index: Int
    let icon: String
    let title: String
    let detail: String
}

// MARK: - Scoring

extension ExploreClue {
    /// Points awarded for a correct guess after revealing this clue.
    var pointsAvailable: Int {
        switch index {
        case 0: 1000
        case 1: 800
        case 2: 600
        case 3: 400
        case 4: 200
        default: 100
        }
    }
}
