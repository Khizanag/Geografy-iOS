import Foundation
import Geografy_Core_Common

public struct MultiplayerMatch: Identifiable, Hashable {
    public let id: UUID
    public let opponent: MockOpponent
    public let configuration: QuizConfiguration
    public let rounds: [MultiplayerRound]
    public let date: Date
    public let playerRatingChange: Int
    public let opponentRatingChange: Int

    public static func == (lhs: MultiplayerMatch, rhs: MultiplayerMatch) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Computed Properties
extension MultiplayerMatch {
    public var playerScore: Int {
        rounds.filter(\.playerWonRound).count
    }

    public var opponentScore: Int {
        rounds.filter(\.opponentWonRound).count
    }

    public var playerWon: Bool {
        playerScore > opponentScore
    }

    public var opponentWon: Bool {
        opponentScore > playerScore
    }

    public var isDraw: Bool {
        playerScore == opponentScore
    }

    public var resultLabel: String {
        if playerWon {
            "Victory"
        } else if opponentWon {
            "Defeat"
        } else {
            "Draw"
        }
    }

    public var totalQuestions: Int {
        rounds.count
    }

    public var playerCorrectCount: Int {
        rounds.compactMap(\.playerAnswer).filter(\.isCorrect).count
    }

    public var opponentCorrectCount: Int {
        rounds.compactMap(\.opponentAnswer).filter(\.isCorrect).count
    }
}
