import Foundation

enum PeerMessage: Codable {
    case playerInfo(name: String)
    case lobbyReady
    case startMatch(config: MatchConfig, questions: [SerializableQuestion])
    case answerSubmitted(questionIndex: Int, optionID: UUID, timeSpent: TimeInterval)
    case timedOut(questionIndex: Int)
    case advanceToNext(questionIndex: Int)
    case matchFinished(hostScore: Int, guestScore: Int)
    case rematchRequest
    case rematchAccepted
    case disconnecting
}

// MARK: - Match Config
extension PeerMessage {
    struct MatchConfig: Codable {
        let quizType: QuizType
        let region: QuizRegion
        let difficulty: QuizDifficulty
        let questionCount: Int
    }
}

// MARK: - Encoding
extension PeerMessage {
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }

    static func decode(from data: Data) throws -> PeerMessage {
        try JSONDecoder().decode(PeerMessage.self, from: data)
    }
}
