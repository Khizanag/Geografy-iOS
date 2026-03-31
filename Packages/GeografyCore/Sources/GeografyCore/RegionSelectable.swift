public protocol RegionSelectable: Identifiable, Hashable {
    var displayName: String { get }
    var regionIcon: String { get }
}
