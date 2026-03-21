import Foundation

struct CountryFunFact: Codable, Identifiable {
    var id: String { text }

    let emoji: String
    let text: String
}
