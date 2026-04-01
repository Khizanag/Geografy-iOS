import Foundation

public struct Ocean: Identifiable {
    public let id: String
    public let name: String
    public let area: Double // km²
    public let averageDepth: Double // meters
    public let maxDepth: Double // meters
    public let borderingContinents: [String]
    public let funFact: String
    public let icon: String // SF Symbol
    public let isOcean: Bool
}
