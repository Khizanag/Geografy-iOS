import Foundation

public struct Lesson: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let type: LessonType
    public let content: String
    public var isCompleted: Bool

    public init(
        id: String,
        title: String,
        type: LessonType,
        content: String,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.content = content
        self.isCompleted = isCompleted
    }

    public enum LessonType: String, Codable, Sendable {
        case reading
        case quiz
        case matching
    }
}
