import Foundation

enum QuizAnswerMode: String, CaseIterable, Identifiable, Codable {
    case multipleChoice
    case typing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .multipleChoice: "Multiple Choice"
        case .typing: "Typing"
        }
    }

    var icon: String {
        switch self {
        case .multipleChoice: "list.bullet"
        case .typing: "keyboard"
        }
    }
}
