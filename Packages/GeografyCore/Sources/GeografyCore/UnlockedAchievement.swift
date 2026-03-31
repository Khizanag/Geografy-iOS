import Foundation
import SwiftData

@Model
public final class UnlockedAchievement {
    public var id: String
    public var userID: String
    public var unlockedAt: Date
    public var gameCenterReported: Bool

    public init(
        id: String,
        userID: String,
        unlockedAt: Date = .now,
        gameCenterReported: Bool = false
    ) {
        self.id = id
        self.userID = userID
        self.unlockedAt = unlockedAt
        self.gameCenterReported = gameCenterReported
    }
}
