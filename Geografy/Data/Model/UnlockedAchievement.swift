import Foundation
import SwiftData

@Model
final class UnlockedAchievement {
    var id: String
    var userID: String
    var unlockedAt: Date
    var gameCenterReported: Bool

    init(
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
