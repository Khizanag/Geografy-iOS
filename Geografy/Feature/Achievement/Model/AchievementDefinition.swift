import Foundation

struct AchievementDefinition: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let iconName: String
    let requirement: String
    let targetValue: Int
    let xpReward: Int
    let gameCenterID: String?
    let isSecret: Bool

    init(
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
