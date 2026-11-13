import Foundation
import SwiftData

/// A collection the user created by name, so it exists even before anything is saved into it.
@Model
public final class SavedCollection {
    // MARK: - Properties
    public var name: String
    public var createdAt: Date
    /// Empty on collections saved before they were per user, until the first active user claims them.
    public var userID: String = ""

    // MARK: - Init
    public init(name: String, createdAt: Date = .now, userID: String = UserScope.currentUserID) {
        self.name = name
        self.createdAt = createdAt
        self.userID = userID
    }
}
