import Foundation
import Geografy_Core_Common

public struct Lesson: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let type: LessonType
    public let content: String
    /// The quiz that completes a quiz or matching lesson; nil for reading.
    public let quiz: LessonQuiz?
    public var isCompleted: Bool

    public init(
        id: String,
        title: String,
        type: LessonType,
        content: String,
        quiz: LessonQuiz? = nil,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.content = content
        self.quiz = quiz
        self.isCompleted = isCompleted
    }

    public enum LessonType: String, Codable, Sendable {
        case reading
        case quiz
        case matching
    }
}
