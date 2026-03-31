import SwiftUI
import GeografyDesign
import GeografyCore

enum MoreSheet: Identifiable {
    case profile, countries, orgs, favorites, travel
    case dailyChallenge, compare, travelJournal, travelBucketList
    case quizPacks, customQuiz, multiplayer, exploreGame, speedRun
    case flagGame, trivia, spellingBee, landmarkQuiz
    case wordSearch, borderChallenge, challengeRoom, countryNicknames
    case quotes, feed
    case srsStudy, learningPath
    case timeline
    case achievements, leaderboards, themes, settings
    case search
    case distanceCalculator
    case currencyConverter
    case timeZones

    var id: Self { self }

    var label: String {
        switch self {
        case .profile: "Profile"
        case .countries: "Countries"
        case .orgs: "Organizations"
        case .favorites: "Favorites"
        case .travel: "Travel Tracker"
        case .dailyChallenge: "Daily Challenge"
        case .compare: "Compare Countries"
        case .travelJournal: "Travel Journal"
        case .quizPacks: "Quiz Packs"
        case .customQuiz: "Custom Quizzes"
        case .multiplayer: "Multiplayer"
        case .exploreGame: "Mystery Country"
        case .speedRun: "Speed Run"
        case .distanceCalculator: "Distance Calculator"
        case .currencyConverter: "Currency Converter"
        case .timeZones: "Time Zones"
        case .timeline: "Historical Timeline"
        case .achievements: "Achievements"
        case .leaderboards: "Leaderboards"
        case .themes: "Themes"
        case .settings: "Settings"
        case .search: "Global Search"
        case .flagGame: "Flag Game"
        case .trivia: "Trivia"
        case .spellingBee: "Spelling Bee"
        case .landmarkQuiz: "Landmark Quiz"
        case .wordSearch: "Word Search"
        case .borderChallenge: "Border Challenge"
        case .challengeRoom: "Challenge Room"
        case .countryNicknames: "Country Nicknames"
        case .quotes: "Quotes"
        case .feed: "Feed"
        case .srsStudy: "SRS Review"
        case .learningPath: "Learning Path"
        case .travelBucketList: "Bucket List"
        }
    }

    var icon: String {
        switch self {
        case .profile: "person.fill"
        case .countries: "list.bullet"
        case .orgs: "building.2.fill"
        case .favorites: "heart.fill"
        case .travel: "airplane.departure"
        case .dailyChallenge: "calendar.badge.exclamationmark"
        case .compare: "arrow.left.arrow.right"
        case .travelJournal: "book.fill"
        case .quizPacks: "square.stack.fill"
        case .customQuiz: "pencil.and.list.clipboard"
        case .multiplayer: "person.2.fill"
        case .exploreGame: "magnifyingglass"
        case .speedRun: "timer"
        case .distanceCalculator: "ruler"
        case .currencyConverter: "dollarsign.arrow.circlepath"
        case .timeZones: "clock.badge.fill"
        case .timeline: "clock.arrow.circlepath"
        case .achievements: "trophy.fill"
        case .leaderboards: "list.number"
        case .themes: "paintbrush.fill"
        case .settings: "gearshape.fill"
        case .search: "magnifyingglass"
        case .flagGame: "flag.fill"
        case .trivia: "questionmark.bubble.fill"
        case .spellingBee: "textformat.abc"
        case .landmarkQuiz: "photo.fill"
        case .wordSearch: "character.magnify"
        case .borderChallenge: "square.dashed"
        case .challengeRoom: "bolt.fill"
        case .countryNicknames: "tag.fill"
        case .quotes: "quote.bubble.fill"
        case .feed: "newspaper.fill"
        case .srsStudy: "brain.fill"
        case .learningPath: "graduationcap.fill"
        case .travelBucketList: "checklist"
        }
    }

    var subtitle: String {
        switch self {
        case .profile: "View your stats and level"
        case .countries: "Browse all 197 countries"
        case .orgs: "International organizations"
        case .favorites: "Your saved countries"
        case .travel: "Track your adventures"
        case .dailyChallenge: "New puzzle every day"
        case .compare: "Side-by-side country stats"
        case .travelJournal: "Photos, notes & memories"
        case .quizPacks: "Themed quiz progression"
        case .customQuiz: "Build your own quizzes"
        case .multiplayer: "Challenge opponents"
        case .exploreGame: "Guess from clues"
        case .speedRun: "Name all countries, race the clock"
        case .distanceCalculator: "Great circle distance between capitals"
        case .currencyConverter: "Live exchange rates, 160+ currencies"
        case .timeZones: "World clock, quiz & UTC offsets"
        case .timeline: "Borders through history"
        case .achievements: "Unlock badges and rewards"
        case .leaderboards: "Compete with others"
        case .themes: "Customize your experience"
        case .settings: "App preferences"
        case .search: "Search all countries & orgs"
        case .flagGame: "Match flags to countries"
        case .trivia: "True or false geography facts"
        case .spellingBee: "Spell country names"
        case .landmarkQuiz: "Identify famous landmarks"
        case .wordSearch: "Find hidden country names"
        case .borderChallenge: "Guess by outline shape"
        case .challengeRoom: "Timed multi-round challenge"
        case .countryNicknames: "Informal country names"
        case .quotes: "Geography quotes & facts"
        case .feed: "Curated geography news"
        case .srsStudy: "Spaced repetition review"
        case .learningPath: "Guided geography curriculum"
        case .travelBucketList: "Countries you dream of visiting"
        }
    }

