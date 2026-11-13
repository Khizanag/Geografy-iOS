import Foundation
import SwiftData

@Model
public final class FavoriteEntry {
    public var countryCode: String
    public var addedAt: Date
    /// Empty on favorites saved before they were per user, until the first active user claims them.
    public var userID: String = ""

    public init(countryCode: String, addedAt: Date = .now, userID: String = UserScope.currentUserID) {
        self.countryCode = countryCode
        self.addedAt = addedAt
        self.userID = userID
    }
}
