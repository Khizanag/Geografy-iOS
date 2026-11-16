import Foundation

public struct CountryFunFact: Codable, Identifiable, Sendable {
    public var id: String { text }

    public let emoji: String
    public let text: String
}
