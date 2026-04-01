import Foundation

public struct QuizPackLevel: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let questionCount: Int
    public let countryCodes: [String]

    public static func == (lhs: QuizPackLevel, rhs: QuizPackLevel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
