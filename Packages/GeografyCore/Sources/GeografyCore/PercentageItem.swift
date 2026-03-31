public struct PercentageItem: Sendable {
    public let name: String
    public let percentage: Double

    public init(name: String, percentage: Double) {
        self.name = name
        self.percentage = percentage
    }
}
