import Foundation

struct QuizPackLevel: Identifiable, Hashable {
    let id: String
    let name: String
    let questionCount: Int
    let countryCodes: [String]

    static func == (lhs: QuizPackLevel, rhs: QuizPackLevel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
