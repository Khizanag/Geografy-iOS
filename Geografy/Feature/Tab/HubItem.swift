import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

enum HubItem: Identifiable, CaseIterable {
    case profile
    case quiz
    case mapPuzzle
    case pinDrop
    case worldFacts
    case countries
    case orgs
    case favorites
    case travel
    case dailyChallenge
    case compare
    case quizPacks
    case multiplayer
    case speedRun
    case wordSearch
    case srsStudy
    case learningPath
    case timeline
    case achievements
    case leaderboards
    case settings
    case search
    case distanceCalculator
    case currencyConverter
    case timeZones

    var id: Self { self }

    var label: String {
        switch self {
        case .profile: "Profile"
        case .quiz: "Quiz"
        case .mapPuzzle: "Map Puzzle"
        case .pinDrop: "Pin Drop"
        case .worldFacts: "World Facts"
        case .countries: "Countries"
        case .orgs: "Organizations"
        case .favorites: "Saved"
        case .travel: "Travel"
        case .dailyChallenge: "Daily Challenge"
        case .compare: "Compare Countries"
        case .quizPacks: "Quiz Library"
        case .multiplayer: "Multiplayer"
        case .speedRun: "Speed Run"
        case .distanceCalculator: "Distance Calculator"
        case .currencyConverter: "Currency Converter"
        case .timeZones: "Time Zones"
        case .timeline: "Historical Timeline"
        case .achievements: "Achievements"
        case .leaderboards: "Leaderboards"
        case .settings: "Settings"
        case .search: "Global Search"
        case .wordSearch: "Word Search"
        case .srsStudy: "Flashcards"
        case .learningPath: "Learning Path"
        }
    }

    var icon: String {
        switch self {
        case .profile: "person.fill"
        case .quiz: "gamecontroller.fill"
        case .mapPuzzle: "puzzlepiece.fill"
        case .pinDrop: "mappin.and.ellipse"
        case .worldFacts: "globe.europe.africa.fill"
        case .countries: "list.bullet"
        case .orgs: "building.2.fill"
        case .favorites: "heart.fill"
        case .travel: "airplane.departure"
        case .dailyChallenge: "calendar.badge.exclamationmark"
        case .compare: "arrow.left.arrow.right"
        case .quizPacks: "square.stack.fill"
        case .multiplayer: "person.2.fill"
        case .speedRun: "timer"
        case .distanceCalculator: "ruler"
        case .currencyConverter: "dollarsign.arrow.circlepath"
        case .timeZones: "clock.badge.fill"
        case .timeline: "clock.arrow.circlepath"
        case .achievements: "trophy.fill"
        case .leaderboards: "list.number"
        case .settings: "gearshape.fill"
        case .search: "magnifyingglass"
        case .wordSearch: "character.magnify"
        case .srsStudy: "brain.fill"
        case .learningPath: "graduationcap.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .profile: "View your stats and level"
        case .quiz: "Flags, capitals, and more"
        case .mapPuzzle: "Place countries on the map"
        case .pinDrop: "Drop a pin on the named country"
        case .worldFacts: "Records, oceans, landmarks"
        case .countries: "Browse all 197 countries"
        case .orgs: "International organizations"
        case .favorites: "Favorites, places to visit, collections"
        case .travel: "Countries visited and your trip journal"
        case .dailyChallenge: "New puzzle every day"
        case .compare: "Side-by-side country stats"
        case .quizPacks: "Themed packs and your own quizzes"
        case .multiplayer: "Play with friends nearby"
        case .speedRun: "Name all countries, race the clock"
        case .distanceCalculator: "Great circle distance between capitals"
        case .currencyConverter: "Daily rates for 160+ currencies"
        case .timeZones: "World clock, quiz & UTC offsets"
        case .timeline: "Borders through history"
        case .achievements: "Unlock badges and rewards"
        case .leaderboards: "Compete with others"
        case .settings: "App preferences"
        case .search: "Search all countries & orgs"
        case .wordSearch: "Find hidden country names"
        case .srsStudy: "Spaced repetition review"
        case .learningPath: "Guided geography curriculum"
        }
    }

