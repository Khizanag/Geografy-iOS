import Foundation

public struct AchievementProgress: Codable, Hashable {
    public let achievementID: String
    public var currentValue: Int
    public var isUnlocked: Bool
    public var unlockedAt: Date?

    public var targetValue: Int = 1

    public init(
        achievementID: String,
        currentValue: Int,
        isUnlocked: Bool,
        unlockedAt: Date? = nil,
        targetValue: Int = 1
    ) {
        self.achievementID = achievementID
        self.currentValue = currentValue
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.targetValue = targetValue
    }

    public var fraction: CGFloat {
        guard targetValue > 0 else { return 0 }
        return min(1, CGFloat(currentValue) / CGFloat(targetValue))
    }

    public var isComplete: Bool {
        currentValue >= targetValue
    }
}
