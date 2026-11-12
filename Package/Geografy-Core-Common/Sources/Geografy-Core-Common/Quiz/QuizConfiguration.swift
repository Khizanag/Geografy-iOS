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

    public init(
        id: UUID = UUID(),
        type: QuizType,
        region: QuizRegion,
        difficulty: QuizDifficulty,
        questionCount: QuestionCount,
        answerMode: QuizAnswerMode,
        comparisonMetric: ComparisonMetric,
        gameMode: QuizGameMode,
        arcadeTimer: ArcadeTimer = .sixty
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
