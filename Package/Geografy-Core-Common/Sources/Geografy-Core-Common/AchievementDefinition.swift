import Foundation

public struct AchievementDefinition: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let category: AchievementCategory
    public let rarity: AchievementRarity
    public let iconName: String
    public let requirement: String
    public let targetValue: Int
    public let xpReward: Int
    public let gameCenterID: String?
    public let isSecret: Bool

    public init(
        id: String,
        title: String,
        description: String,
        category: AchievementCategory,
        rarity: AchievementRarity = .common,
        iconName: String,
        requirement: String = "",
        targetValue: Int = 1,
        xpReward: Int = 0,
        gameCenterID: String? = nil,
        isSecret: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.rarity = rarity
        self.iconName = iconName
        self.requirement = requirement.isEmpty ? description : requirement
        self.targetValue = targetValue
        self.xpReward = xpReward
        self.gameCenterID = gameCenterID
        self.isSecret = isSecret
    }
}
