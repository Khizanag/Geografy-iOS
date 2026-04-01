import Foundation
import SwiftData

@Model
public final class FavoriteEntry {
    public var countryCode: String
    public var addedAt: Date

    public init(countryCode: String, addedAt: Date = .now) {
        self.countryCode = countryCode
        self.addedAt = addedAt
    }
}
