import Foundation

public struct CountryPhrase: Codable, Identifiable, Sendable {
    public var id: String { english }

    public let english: String
    public let local: String
    public let pronunciation: String
}
