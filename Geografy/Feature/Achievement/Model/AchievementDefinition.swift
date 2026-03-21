import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let xpReward: Int
    let gameCenterID: String
    let iconName: String
    let isSecret: Bool
}

enum AchievementCategory: String {
    case explorer
    case quizMaster
    case travelTracker
    case streak
    case knowledge
}
