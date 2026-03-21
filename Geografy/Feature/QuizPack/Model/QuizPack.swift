import SwiftUI

struct QuizPack: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: QuizPackCategory
    let levels: [QuizPackLevel]
    let gradientColors: (Color, Color)
    let isPremium: Bool
    let prerequisitePackID: String?

    static func == (lhs: QuizPack, rhs: QuizPack) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Computed Properties

extension QuizPack {
    var totalQuestions: Int {
        levels.reduce(0) { $0 + $1.questionCount }
    }

    var levelCount: Int {
        levels.count
    }
}
