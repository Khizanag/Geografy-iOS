import Foundation
import Observation

@Observable
@MainActor
public final class FeatureFlagService {
    private let defaults = UserDefaults.standard
    private let prefix = "feature_flag_"

    public init() {}

    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        defaults.object(forKey: prefix + flag.rawValue) as? Bool ?? true
    }

    public func setEnabled(_ flag: FeatureFlag, enabled: Bool) {
        defaults.set(enabled, forKey: prefix + flag.rawValue)
    }

    public func toggle(_ flag: FeatureFlag) {
        setEnabled(flag, enabled: !isEnabled(flag))
    }

    public func reset() {
        for flag in FeatureFlag.allCases {
            defaults.removeObject(forKey: prefix + flag.rawValue)
        }
    }
}

// MARK: - Feature Flag
public enum FeatureFlag: String, CaseIterable, Identifiable {
    case dailyChallenge
    case speedRun
    case flashcards
    case exploreGame
    case multiplayer
    case localMultiplayer
    case flagGame
    case trivia
    case wordSearch
    case borderChallenge
    case landmarkQuiz
    case travelTracker
    case travelJournal
    case travelBucketList
    case distanceCalculator
    case currencyConverter
    case timeZones
    case compare
    case timeline
    case oceanExplorer
    case languageExplorer
    case economyExplorer
    case geographyFeatures
    case cultureExplorer
    case landmarkGallery
    case mapColoring
    case countryNicknames
    case quotes
    case feed
    case leaderboards
    case friends
    case quizPacks
    case customQuiz
    case learningPath

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .dailyChallenge: "Daily Challenge"
        case .speedRun: "Speed Run"
        case .flashcards: "Flashcards"
        case .exploreGame: "Explore Game"
        case .multiplayer: "Multiplayer"
        case .localMultiplayer: "Local Multiplayer"
        case .flagGame: "Flag Game"
        case .trivia: "Trivia"
        case .wordSearch: "Word Search"
        case .borderChallenge: "Border Challenge"
        case .landmarkQuiz: "Landmark Quiz"
        case .travelTracker: "Travel Tracker"
        case .travelJournal: "Travel Journal"
        case .travelBucketList: "Travel Bucket List"
        case .distanceCalculator: "Distance Calculator"
        case .currencyConverter: "Currency Converter"
        case .timeZones: "Time Zones"
        case .compare: "Compare Countries"
        case .timeline: "Timeline"
        case .oceanExplorer: "Ocean Explorer"
        case .languageExplorer: "Language Explorer"
        case .economyExplorer: "Economy Explorer"
        case .geographyFeatures: "Geography Features"
        case .cultureExplorer: "Culture Explorer"
        case .landmarkGallery: "Landmark Gallery"
        case .mapColoring: "Map Coloring"
        case .countryNicknames: "Country Nicknames"
        case .quotes: "Quotes"
        case .feed: "Feed"
        case .leaderboards: "Leaderboards"
        case .friends: "Friends"
        case .quizPacks: "Quiz Packs"
        case .customQuiz: "Custom Quiz"
        case .learningPath: "Learning Path"
        }
    }

    public var icon: String {
        switch self {
        case .dailyChallenge: "calendar.badge.clock"
        case .speedRun: "timer"
        case .flashcards: "rectangle.on.rectangle.angled"
        case .exploreGame: "magnifyingglass.circle"
        case .multiplayer: "person.2"
        case .localMultiplayer: "antenna.radiowaves.left.and.right"
        case .flagGame: "flag.fill"
        case .trivia: "questionmark.circle"
        case .wordSearch: "character.magnify"
        case .borderChallenge: "square.dashed"
        case .landmarkQuiz: "building.columns"
        case .travelTracker: "airplane.departure"
        case .travelJournal: "book"
        case .travelBucketList: "checklist"
        case .distanceCalculator: "ruler"
        case .currencyConverter: "dollarsign.circle"
        case .timeZones: "clock"
        case .compare: "arrow.left.arrow.right"
        case .timeline: "clock.arrow.circlepath"
        case .oceanExplorer: "water.waves"
        case .languageExplorer: "character.bubble"
        case .economyExplorer: "chart.bar"
        case .geographyFeatures: "mountain.2"
        case .cultureExplorer: "theatermasks"
        case .landmarkGallery: "photo.on.rectangle"
        case .mapColoring: "paintpalette"
        case .countryNicknames: "quote.bubble"
        case .quotes: "text.quote"
        case .feed: "newspaper"
        case .leaderboards: "list.number"
        case .friends: "person.2.fill"
        case .quizPacks: "square.stack.3d.up"
        case .customQuiz: "slider.horizontal.3"
        case .learningPath: "graduationcap"
        }
    }

    public var category: Category {
        switch self {
        case .dailyChallenge, .speedRun, .flashcards, .exploreGame,
             .flagGame, .trivia, .wordSearch, .borderChallenge, .landmarkQuiz,
             .quizPacks, .customQuiz, .learningPath:
            .games
        case .multiplayer, .localMultiplayer, .leaderboards, .friends:
            .social
        case .travelTracker, .travelJournal, .travelBucketList:
            .travel
        case .distanceCalculator, .currencyConverter, .timeZones, .compare, .timeline:
            .tools
        case .oceanExplorer, .languageExplorer, .economyExplorer,
             .geographyFeatures, .cultureExplorer, .landmarkGallery,
             .mapColoring, .countryNicknames, .quotes, .feed:
            .explore
        }
    }

    public enum Category: String, CaseIterable {
        case games = "Games & Quizzes"
        case social = "Social"
        case travel = "Travel"
        case tools = "Tools"
        case explore = "Explore"
    }
}
