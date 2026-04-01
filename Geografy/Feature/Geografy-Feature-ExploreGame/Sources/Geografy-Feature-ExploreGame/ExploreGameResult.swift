import Foundation
import Geografy_Core_Common

/// Captures the result of a completed Explore Game round.
public struct ExploreGameResult: Identifiable, Hashable {
    public let id = UUID()
    public let country: Country
    public let score: Int
    public let cluesUsed: Int
    public let wrongGuesses: Int
    public let wasRevealed: Bool
}

// MARK: - Factory
extension ExploreGameResult {
    public init(from state: ExploreGameState) {
        self.country = state.targetCountry
        self.score = state.finalScore
        self.cluesUsed = state.revealedClueCount
        self.wrongGuesses = state.wrongGuessCount
        self.wasRevealed = state.outcome == .revealed
    }
}