    var color: Color {
        switch self {
        case .profile: DesignSystem.Color.accent
        case .countries: DesignSystem.Color.blue
        case .orgs: DesignSystem.Color.indigo
        case .favorites: DesignSystem.Color.error
        case .travel: Color(hex: "00C9A7")
        case .dailyChallenge: DesignSystem.Color.orange
        case .compare: DesignSystem.Color.blue
        case .travelJournal: Color(hex: "00C9A7")
        case .quizPacks: DesignSystem.Color.purple
        case .customQuiz: DesignSystem.Color.accent
        case .multiplayer: DesignSystem.Color.error
        case .exploreGame: DesignSystem.Color.warning
        case .speedRun: DesignSystem.Color.error
        case .distanceCalculator: DesignSystem.Color.blue
        case .currencyConverter: DesignSystem.Color.success
        case .timeZones: DesignSystem.Color.indigo
        case .timeline: DesignSystem.Color.indigo
        case .achievements: DesignSystem.Color.warning
        case .leaderboards: DesignSystem.Color.success
        case .themes: DesignSystem.Color.indigo
        case .settings: DesignSystem.Color.textSecondary
        case .search: DesignSystem.Color.accent
        case .flagGame: DesignSystem.Color.error
        case .trivia: DesignSystem.Color.purple
        case .spellingBee: DesignSystem.Color.orange
        case .landmarkQuiz: DesignSystem.Color.accent
        case .wordSearch: DesignSystem.Color.indigo
        case .borderChallenge: DesignSystem.Color.warning
        case .challengeRoom: DesignSystem.Color.error
        case .countryNicknames: DesignSystem.Color.purple
        case .quotes: DesignSystem.Color.indigo
        case .feed: DesignSystem.Color.blue
        case .srsStudy: DesignSystem.Color.accent
        case .learningPath: DesignSystem.Color.success
        case .travelBucketList: Color(hex: "00C9A7")
        }
    }

    var testKey: String {
        switch self {
        case .profile: "profile"
        case .countries: "countries"
        case .orgs: "orgs"
        case .favorites: "favorites"
        case .travel: "travel"
        case .dailyChallenge: "dailyChallenge"
        case .compare: "compare"
        case .travelJournal: "travelJournal"
        case .quizPacks: "quizPacks"
        case .customQuiz: "customQuiz"
        case .multiplayer: "multiplayer"
        case .exploreGame: "exploreGame"
        case .speedRun: "speedRun"
        case .distanceCalculator: "distanceCalculator"
        case .currencyConverter: "currencyConverter"
        case .timeZones: "timeZones"
        case .timeline: "timeline"
        case .achievements: "achievements"
        case .leaderboards: "leaderboards"
        case .themes: "themes"
        case .settings: "settings"
        case .search: "search"
        case .flagGame: "flagGame"
        case .trivia: "trivia"
        case .spellingBee: "spellingBee"
        case .landmarkQuiz: "landmarkQuiz"
        case .wordSearch: "wordSearch"
        case .borderChallenge: "borderChallenge"
        case .challengeRoom: "challengeRoom"
        case .countryNicknames: "countryNicknames"
        case .quotes: "quotes"
        case .feed: "feed"
        case .srsStudy: "srsStudy"
        case .learningPath: "learningPath"
        case .travelBucketList: "travelBucketList"
        }
    }

    var toDestination: Destination {
        switch self {
        case .profile: .profile
        case .countries: .countries
        case .orgs: .organizations
        case .favorites: .favorites
        case .travel: .travelTracker
        case .dailyChallenge: .dailyChallenge
        case .compare: .compare
        case .travelJournal: .travelJournal
        case .quizPacks: .quizPacks
        case .customQuiz: .customQuiz
        case .multiplayer: .multiplayer
        case .exploreGame: .exploreGame
        case .speedRun: .speedRunSetup
        case .distanceCalculator: .distanceCalculator
        case .currencyConverter: .currencyConverter
        case .timeZones: .timeZones
        case .timeline: .timeline
        case .achievements: .achievements
        case .leaderboards: .leaderboards
        case .themes: .themes
        case .settings: .settings
        case .search: .search
        case .flagGame: .flagGame
        case .trivia: .trivia
        case .spellingBee: .spellingBee
        case .landmarkQuiz: .landmarkQuiz
        case .wordSearch: .wordSearch
        case .borderChallenge: .borderChallenge
        case .challengeRoom: .challengeRoom
        case .countryNicknames: .countryNicknames
        case .quotes: .quotes
        case .feed: .feed
        case .srsStudy: .srsStudy
        case .learningPath: .learningPath
        case .travelBucketList: .travelBucketList
        }
    }
}
