import Geografy_Core_Common
#if !os(tvOS)
import Foundation

public enum PeerMessage: Codable {
    case playerInfo(name: String)
    /// The host's quiz settings, sent on joining and whenever the host changes them.
    case lobbySettings(config: MatchConfig)
    case lobbyReady
    case startMatch(config: MatchConfig, questions: [SerializableQuestion])
    /// Any game but a quiz, with what the host picked for it.
    case startGame(config: MatchConfig, setup: LocalGameSetup)
    /// A round played in a game other than a quiz: a pin locked in, a puzzle answered, a word or country found.
    case roundScored(round: Int, points: Int)
    /// The sender has played every round.
    case finishedRounds
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
        /// Nil for the whole world.
        public let mapPuzzleContinent: Country.Continent?
        public let mapPuzzleQuestionCount: QuestionCount
        public let wordSearchTheme: WordSearchTheme
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
