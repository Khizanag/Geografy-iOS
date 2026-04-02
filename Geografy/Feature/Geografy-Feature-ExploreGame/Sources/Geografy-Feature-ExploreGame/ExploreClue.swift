import Foundation

/// A single progressive clue revealed during an Explore Game round.
public struct ExploreClue: Identifiable {
    public let id = UUID()
    public let index: Int
    public let icon: String
    public let title: String
    public let detail: String
}

// MARK: - Scoring
extension ExploreClue {
    /// Points awarded for a correct guess after revealing this clue.
    public var pointsAvailable: Int {
        switch index {
        case 0: 1_000
        case 1: 800
        case 2: 600
        case 3: 400
        case 4: 200
        default: 100
        }
    }
}
