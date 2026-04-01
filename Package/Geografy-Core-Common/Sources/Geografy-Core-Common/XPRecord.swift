import Foundation
import SwiftData

@Model
public final class XPRecord {
    public var id: String
    public var userID: String
    public var amount: Int
    public var source: String
    public var earnedAt: Date
    public var metadata: String?

    public init(
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
