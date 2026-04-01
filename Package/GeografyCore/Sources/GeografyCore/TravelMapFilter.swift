import Foundation

public enum TravelMapFilter: String, CaseIterable, Sendable {
    case visited
    case wantToVisit
    case all

    public var displayName: String {
        switch self {
        case .visited: "Visited"
        case .wantToVisit: "Want to Visit"
        case .all: "All Travel"
        }
    }

    public var icon: String {
        switch self {
        case .visited: "checkmark.circle.fill"
        case .wantToVisit: "heart.fill"
        case .all: "globe"
        }
    }
}
