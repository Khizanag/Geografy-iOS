import Foundation

public struct QuizPackLevel: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let levelIndex: Int
    public let questionCount: Int
    public let countryCodes: [String]

    public init(
        id: String,
        name: String,
        levelIndex: Int,
        questionCount: Int,
        countryCodes: [String]
    ) {
        self.id = id
        self.name = name
        self.levelIndex = levelIndex
        self.questionCount = questionCount
        self.countryCodes = countryCodes
    }

    public static func == (lhs: QuizPackLevel, rhs: QuizPackLevel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
