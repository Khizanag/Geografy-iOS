import Foundation

struct CountryTimelineEvent: Codable, Identifiable {
    var id: String { "\(year)-\(title)" }

    let year: String
    let title: String
    let description: String
}
