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
    case speedRunSetup
    case dailyChallenge
    case exploreGame
    case multiplayer
    case quizPacks
    case customQuiz

    // Tools
    case distanceCalculator
    case currencyConverter
    case timeZones

    // Explore
    case compare
    case timeline

    // Travel
    case travelTracker
    case travelJournal
    case travelBucketList

    // Badges & achievements
    case badges
    case leaderboards

    // Discover
    case search

    // Study
    case srsStudy

    // Games
    case flagGame
    case trivia
    case spellingBee
    case landmarkQuiz

    // Discover
    case feed

    // Challenge
    case challengeRoom

    // Culture & Discovery
    case geoQuotes
    case countryNicknames

    // Games & Quizzes
    case nationalSymbolsQuiz
    case wordSearch
    case borderChallenge

    // App
    case achievements
    case themes
    case settings
    case sectionEditor
    case friends
    case learningPath

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
        case .speedRunSetup: "speedRunSetup"
        case .distanceCalculator: "distanceCalculator"
        case .currencyConverter: "currencyConverter"
        case .timeZones: "timeZones"
        case .dailyChallenge: "dailyChallenge"
        case .exploreGame: "exploreGame"
        case .multiplayer: "multiplayer"
        case .quizPacks: "quizPacks"
        case .customQuiz: "customQuiz"
        case .search: "search"
        case .compare: "compare"
        case .timeline: "timeline"
        case .travelTracker: "travelTracker"
        case .travelJournal: "travelJournal"
        case .travelBucketList: "travelBucketList"
        case .badges: "badges"
        case .leaderboards: "leaderboards"
        case .achievements: "achievements"
        case .themes: "themes"
        case .settings: "settings"
        case .sectionEditor: "sectionEditor"
        case .friends: "friends"
        case .learningPath: "learningPath"
        case .srsStudy: "srsStudy"
        case .flagGame: "flagGame"
        case .trivia: "trivia"
        case .spellingBee: "spellingBee"
        case .landmarkQuiz: "landmarkQuiz"
        case .feed: "feed"
        case .challengeRoom: "challengeRoom"
        case .geoQuotes: "geoQuotes"
        case .countryNicknames: "countryNicknames"
        case .nationalSymbolsQuiz: "nationalSymbolsQuiz"
        case .wordSearch: "wordSearch"
        case .borderChallenge: "borderChallenge"
        }
    }
}
