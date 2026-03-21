import Foundation

struct QuizPackProgress: Codable {
    let levelID: String
    let stars: Int
    let bestAccuracy: Double
    let completedAt: Date
}

// MARK: - Star Rating

extension QuizPackProgress {
    static func starRating(for accuracy: Double) -> Int {
        switch accuracy {
        case 0.9...: 3
        case 0.7...: 2
        case 0.5...: 1
        default: 0
        }
    }
}
