/// A tab of the Quiz Library: themed packs or the user's own quizzes.
public enum QuizLibraryTab: String, CaseIterable, Hashable, Identifiable, Sendable {
    case packs
    case custom

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .packs: "Packs"
        case .custom: "My Quizzes"
        }
    }
}
