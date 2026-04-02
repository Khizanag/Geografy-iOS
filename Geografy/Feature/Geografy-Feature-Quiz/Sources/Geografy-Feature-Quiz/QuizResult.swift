import Foundation
import Geografy_Core_Common

public struct QuizResult: Identifiable, Hashable {
    public let id = UUID()

    public static func == (lhs: QuizResult, rhs: QuizResult) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public let configuration: QuizConfiguration
    public let answers: [QuizAnswer]
    public let totalTime: TimeInterval
}

// MARK: - Computed Properties
extension QuizResult {
    public var correctCount: Int {
        answers.filter(\.isCorrect).count
    }

    public var incorrectCount: Int {
        answers.count - correctCount
    }

    public var accuracy: Double {
        guard !answers.isEmpty else { return 0 }
        return Double(correctCount) / Double(answers.count)
    }
}

// MARK: - QuizAnswer
public struct QuizAnswer: Identifiable {
    public let id: UUID
    public let question: QuizQuestion
    public let selectedOptionID: UUID?
    public let isCorrect: Bool
    public let timeSpent: TimeInterval
}
