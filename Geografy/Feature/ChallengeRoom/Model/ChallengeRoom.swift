import Foundation

struct ChallengeRoom {
    let player1Name: String
    let player2Name: String
    var player1Score: Int
    var player2Score: Int
    var currentPlayerIndex: Int // 0 or 1
    var roundNumber: Int
    var totalRounds: Int // 5, 10, 15
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

struct ChallengeQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let category: String
}

enum ChallengeCategory: String, CaseIterable {
    case flags = "Flags"
    case capitals = "Capitals"
    case mixed = "Mixed"
}

enum ChallengeMode: String, CaseIterable {
    case passAndPlay = "Pass & Play"
    case splitScreen = "Split Screen"

    var icon: String {
        switch self {
        case .passAndPlay: "hand.point.right.fill"
        case .splitScreen: "rectangle.split.1x2.fill"
        }
    }

    var description: String {
        switch self {
        case .passAndPlay: "Take turns on one device"
        case .splitScreen: "Play simultaneously — screen split in half"
        }
    }
}
