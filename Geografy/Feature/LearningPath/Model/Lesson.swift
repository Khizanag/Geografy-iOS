import Foundation

struct Lesson: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let type: LessonType
    let content: String
    var isCompleted: Bool

    enum LessonType: String, Codable {
        case reading
        case quiz
        case matching
    }
}
