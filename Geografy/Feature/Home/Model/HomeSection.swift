import Foundation

enum HomeSection: String, CaseIterable, Identifiable, Codable {
    case guestBanner
    case carousel
    case spotlight
    case streak
    case dailyChallenge
    case capitalQuiz
    case srsReview
    case worldRecords
    case organizations
    case progress
    case flagGame
    case geoTrivia
    case spellingBee
    case comingSoon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .guestBanner: "Guest Mode Banner"
        case .carousel: "Explore Maps"
        case .spotlight: "Country Spotlight"
        case .streak: "Daily Streak"
        case .dailyChallenge: "Daily Challenge"
        case .capitalQuiz: "Capital City Quiz"
        case .srsReview: "Due for Review"
        case .worldRecords: "World Records"
        case .organizations: "Organizations"
        case .progress: "Statistics"
        case .flagGame: "Flag Matching"
        case .geoTrivia: "Geo Trivia"
        case .spellingBee: "Spelling Bee"
        case .comingSoon: "Coming Soon"
        }
    }

    var icon: String {
        switch self {
        case .guestBanner: "person.badge.key.fill"
        case .carousel: "map.fill"
        case .spotlight: "star.fill"
        case .streak: "flame.fill"
        case .dailyChallenge: "calendar.badge.clock"
        case .capitalQuiz: "building.columns.fill"
        case .srsReview: "clock.arrow.circlepath"
        case .worldRecords: "trophy.fill"
        case .organizations: "building.2.fill"
        case .progress: "chart.bar.fill"
        case .flagGame: "flag.fill"
        case .geoTrivia: "checkmark.circle.fill"
        case .spellingBee: "pencil.and.list.clipboard"
        case .comingSoon: "sparkles"
        }
    }
}
