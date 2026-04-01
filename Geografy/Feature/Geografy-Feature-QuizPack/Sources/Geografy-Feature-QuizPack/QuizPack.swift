import SwiftUI

public struct QuizPack: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
    public let category: QuizPackCategory
    public let levels: [QuizPackLevel]
    public let gradientColors: (Color, Color)
    public let isPremium: Bool
    public let prerequisitePackID: String?

    public static func == (lhs: QuizPack, rhs: QuizPack) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Computed Properties
extension QuizPack {
    public var totalQuestions: Int {
        levels.reduce(0) { $0 + $1.questionCount }
    }

    public var levelCount: Int {
        levels.count
    }
}