    var color: Color {
        switch self {
        case .profile: DesignSystem.Color.indigo
        case .quiz: DesignSystem.Color.blue
        case .mapPuzzle: DesignSystem.Color.purple
        case .pinDrop: DesignSystem.Color.orange
        case .worldFacts: DesignSystem.Color.teal
        case .countries: DesignSystem.Color.blue
        case .orgs: DesignSystem.Color.purple
        case .favorites: DesignSystem.Color.pink
        case .travel: DesignSystem.Color.teal
        case .dailyChallenge: DesignSystem.Color.orange
        case .compare: DesignSystem.Color.blue
        case .quizPacks: DesignSystem.Color.blue
        case .multiplayer: DesignSystem.Color.teal
        case .speedRun: DesignSystem.Color.pink
        case .distanceCalculator: DesignSystem.Color.orange
        case .currencyConverter: DesignSystem.Color.teal
        case .timeZones: DesignSystem.Color.indigo
        case .timeline: DesignSystem.Color.indigo
        case .achievements: DesignSystem.Color.warning
        case .leaderboards: DesignSystem.Color.orange
        case .settings: DesignSystem.Color.textSecondary
        case .search: DesignSystem.Color.textSecondary
        case .wordSearch: DesignSystem.Color.indigo
        case .srsStudy: DesignSystem.Color.purple
        case .learningPath: DesignSystem.Color.blue
        }
    }

    var testKey: String {
        switch self {
        case .profile: "profile"
        case .quiz: "quiz"
        case .mapPuzzle: "mapPuzzle"
        case .pinDrop: "pinDrop"
        case .worldFacts: "worldFacts"
        case .countries: "countries"
        case .orgs: "orgs"
        case .favorites: "favorites"
        case .travel: "travel"
        case .dailyChallenge: "dailyChallenge"
        case .compare: "compare"
        case .quizPacks: "quizPacks"
        case .multiplayer: "multiplayer"
        case .speedRun: "speedRun"
        case .distanceCalculator: "distanceCalculator"
        case .currencyConverter: "currencyConverter"
        case .timeZones: "timeZones"
        case .timeline: "timeline"
        case .achievements: "achievements"
        case .leaderboards: "leaderboards"
        case .settings: "settings"
        case .search: "search"
        case .wordSearch: "wordSearch"
        case .srsStudy: "srsStudy"
        case .learningPath: "learningPath"
        }
    }

    var destination: Destination {
        switch self {
        case .profile: Destination(ProfileRoute.profile)
        case .quiz: Destination(PlayRoute.quizSetup)
        case .mapPuzzle: Destination(PlayRoute.mapPuzzle())
        case .pinDrop: Destination(PlayRoute.pinDrop)
        case .worldFacts: Destination(DiscoverRoute.worldFacts(.records))
        case .countries: Destination(CountryRoute.countries)
        case .orgs: Destination(DiscoverRoute.organizations)
        case .favorites: Destination(CountryRoute.saved(.favorites))
        case .travel: Destination(TravelRoute.travelTracker)
        case .dailyChallenge: Destination(PlayRoute.dailyChallenge)
        case .compare: Destination(CountryRoute.compare())
        case .quizPacks: Destination(PlayRoute.quizLibrary(.packs))
        case .multiplayer: Destination(PlayRoute.multiplayer)
        case .speedRun: Destination(PlayRoute.speedRunSetup)
        case .distanceCalculator: Destination(DiscoverRoute.distanceCalculator)
        case .currencyConverter: Destination(DiscoverRoute.currencyConverter())
        case .timeZones: Destination(DiscoverRoute.timeZones)
        case .timeline: Destination(DiscoverRoute.timeline)
        case .achievements: Destination(ProfileRoute.achievements)
        case .leaderboards: Destination(ProfileRoute.leaderboards)
        case .settings: Destination(ProfileRoute.settings)
        case .search: Destination(CountryRoute.search)
        case .wordSearch: Destination(PlayRoute.wordSearch)
        case .srsStudy: Destination(PlayRoute.srsStudy)
        case .learningPath: Destination(PlayRoute.learningPath)
        }
    }
}
