import SwiftUI

public struct QuizPack: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
    public let category: QuizPackCategory
    public let levels: [QuizPackLevel]
    public let gradientHex: (String, String)
    public let isPremium: Bool
    public let prerequisitePackID: String?

    public init(
        id: String,
        name: String,
        description: String,
        icon: String,
        category: QuizPackCategory,
        levels: [QuizPackLevel],
        gradientHex: (String, String),
        isPremium: Bool,
        prerequisitePackID: String?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.levels = levels
        self.gradientHex = gradientHex
        self.isPremium = isPremium
        self.prerequisitePackID = prerequisitePackID
    }

    public static func == (lhs: QuizPack, rhs: QuizPack) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Computed Properties
extension QuizPack {
    public var gradientColors: (Color, Color) {
        (Color(hex: gradientHex.0), Color(hex: gradientHex.1))
    }

    public var totalQuestions: Int {
        levels.reduce(0) { $0 + $1.questionCount }
    }

    public var levelCount: Int {
        levels.count
    }
}
