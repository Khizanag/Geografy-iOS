import Foundation

/// When a quiz moves on to the next question after an answer. Waiting leaves the answer on screen, with a way to
/// read about the country, until the player taps Next.
public enum QuizAnswerAdvance: String, CaseIterable, Identifiable, Codable, Sendable {
    case always
    case afterCorrect
    case never

    /// Remembered across quizzes, so every way into a quiz follows the same choice.
    public static let storageKey = "quiz_answerAdvance"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .always: "Auto"
        case .afterCorrect: "If Right"
        case .never: "On Tap"
        }
    }

    public var description: String {
        switch self {
        case .always: "Moves on a moment after every answer."
        case .afterCorrect: "Moves on after a right answer, and waits on a wrong one so you can see why."
        case .never: "Waits on every answer until you tap Next."
        }
    }

    /// Whether the quiz moves on by itself after an answer that was right or wrong.
    public func movesOn(afterCorrectAnswer isCorrect: Bool) -> Bool {
        switch self {
        case .always: true
        case .afterCorrect: isCorrect
        case .never: false
        }
    }
}
