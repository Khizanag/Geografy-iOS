/// What a filled pair slot shows: a flag, a name and a short detail line.
public struct PairSlotItem: Equatable, Sendable {
    public let flagCode: String
    public let title: String
    public let subtitle: String?

    public init(flagCode: String, title: String, subtitle: String? = nil) {
        self.flagCode = flagCode
        self.title = title
        self.subtitle = subtitle
    }
}
