import SwiftUI

enum AchievementCategory: String, CaseIterable, Codable {
    case explorer
    case quizMaster
    case streak
    case continental
    case flashcard
    case speed
    case perfectScore
    case travel
    case knowledge
    case social
}

// MARK: - Display

extension AchievementCategory {
    var displayName: String {
        switch self {
        case .explorer: "Explorer"
        case .quizMaster: "Quiz Master"
        case .streak: "Streak"
        case .continental: "Continental"
        case .flashcard: "Flashcard"
        case .speed: "Speed"
        case .perfectScore: "Perfect Score"
        case .travel: "Travel"
        case .knowledge: "Knowledge"
        case .social: "Social"
        }
    }

    var iconName: String {
        switch self {
        case .explorer: "globe"
        case .quizMaster: "brain.fill"
        case .streak: "flame.fill"
        case .continental: "map.fill"
        case .flashcard: "rectangle.on.rectangle.angled"
        case .speed: "bolt.fill"
        case .perfectScore: "checkmark.seal.fill"
        case .travel: "airplane.departure"
        case .knowledge: "book.fill"
        case .social: "person.2.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .explorer: DesignSystem.Color.blue
        case .quizMaster: DesignSystem.Color.purple
        case .streak: DesignSystem.Color.error
        case .continental: DesignSystem.Color.ocean
        case .flashcard: DesignSystem.Color.indigo
        case .speed: DesignSystem.Color.orange
        case .perfectScore: DesignSystem.Color.success
        case .travel: DesignSystem.Color.accent
        case .knowledge: DesignSystem.Color.warning
        case .social: DesignSystem.Color.accent
        }
    }
}
