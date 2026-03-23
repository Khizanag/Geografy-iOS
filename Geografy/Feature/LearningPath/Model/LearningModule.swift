import Foundation

struct LearningModule: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var lessons: [Lesson]
    var isUnlocked: Bool

    var completedCount: Int {
        lessons.filter { $0.isCompleted }.count
    }

    var totalCount: Int {
        lessons.count
    }

    var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var isCompleted: Bool {
        totalCount > 0 && completedCount == totalCount
    }
}
