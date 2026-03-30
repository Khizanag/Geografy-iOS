import Foundation

struct QuizResult: Identifiable, Hashable {
    let id = UUID()

    static func == (lhs: QuizResult, rhs: QuizResult) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let configuration: QuizConfiguration
    let answers: [QuizAnswer]
    let totalTime: TimeInterval
}

// MARK: - Computed Properties
extension QuizResult {
    var correctCount: Int {
        answers.filter(\.isCorrect).count
    }

    var incorrectCount: Int {
        answers.count - correctCount
    }

    var accuracy: Double {
        guard !answers.isEmpty else { return 0 }
        return Double(correctCount) / Double(answers.count)
    }
}

// MARK: - QuizAnswer
struct QuizAnswer: Identifiable {
    let id: UUID
    let question: QuizQuestion
    let selectedOptionID: UUID?
    let isCorrect: Bool
    let timeSpent: TimeInterval
}
