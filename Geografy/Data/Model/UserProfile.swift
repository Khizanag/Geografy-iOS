import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: String
    var displayName: String
    var email: String?
    var isGuest: Bool
    var createdAt: Date
    var lastLoginAt: Date
    var currentStreak: Int
    var longestStreak: Int

    init(
        id: String,
        displayName: String,
        email: String? = nil,
        isGuest: Bool,
        createdAt: Date = .now,
        lastLoginAt: Date = .now,
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.isGuest = isGuest
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}
