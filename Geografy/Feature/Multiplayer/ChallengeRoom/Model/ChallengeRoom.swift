import Foundation

struct ChallengeRoom: Hashable {
    let player1Name: String
    let player2Name: String
    var player1Score: Int
    var player2Score: Int
    var currentPlayerIndex: Int
    var roundNumber: Int
    var totalRounds: Int
    var questions: [ChallengeQuestion]

    var currentPlayerName: String {
        currentPlayerIndex == 0 ? player1Name : player2Name
    }

    var otherPlayerName: String {
        currentPlayerIndex == 0 ? player2Name : player1Name
    }

    var isFinished: Bool {
        roundNumber > totalRounds
    }

    var currentQuestion: ChallengeQuestion? {
        let questionIndex = (roundNumber - 1) * 2 + currentPlayerIndex
        guard questionIndex < questions.count else { return nil }
        return questions[questionIndex]
    }
}
