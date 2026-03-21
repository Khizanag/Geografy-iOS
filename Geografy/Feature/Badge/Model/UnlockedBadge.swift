import Foundation

struct UnlockedBadge: Codable, Identifiable, Equatable {
    let id: String
    let unlockedAt: Date
    let currentValue: Int
}
