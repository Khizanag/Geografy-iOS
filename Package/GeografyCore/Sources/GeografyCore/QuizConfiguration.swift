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

    public init(
        id: UUID = UUID(),
        type: QuizType,
        region: QuizRegion,
        difficulty: QuizDifficulty,
        questionCount: QuestionCount,
        answerMode: QuizAnswerMode,
        comparisonMetric: ComparisonMetric,
        gameMode: QuizGameMode
    ) {
        self.id = id
        self.type = type
        self.region = region
        self.difficulty = difficulty
        self.questionCount = questionCount
        self.answerMode = answerMode
        self.comparisonMetric = comparisonMetric
        self.gameMode = gameMode
    }
}

// MARK: - QuestionCount
public enum QuestionCount: Int, CaseIterable, Identifiable, Sendable {
    case five = 5
    case ten = 10
    case twenty = 20
    case thirty = 30
    case fifty = 50

    public var id: Int { rawValue }

    public var displayName: String {
        "\(rawValue)"
    }
}

// MARK: - ComparisonMetric
public enum ComparisonMetric: String, CaseIterable, Identifiable, Codable, Sendable {
    case population = "Population"
    case area = "Area"
    case gdpPerCapita = "GDP per Capita"
    case populationDensity = "Density"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .population: "person.3.fill"
        case .area: "map.fill"
        case .gdpPerCapita: "dollarsign.circle.fill"
        case .populationDensity: "person.crop.square"
        }
    }

    public var questionText: String {
        switch self {
        case .population: "Which country has the largest population?"
        case .area: "Which country has the largest area?"
        case .gdpPerCapita: "Which country has the highest GDP per capita?"
        case .populationDensity: "Which country has the highest population density?"
        }
    }

    public func value(for country: Country) -> Double {
        switch self {
        case .population: Double(country.population)
        case .area: country.area
        case .gdpPerCapita: country.gdpPerCapita ?? 0
        case .populationDensity: country.populationDensity
        }
    }
}

// MARK: - QuizGameMode
public enum QuizGameMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case standard = "Standard"
    case arcade = "Arcade"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .standard: "list.number"
        case .arcade: "bolt.fill"
        }
    }

    public var description: String {
        switch self {
        case .standard: "Fixed questions, your pace"
        case .arcade: "60s timer, 3 lives, endless questions"
        }
    }
}
