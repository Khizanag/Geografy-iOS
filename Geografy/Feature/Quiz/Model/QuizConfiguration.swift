import Foundation

struct QuizConfiguration {
    let type: QuizType
    let region: QuizRegion
    let difficulty: QuizDifficulty
    let questionCount: QuestionCount
}

// MARK: - QuestionCount

enum QuestionCount: Int, CaseIterable, Identifiable {
    case ten = 10
    case twenty = 20
    case fifty = 50

    var id: Int { rawValue }

    var displayName: String {
        "\(rawValue)"
    }
}
