import Foundation

public struct UserLevel: Equatable, Sendable {
    public let level: Int
    public let title: String
    public let minXP: Int
    public let maxXP: Int

    public init(level: Int, title: String, minXP: Int, maxXP: Int) {
        self.level = level
        self.title = title
        self.minXP = minXP
        self.maxXP = maxXP
    }
}

// MARK: - Thresholds
public extension UserLevel {
    nonisolated(unsafe) static let thresholds: [UserLevel] = [
        UserLevel(level: 1, title: "Explorer", minXP: 0, maxXP: 100),
        UserLevel(level: 2, title: "Traveler", minXP: 100, maxXP: 300),
        UserLevel(level: 3, title: "Adventurer", minXP: 300, maxXP: 700),
        UserLevel(level: 4, title: "Geographer", minXP: 700, maxXP: 1_500),
        UserLevel(level: 5, title: "Cartographer", minXP: 1_500, maxXP: 3_000),
        UserLevel(level: 6, title: "Navigator", minXP: 3_000, maxXP: 5_500),
        UserLevel(level: 7, title: "Ambassador", minXP: 5_500, maxXP: 9_000),
        UserLevel(level: 8, title: "World Citizen", minXP: 9_000, maxXP: 14_000),
        UserLevel(level: 9, title: "Global Expert", minXP: 14_000, maxXP: 21_000),
        UserLevel(level: 10, title: "Master Geographer", minXP: 21_000, maxXP: Int.max),
    ]

    static func level(for xp: Int) -> UserLevel {
        thresholds.last(where: { xp >= $0.minXP }) ?? thresholds[0]
    }
}
