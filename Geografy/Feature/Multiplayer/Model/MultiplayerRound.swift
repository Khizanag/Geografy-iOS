import Foundation

struct MultiplayerRound: Identifiable {
    let id: UUID
    let questionIndex: Int
    let question: QuizQuestion
    let playerAnswer: PlayerAnswer?
    let opponentAnswer: PlayerAnswer?
}

// MARK: - PlayerAnswer
struct PlayerAnswer: Identifiable {
    let id: UUID
    let selectedOptionID: UUID?
    let isCorrect: Bool
    let timeSpent: TimeInterval
}

// MARK: - Computed Properties
extension MultiplayerRound {
    var playerWonRound: Bool {
        guard let player = playerAnswer else { return false }
        guard let opponent = opponentAnswer else { return player.isCorrect }

        if player.isCorrect, !opponent.isCorrect { return true }
        if !player.isCorrect, opponent.isCorrect { return false }
        if player.isCorrect, opponent.isCorrect {
            return player.timeSpent < opponent.timeSpent
        }
        return false
    }

    var opponentWonRound: Bool {
        guard let opponent = opponentAnswer else { return false }
        guard let player = playerAnswer else { return opponent.isCorrect }

        if opponent.isCorrect, !player.isCorrect { return true }
        if !opponent.isCorrect, player.isCorrect { return false }
        if opponent.isCorrect, player.isCorrect {
            return opponent.timeSpent < player.timeSpent
        }
        return false
    }

    var isDraw: Bool {
        !playerWonRound && !opponentWonRound
    }
}
