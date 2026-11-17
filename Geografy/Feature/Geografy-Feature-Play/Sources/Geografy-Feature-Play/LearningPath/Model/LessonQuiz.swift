import Foundation
import Geografy_Core_Common

/// The quiz a quiz lesson runs, and what it takes to pass.
public struct LessonQuiz: Hashable, Codable, Sendable {
    /// The share of right answers that completes the lesson.
    public static let passingAccuracy = 0.8

    public let type: QuizType
    /// Where the questions come from; more than one combines them, as the Americas do.
    public let regions: [QuizRegion]
    /// Exact countries instead of whole regions, such as island nations.
    public let countryCodes: [String]?
    public let questionCount: QuestionCount

    public init(
        _ type: QuizType,
        regions: [QuizRegion] = [.world],
        countryCodes: [String]? = nil,
        questionCount: QuestionCount = .ten
    ) {
        self.type = type
        self.regions = regions
        self.countryCodes = countryCodes
        self.questionCount = questionCount
    }

    public static func passes(accuracy: Double) -> Bool {
        accuracy >= passingAccuracy
    }

    /// A fresh quiz each time, from `countries` when the lesson spans several regions.
    func configuration(countries: [Country]) -> QuizConfiguration {
        let codes = countryCodes ?? (regions.count > 1
            ? regions.flatMap { $0.filter(countries) }.map(\.code)
            : nil)
        return QuizConfiguration(
            type: type,
            region: regions.count == 1 ? regions[0] : .world,
            difficulty: .easy,
            questionCount: questionCount,
            answerMode: .multipleChoice,
            comparisonMetric: .population,
            gameMode: .standard,
            countryCodes: codes
        )
    }
}
