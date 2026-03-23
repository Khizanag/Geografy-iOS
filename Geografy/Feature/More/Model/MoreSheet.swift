import SwiftUI

enum MoreSheet: Identifiable {
    case profile, countries, orgs, favorites, travel
    case dailyChallenge, compare, travelJournal
    case quizPacks, customQuiz, multiplayer, exploreGame, speedRun
    case badges, timeline
    case achievements, leaderboards, themes, settings
    case search
    case distanceCalculator

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
        case .badges: "Badge Collection"
        case .timeline: "Historical Timeline"
        case .achievements: "Achievements"
        case .leaderboards: "Leaderboards"
        case .themes: "Themes"
        case .settings: "Settings"
        case .search: "Global Search"
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
        case .badges: "medal.fill"
        case .timeline: "clock.arrow.circlepath"
        case .achievements: "trophy.fill"
        case .leaderboards: "list.number"
        case .themes: "paintbrush.fill"
        case .settings: "gearshape.fill"
        case .search: "magnifyingglass"
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
        case .badges: "Collect and showcase"
        case .timeline: "Borders through history"
        case .achievements: "Unlock badges and rewards"
        case .leaderboards: "Compete with others"
        case .themes: "Customize your experience"
        case .settings: "App preferences"
        case .search: "Search all countries & orgs"
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
        case .badges: DesignSystem.Color.warning
        case .timeline: DesignSystem.Color.indigo
        case .achievements: DesignSystem.Color.warning
        case .leaderboards: DesignSystem.Color.success
        case .themes: DesignSystem.Color.indigo
        case .settings: DesignSystem.Color.textSecondary
        case .search: DesignSystem.Color.accent
        }
    }

    var toSheet: Sheet {
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
        case .badges: .badges
        case .timeline: .timeline
        case .achievements: .achievements
        case .leaderboards: .leaderboards
        case .themes: .themes
        case .settings: .settings
        case .search: .search
        }
    }
}
