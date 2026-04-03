import Foundation

public enum AchievementCategory: String, CaseIterable, Codable, Sendable {
    case explorer
    case quizExpert
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
    public var displayName: String {
        switch self {
        case .explorer: "Explorer"
        case .quizExpert: "Quiz Master"
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

    public var iconName: String {
        switch self {
        case .explorer: "globe"
        case .quizExpert: "brain.fill"
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
}
