import SwiftUI

enum TravelStatus: String, CaseIterable, Codable, Identifiable {
    case visited
    case wantToVisit

    var id: String { rawValue }

    var label: String {
        switch self {
        case .visited: "Visited"
        case .wantToVisit: "Want to Visit"
        }
    }

    var shortLabel: String {
        switch self {
        case .visited: "Visited"
        case .wantToVisit: "Want"
        }
    }

    var icon: String {
        switch self {
        case .visited: "checkmark.seal.fill"
        case .wantToVisit: "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .visited: Color(hex: "00C9A7")
        case .wantToVisit: Color(hex: "FF9500")
        }
    }
}
