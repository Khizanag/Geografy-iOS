import Foundation
import SwiftData

@Model
public final class UserProfile {
    public var id: String
    public var displayName: String
    public var email: String?
    public var isGuest: Bool
    public var createdAt: Date
    public var lastLoginAt: Date
    public var currentStreak: Int
    public var longestStreak: Int

    public init(
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
