import Foundation

enum HomeSection: String, CaseIterable, Identifiable, Codable {
    case guestBanner
    case carousel
    case spotlight
    case streak
    case worldRecords
    case organizations
    case progress
    case comingSoon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .guestBanner: "Guest Mode Banner"
        case .carousel: "Explore Maps"
        case .spotlight: "Country Spotlight"
        case .streak: "Daily Streak"
        case .worldRecords: "World Records"
        case .organizations: "Organizations"
        case .progress: "Statistics"
        case .comingSoon: "Coming Soon"
        }
    }

    var icon: String {
        switch self {
        case .guestBanner: "person.badge.key.fill"
        case .carousel: "map.fill"
        case .spotlight: "star.fill"
        case .streak: "flame.fill"
        case .worldRecords: "trophy.fill"
        case .organizations: "building.2.fill"
        case .progress: "chart.bar.fill"
        case .comingSoon: "sparkles"
        }
    }
}
