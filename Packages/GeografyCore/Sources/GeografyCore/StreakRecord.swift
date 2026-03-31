import Foundation
import SwiftData

/// One record per calendar day — used to compute consecutive login streaks.
@Model
public final class StreakRecord {
    public var id: String
    public var userID: String
    public var date: Date

    public init(
        id: String = UUID().uuidString,
        userID: String,
        date: Date
    ) {
        self.id = id
        self.userID = userID
        self.date = date
    }
}
