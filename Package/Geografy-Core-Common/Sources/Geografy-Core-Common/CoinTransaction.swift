import Foundation

public struct CoinTransaction: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let amount: Int
    public let reason: CoinReason
    public let date: Date
    public let balanceAfter: Int

    public init(id: UUID, amount: Int, reason: CoinReason, date: Date, balanceAfter: Int) {
        self.id = id
        self.amount = amount
        self.reason = reason
        self.date = date
        self.balanceAfter = balanceAfter
    }
}

public enum CoinReason: String, Codable, CaseIterable, Sendable {
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
public extension CoinReason {
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
