protocol SelectableType: Identifiable, Hashable {
    var displayName: String { get }
    var icon: String { get }
    var emoji: String { get }
    var description: String { get }
}
