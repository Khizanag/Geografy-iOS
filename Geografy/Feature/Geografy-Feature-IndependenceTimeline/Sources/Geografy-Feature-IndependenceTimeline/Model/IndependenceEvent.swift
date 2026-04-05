import Foundation

public struct IndependenceEvent: Identifiable, Sendable {
    public let id: String
    public let countryCode: String
    public let countryName: String
    public let year: Int
    public let independenceFrom: String
    public let description: String
}
