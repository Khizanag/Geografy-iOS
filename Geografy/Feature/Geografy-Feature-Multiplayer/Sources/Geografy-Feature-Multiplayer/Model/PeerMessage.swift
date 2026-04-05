import Geografy_Core_Common
#if !os(tvOS)
import Foundation

public enum PeerMessage: Codable {
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
    public struct MatchConfig: Codable {
        public let quizType: QuizType
        public let region: QuizRegion
        public let difficulty: QuizDifficulty
        public let questionCount: Int
    }
}

// MARK: - Encoding
extension PeerMessage {
    public func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }

    public static func decode(from data: Data) throws -> PeerMessage {
        try JSONDecoder().decode(PeerMessage.self, from: data)
    }
}
#endif
