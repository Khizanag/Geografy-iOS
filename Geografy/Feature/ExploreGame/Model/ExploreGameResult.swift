import Foundation
import Geografy_Core_Common

/// Captures the result of a completed Explore Game round.
struct ExploreGameResult: Identifiable, Hashable {
    let id = UUID()
    let country: Country
    let score: Int
    let cluesUsed: Int
    let wrongGuesses: Int
    let wasRevealed: Bool
}

// MARK: - Factory
extension ExploreGameResult {
    init(from state: ExploreGameState) {
        self.country = state.targetCountry
        self.score = state.finalScore
        self.cluesUsed = state.revealedClueCount
        self.wrongGuesses = state.wrongGuessCount
        self.wasRevealed = state.outcome == .revealed
    }
}
