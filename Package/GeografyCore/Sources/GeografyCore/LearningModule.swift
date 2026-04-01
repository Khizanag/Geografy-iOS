import Foundation

public struct LearningModule: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String
    public var lessons: [Lesson]
    public var isUnlocked: Bool

    public init(
        id: String,
        title: String,
        description: String,
        icon: String,
        lessons: [Lesson],
        isUnlocked: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.lessons = lessons
        self.isUnlocked = isUnlocked
    }

    public var completedCount: Int {
        lessons.filter { $0.isCompleted }.count
    }

    public var totalCount: Int {
        lessons.count
    }

    public var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    public var isCompleted: Bool {
        totalCount > 0 && completedCount == totalCount
    }
}
