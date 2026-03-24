import Foundation
import SwiftData

@Model
final class FavoriteEntry {
    var countryCode: String
    var addedAt: Date

    init(countryCode: String, addedAt: Date = .now) {
        self.countryCode = countryCode
        self.addedAt = addedAt
    }
}
