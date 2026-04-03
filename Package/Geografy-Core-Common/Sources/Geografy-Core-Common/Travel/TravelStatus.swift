import SwiftUI

public enum TravelStatus: String, CaseIterable, Codable, Identifiable, Sendable {
    case visited
    case wantToVisit

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .visited: "Visited"
        case .wantToVisit: "Want to Visit"
        }
    }

    public var shortLabel: String {
        switch self {
        case .visited: "Visited"
        case .wantToVisit: "Want"
        }
    }

    public var icon: String {
        switch self {
        case .visited: "checkmark.seal.fill"
        case .wantToVisit: "heart.fill"
        }
    }

    public var color: Color {
        switch self {
        case .visited: Color(hex: "00C9A7")
        case .wantToVisit: Color(hex: "FF9500")
        }
    }
}
