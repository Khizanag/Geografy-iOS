import Foundation

public enum QuizAnswerMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case multipleChoice
    case typing
    case spellingBee

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .multipleChoice: "Multiple Choice"
        case .typing: "Typing"
        case .spellingBee: "Spelling Bee"
        }
    }

    public var icon: String {
        switch self {
        case .multipleChoice: "list.bullet"
        case .typing: "keyboard"
        case .spellingBee: "textformat.abc"
        }
    }
}
