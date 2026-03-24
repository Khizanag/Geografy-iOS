import Foundation

enum QuizAnswerMode: String, CaseIterable, Identifiable, Codable {
    case multipleChoice
    case typing
    case spellingBee

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .multipleChoice: "Multiple Choice"
        case .typing: "Typing"
        case .spellingBee: "Spelling Bee"
        }
    }

    var icon: String {
        switch self {
        case .multipleChoice: "list.bullet"
        case .typing: "keyboard"
        case .spellingBee: "textformat.abc"
        }
    }
}
