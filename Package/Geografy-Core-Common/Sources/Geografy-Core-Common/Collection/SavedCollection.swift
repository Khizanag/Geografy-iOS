import Foundation
import SwiftData

/// A collection the user created by name, so it exists even before anything is saved into it.
@Model
public final class SavedCollection {
    // MARK: - Properties
    public var name: String
    public var createdAt: Date

    // MARK: - Init
    public init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}
