import Foundation
import Geografy_Feature_Quiz

public struct MultiplayerRound: Identifiable {
    public let id: UUID
    public let questionIndex: Int
    public let question: QuizQuestion
    public let playerAnswer: PlayerAnswer?
    public let opponentAnswer: PlayerAnswer?
}

// MARK: - PlayerAnswer
public struct PlayerAnswer: Identifiable {
    public let id: UUID
    public let selectedOptionID: UUID?
    public let isCorrect: Bool
    public let timeSpent: TimeInterval
}

// MARK: - Computed Properties
extension MultiplayerRound {
    public var playerWonRound: Bool {
        guard let player = playerAnswer else { return false }
        guard let opponent = opponentAnswer else { return player.isCorrect }

        if player.isCorrect, !opponent.isCorrect { return true }
        if !player.isCorrect, opponent.isCorrect { return false }
        if player.isCorrect, opponent.isCorrect {
            return player.timeSpent < opponent.timeSpent
        }
        return false
    }

    public var opponentWonRound: Bool {
        guard let opponent = opponentAnswer else { return false }
        guard let player = playerAnswer else { return opponent.isCorrect }

        if opponent.isCorrect, !player.isCorrect { return true }
        if !opponent.isCorrect, player.isCorrect { return false }
        if opponent.isCorrect, player.isCorrect {
            return opponent.timeSpent < player.timeSpent
        }
        return false
    }

    public var isDraw: Bool {
        !playerWonRound && !opponentWonRound
    }
}
