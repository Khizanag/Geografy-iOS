import Foundation

public struct QuizPackProgress: Codable {
    public let levelID: String
    public let stars: Int
    public let bestAccuracy: Double
    public let completedAt: Date

    public init(
        levelID: String,
        stars: Int,
        bestAccuracy: Double,
        completedAt: Date
    ) {
        self.levelID = levelID
        self.stars = stars
        self.bestAccuracy = bestAccuracy
        self.completedAt = completedAt
    }
}

// MARK: - Star Rating
extension QuizPackProgress {
    public static func starRating(for accuracy: Double) -> Int {
        switch accuracy {
        case 0.9...: 3
        case 0.7...: 2
        case 0.5...: 1
        default: 0
        }
    }
}
