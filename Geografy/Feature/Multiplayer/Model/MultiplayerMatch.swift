import Foundation

struct MultiplayerMatch: Identifiable, Hashable {
    let id: UUID
    let opponent: MockOpponent
    let configuration: QuizConfiguration
    let rounds: [MultiplayerRound]
    let date: Date
    let playerRatingChange: Int
    let opponentRatingChange: Int

    static func == (lhs: MultiplayerMatch, rhs: MultiplayerMatch) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Computed Properties
extension MultiplayerMatch {
    var playerScore: Int {
        rounds.filter(\.playerWonRound).count
    }

    var opponentScore: Int {
        rounds.filter(\.opponentWonRound).count
    }

    var playerWon: Bool {
        playerScore > opponentScore
    }

    var opponentWon: Bool {
        opponentScore > playerScore
    }

    var isDraw: Bool {
        playerScore == opponentScore
    }

    var resultLabel: String {
        if playerWon {
            "Victory"
        } else if opponentWon {
            "Defeat"
        } else {
            "Draw"
        }
    }

    var totalQuestions: Int {
        rounds.count
    }

    var playerCorrectCount: Int {
        rounds.compactMap(\.playerAnswer).filter(\.isCorrect).count
    }

    var opponentCorrectCount: Int {
        rounds.compactMap(\.opponentAnswer).filter(\.isCorrect).count
    }
}
