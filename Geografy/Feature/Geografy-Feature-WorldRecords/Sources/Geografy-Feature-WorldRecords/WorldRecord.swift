import Foundation

public struct WorldRecord: Identifiable, Sendable {
    public let id = UUID()
    public let category: WorldRecordCategory
    public let title: String
    public let countryCode: String
    public let countryName: String
    public let value: String
    public let unit: String
    public let description: String
}
