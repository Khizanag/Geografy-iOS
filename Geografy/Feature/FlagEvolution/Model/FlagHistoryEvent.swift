import Foundation

struct FlagHistoryEvent: Identifiable {
    let id: UUID
    let countryCode: String
    let year: Int
    let description: String
    let colors: [String]
    let designDescription: String
    let reasonForChange: String
}
