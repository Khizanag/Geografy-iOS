import Foundation
import SwiftData

@Model
final class XPRecord {
    var id: String
    var userID: String
    var amount: Int
    var source: String
    var earnedAt: Date
    var metadata: String?

    init(
        id: String = UUID().uuidString,
        userID: String,
        amount: Int,
        source: String,
        earnedAt: Date = .now,
        metadata: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.amount = amount
        self.source = source
        self.earnedAt = earnedAt
        self.metadata = metadata
    }
}
