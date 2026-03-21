import Foundation

enum TravelMapFilter: String, CaseIterable {
    case visited
    case wantToVisit
    case all

    var displayName: String {
        switch self {
        case .visited: "Visited"
        case .wantToVisit: "Want to Visit"
        case .all: "All Travel"
        }
    }
}
