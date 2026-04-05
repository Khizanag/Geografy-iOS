import Foundation
import Geografy_Core_Common

/// Tracks the state of a single Explore Game round.
public struct ExploreGameState {
    public let targetCountry: Country
    public let clues: [ExploreClue]

    public private(set) var revealedClueCount: Int = 1
    public private(set) var wrongGuessCount: Int = 0
    public private(set) var guessHistory: [String] = []
    public private(set) var outcome: Outcome?

    public enum Outcome {
        case guessedCorrectly
        case revealed
    }

    public init(targetCountry: Country, clues: [ExploreClue]) {
        self.targetCountry = targetCountry
        self.clues = clues
    }
}

// MARK: - Computed Properties
extension ExploreGameState {
    public var currentPointsAvailable: Int {
        let clueIndex = min(revealedClueCount - 1, clues.count - 1)
        let base = clues[clueIndex].pointsAvailable
        let penalty = wrongGuessCount * 100
        return max(base - penalty, 0)
    }

    public var revealedClues: [ExploreClue] {
        Array(clues.prefix(revealedClueCount))
    }

    public var hasMoreClues: Bool {
        revealedClueCount < clues.count
    }

    public var isFinished: Bool {
        outcome != nil
    }

    public var finalScore: Int {
        guard outcome == .guessedCorrectly else { return 0 }
        return currentPointsAvailable
    }
}

// MARK: - Mutations
extension ExploreGameState {
    public mutating func revealNextClue() {
        guard hasMoreClues else { return }
        revealedClueCount += 1
    }

    @discardableResult
    public mutating func submitGuess(_ countryName: String) -> Bool {
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

    public mutating func revealAnswer() {
        outcome = .revealed
    }
}
