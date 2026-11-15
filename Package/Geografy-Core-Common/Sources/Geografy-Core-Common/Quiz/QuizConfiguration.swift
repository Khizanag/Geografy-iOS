import Foundation

public struct QuizConfiguration: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let type: QuizType
    public let region: QuizRegion
    public let difficulty: QuizDifficulty
    public let questionCount: QuestionCount
    public let answerMode: QuizAnswerMode
    public let comparisonMetric: ComparisonMetric
    public let gameMode: QuizGameMode
    public let arcadeTimer: ArcadeTimer
    /// When set, questions come from these countries only, as a quiz pack level asks; otherwise from `region`.
    public let countryCodes: [String]?

    public init(
        id: UUID = UUID(),
        type: QuizType,
        region: QuizRegion,
        difficulty: QuizDifficulty,
        questionCount: QuestionCount,
        answerMode: QuizAnswerMode,
        comparisonMetric: ComparisonMetric,
        gameMode: QuizGameMode,
        arcadeTimer: ArcadeTimer = .sixty,
        countryCodes: [String]? = nil
    ) {
        self.id = id
        self.type = type
        self.region = region
        self.difficulty = difficulty
        self.questionCount = questionCount
        self.answerMode = answerMode
        self.comparisonMetric = comparisonMetric
        self.gameMode = gameMode
        self.arcadeTimer = arcadeTimer
        self.countryCodes = countryCodes
    }
}

// MARK: - Quick Play
public extension QuizConfiguration {
    /// Ten world questions with no timer, for one-tap entry points that skip setup.
    static func quickPlay(_ type: QuizType) -> QuizConfiguration {
        QuizConfiguration(
            type: type,
            region: .world,
            difficulty: .easy,
            questionCount: .ten,
            answerMode: .multipleChoice,
            comparisonMetric: .population,
            gameMode: .standard
        )
    }
}

// MARK: - Finishing
public extension QuizConfiguration {
    /// Posted when a quiz session ends, with the configuration's `id` as the object and the share of
    /// correct answers, from 0 to 1, under `accuracyKey`; screens that started a quiz record its result from it.
    static let finishedNotification = Notification.Name("QuizConfiguration.finished")
    static let accuracyKey = "accuracy"

    func announceFinished(accuracy: Double) {
        NotificationCenter.default.post(
            name: Self.finishedNotification,
            object: id,
            userInfo: [Self.accuracyKey: accuracy]
        )
    }
}
