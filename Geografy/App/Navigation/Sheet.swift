import Foundation

enum Sheet: Identifiable {
    // Auth
    case signIn

    // Profile
    case profile

    // Content browsing
    case countries
    case favorites
    case organizations
    case organizationDetail(Organization)

    // Store
    case coinStore
    case paywall

    // Play modes
    case quizSetup
    case dailyChallenge
    case exploreGame
    case multiplayer
    case quizPacks
    case customQuiz

    // Explore
    case compare
    case timeline

    // Travel
    case travelTracker
    case travelJournal

    // Badges & achievements
    case badges
    case leaderboards

    // App
    case achievements
    case themes
    case settings
    case sectionEditor
    case friends

    var id: String {
        switch self {
        case .signIn: "signIn"
        case .profile: "profile"
        case .countries: "countries"
        case .favorites: "favorites"
        case .organizations: "organizations"
        case .organizationDetail(let organization): "orgDetail-\(organization.id)"
        case .coinStore: "coinStore"
        case .paywall: "paywall"
        case .quizSetup: "quizSetup"
        case .dailyChallenge: "dailyChallenge"
        case .exploreGame: "exploreGame"
        case .multiplayer: "multiplayer"
        case .quizPacks: "quizPacks"
        case .customQuiz: "customQuiz"
        case .compare: "compare"
        case .timeline: "timeline"
        case .travelTracker: "travelTracker"
        case .travelJournal: "travelJournal"
        case .badges: "badges"
        case .leaderboards: "leaderboards"
        case .achievements: "achievements"
        case .themes: "themes"
        case .settings: "settings"
        case .sectionEditor: "sectionEditor"
        case .friends: "friends"
        }
    }
}
