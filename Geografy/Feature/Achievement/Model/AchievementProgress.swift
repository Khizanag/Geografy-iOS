import Foundation

struct AchievementProgress: Codable, Hashable {
    let achievementID: String
    var currentValue: Int
    var isUnlocked: Bool
    var unlockedAt: Date?

    var targetValue: Int = 1

    var fraction: CGFloat {
        guard targetValue > 0 else { return 0 }
        return min(1, CGFloat(currentValue) / CGFloat(targetValue))
    }

    var isComplete: Bool {
        currentValue >= targetValue
    }
}
