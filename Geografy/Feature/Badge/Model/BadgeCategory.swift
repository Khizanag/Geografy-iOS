import SwiftUI

enum BadgeCategory: String, CaseIterable, Codable {
    case explorer
    case quizMaster
    case streakWarrior
    case continentalExpert
    case flashcardScholar
    case speedDemon
    case perfectScore
    case earlyBird
    case nightOwl
    case socialButterfly
}

// MARK: - Display Properties

extension BadgeCategory {
    var displayName: String {
        switch self {
        case .explorer:           "Explorer"
        case .quizMaster:         "Quiz Master"
        case .streakWarrior:      "Streak Warrior"
        case .continentalExpert:  "Continental Expert"
        case .flashcardScholar:   "Flashcard Scholar"
        case .speedDemon:         "Speed Demon"
        case .perfectScore:       "Perfect Score"
        case .earlyBird:          "Early Bird"
        case .nightOwl:           "Night Owl"
        case .socialButterfly:    "Social Butterfly"
        }
    }

    var iconName: String {
        switch self {
        case .explorer:           "globe"
        case .quizMaster:         "brain.fill"
        case .streakWarrior:      "flame.fill"
        case .continentalExpert:  "map.fill"
        case .flashcardScholar:   "rectangle.on.rectangle.angled"
        case .speedDemon:         "bolt.fill"
        case .perfectScore:       "checkmark.seal.fill"
        case .earlyBird:          "sunrise.fill"
        case .nightOwl:           "moon.stars.fill"
        case .socialButterfly:    "person.2.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .explorer:           DesignSystem.Color.blue
        case .quizMaster:         DesignSystem.Color.purple
        case .streakWarrior:      DesignSystem.Color.error
        case .continentalExpert:  DesignSystem.Color.ocean
        case .flashcardScholar:   DesignSystem.Color.indigo
        case .speedDemon:         DesignSystem.Color.orange
        case .perfectScore:       DesignSystem.Color.success
        case .earlyBird:          DesignSystem.Color.warning
        case .nightOwl:           DesignSystem.Color.purple
        case .socialButterfly:    DesignSystem.Color.accent
        }
    }
}
