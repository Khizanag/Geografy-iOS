import Foundation
import SwiftData

/// One record per calendar day — used to compute consecutive login streaks.
@Model
final class StreakRecord {
    var id: String
    var userID: String
    var date: Date

    init(
        id: String = UUID().uuidString,
        userID: String,
        date: Date
    ) {
        self.id = id
        self.userID = userID
        self.date = date
    }
}
