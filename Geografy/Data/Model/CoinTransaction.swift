import Foundation

struct CoinTransaction: Identifiable, Codable, Equatable {
    let id: UUID
    let amount: Int
    let reason: CoinReason
    let date: Date
    let balanceAfter: Int
}

enum CoinReason: String, Codable, CaseIterable {
    // Earning
    case quizCompleted
    case dailyLogin
    case achievementUnlocked
    case levelUp
    case purchase

    // Spending
    case hintUsed
    case skipQuestion
    case unlockTheme
    case unlockMap
}

// MARK: - Display

extension CoinReason {
    var displayName: String {
        switch self {
        case .quizCompleted: "Quiz Completed"
        case .dailyLogin: "Daily Login"
        case .achievementUnlocked: "Achievement"
        case .levelUp: "Level Up"
        case .purchase: "Purchase"
        case .hintUsed: "Hint Used"
        case .skipQuestion: "Skip Question"
        case .unlockTheme: "Unlock Theme"
        case .unlockMap: "Unlock Map"
        }
    }

    var icon: String {
        switch self {
        case .quizCompleted: "checkmark.circle.fill"
        case .dailyLogin: "calendar.badge.checkmark"
        case .achievementUnlocked: "trophy.fill"
        case .levelUp: "arrow.up.circle.fill"
        case .purchase: "bag.fill"
        case .hintUsed: "lightbulb.fill"
        case .skipQuestion: "forward.fill"
        case .unlockTheme: "paintpalette.fill"
        case .unlockMap: "map.fill"
        }
    }

    var isEarning: Bool {
        switch self {
        case .quizCompleted, .dailyLogin, .achievementUnlocked, .levelUp, .purchase:
            true
        case .hintUsed, .skipQuestion, .unlockTheme, .unlockMap:
            false
        }
    }
}
