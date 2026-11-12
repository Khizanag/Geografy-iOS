/// A tab of the Saved screen, which gathers everything the user keeps.
public enum SavedTab: String, CaseIterable, Hashable, Identifiable, Sendable {
    case favorites
    case wantToVisit
    case collections

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .favorites: "Favorites"
        case .wantToVisit: "Want to Visit"
        case .collections: "Collections"
        }
    }
}
