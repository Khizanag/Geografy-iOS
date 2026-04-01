import Foundation

public struct CountryTimelineEvent: Codable, Identifiable {
    public var id: String { "\(year)-\(title)" }

    public let year: String
    public let title: String
    public let description: String
}
