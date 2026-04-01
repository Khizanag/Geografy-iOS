import Foundation
import Geografy_Core_Common

/// Tracks the state of a single Explore Game round.
struct ExploreGameState {
    let targetCountry: Country
    let clues: [ExploreClue]

    private(set) var revealedClueCount: Int = 1
    private(set) var wrongGuessCount: Int = 0
    private(set) var guessHistory: [String] = []
    private(set) var outcome: Outcome?

    enum Outcome {
        case guessedCorrectly
        case revealed
    }
}

// MARK: - Computed Properties
extension ExploreGameState {
    var currentPointsAvailable: Int {
        let clueIndex = min(revealedClueCount - 1, clues.count - 1)
        let base = clues[clueIndex].pointsAvailable
        let penalty = wrongGuessCount * 100
        return max(base - penalty, 0)
    }

    var revealedClues: [ExploreClue] {
        Array(clues.prefix(revealedClueCount))
    }

    var hasMoreClues: Bool {
        revealedClueCount < clues.count
    }

    var isFinished: Bool {
        outcome != nil
    }

    var finalScore: Int {
        guard outcome == .guessedCorrectly else { return 0 }
        return currentPointsAvailable
    }
}

// MARK: - Mutations
extension ExploreGameState {
    mutating func revealNextClue() {
        guard hasMoreClues else { return }
        revealedClueCount += 1
    }

    mutating func submitGuess(_ countryName: String) -> Bool {
        guessHistory.append(countryName)

        let isCorrect = countryName.lowercased()
            == targetCountry.name.lowercased()

        if isCorrect {
            outcome = .guessedCorrectly
        } else {
            wrongGuessCount += 1
        }

        return isCorrect
    }

    mutating func revealAnswer() {
        outcome = .revealed
    }
}
