import Geografy_Core_Common
#if !os(tvOS)
import Foundation

public enum PeerMessage: Codable {
    case playerInfo(name: String)
    /// The host's quiz settings, sent on joining and whenever the host changes them.
    case lobbySettings(config: MatchConfig)
    case lobbyReady
    case startMatch(config: MatchConfig, questions: [SerializableQuestion])
    /// A Pin Drop match: the countries to find, in order.
    case startPinDrop(config: MatchConfig, countryCodes: [String])
    case pinDropLocked(round: Int, points: Int)
    case answerSubmitted(questionIndex: Int, optionID: UUID, timeSpent: TimeInterval)
    case timedOut(questionIndex: Int)
    case advanceToNext(questionIndex: Int)
    case matchFinished(hostScore: Int, guestScore: Int)
    case rematchRequest
    case rematchAccepted
    case rematchDeclined
    case disconnecting
}

// MARK: - Match Config
extension PeerMessage {
    public struct MatchConfig: Codable {
        public let game: LocalGame
        public let pinDrop: PinDropConfiguration
        public let quizType: QuizType
        public let region: QuizRegion
        public let difficulty: QuizDifficulty
        public let questionCount: Int
        public let comparisonMetric: ComparisonMetric
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
