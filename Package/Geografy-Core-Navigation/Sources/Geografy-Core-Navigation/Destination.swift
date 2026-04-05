import Geografy_Core_Common
import SwiftUI

// MARK: - Destination
public enum Destination: Hashable, Identifiable {
    case achievementDetail(AchievementDefinition)
    case achievements
    case allMaps
    case borderChallenge
    case coinStore
    case compare(preselectedCountry: Country? = nil)
    case continentOverview(Country.Continent)
    case continentPicker
    case continentStats(String)
    case countries
    case countryDetail(Country)
    case countryNicknames
    case countryNicknameQuiz
    case cultureExplorer
    case currencyConverter(preselectedCode: String? = nil)
    case customQuiz
    case customQuizShare(CustomQuiz)
    case dailyChallenge
    case dailyChallengeResult(
        score: Int, maxScore: Int, challengeType: DailyChallengeType,
        timeSpent: TimeInterval, streak: Int
    )
    case editProfile
    case distanceCalculator
    case economyExplorer
    case exploreGame
    case favorites
    case featureFlags
    case feed
    case flagGame
    case flashcardSession(deck: FlashcardDeck, cards: [FlashcardItem])
    case friends
    case geographyFeatures
    case historicalMap(initialYear: Int)
    case independenceTimeline
    case landmarkGallery
    case landmarkQuiz
    case languageExplorer
    case learningPath
    case lesson(LearningModule, Lesson)
    case leaderboards
    case localMultiplayer
    case map(continentFilter: Country.Continent? = nil)
    case mapColoring
    case mapFullScreen(continentFilter: String?)
    case mapPuzzle
    case multiplayer
    case neighborExplorer(Country)
    case oceanExplorer
    case organizationDetail(Organization)
    case organizationMap(Organization)
    case organizations
    case paywall
    case profile
    case quizPackDetail(packID: String)
    case quizPacks
    case quizSession(QuizConfiguration)
    case quizSetup
    case quotes
    case search
    case sectionEditor
    case settings
    case signIn
    case speedRunSession(region: QuizRegion)
    case speedRunSetup
    case srsStudy
    case territorialDisputes
    case themes
    case timeline
    case timeZones
    case travelBucketList
    case travelJournal
    case travelMap(TravelMapFilter)
    case travelTracker
    case trivia
    case wordSearch
    case wordSearchGame(WordSearchTheme)
    case worldRecords

    public var id: String {
        switch self {
        case .achievementDetail(let definition): "achievementDetail-\(definition.id)"
        case .achievements: "achievements"
        case .allMaps: "allMaps"
        case .borderChallenge: "borderChallenge"
        case .coinStore: "coinStore"
        case .compare(let country): "compare-\(country?.code ?? "none")"
        case .continentOverview(let continent): "continentOverview-\(continent.rawValue)"
        case .continentPicker: "continentPicker"
        case .continentStats(let name): "continentStats-\(name)"
        case .countries: "countries"
        case .countryDetail(let country): "countryDetail-\(country.code)"
        case .countryNicknames: "countryNicknames"
        case .countryNicknameQuiz: "countryNicknameQuiz"
        case .cultureExplorer: "cultureExplorer"
        case .currencyConverter(let code): "currencyConverter-\(code ?? "none")"
        case .customQuiz: "customQuiz"
        case .customQuizShare(let quiz): "customQuizShare-\(quiz.id)"
        case .dailyChallenge: "dailyChallenge"
        case .dailyChallengeResult: "dailyChallengeResult"
        case .editProfile: "editProfile"
        case .distanceCalculator: "distanceCalculator"
        case .economyExplorer: "economyExplorer"
        case .exploreGame: "exploreGame"
        case .favorites: "favorites"
        case .featureFlags: "featureFlags"
        case .feed: "feed"
        case .flagGame: "flagGame"
        case .flashcardSession: "flashcardSession"
        case .friends: "friends"
        case .geographyFeatures: "geographyFeatures"
        case .historicalMap(let year): "historicalMap-\(year)"
        case .independenceTimeline: "independenceTimeline"
        case .landmarkGallery: "landmarkGallery"
        case .landmarkQuiz: "landmarkQuiz"
        case .languageExplorer: "languageExplorer"
        case .learningPath: "learningPath"
        case let .lesson(module, lesson): "lesson-\(module.id)-\(lesson.id)"
        case .leaderboards: "leaderboards"
        case .localMultiplayer: "localMultiplayer"
        case .map(let filter): "map-\(filter?.rawValue ?? "world")"
        case .mapColoring: "mapColoring"
        case .mapFullScreen(let filter): "mapFullScreen-\(filter ?? "world")"
        case .mapPuzzle: "mapPuzzle"
        case .multiplayer: "multiplayer"
        case .neighborExplorer(let country): "neighborExplorer-\(country.code)"
        case .oceanExplorer: "oceanExplorer"
        case .organizationDetail(let org): "orgDetail-\(org.id)"
        case .organizationMap(let org): "orgMap-\(org.id)"
        case .organizations: "organizations"
        case .paywall: "paywall"
        case .profile: "profile"
        case .quizPackDetail(let id): "quizPackDetail-\(id)"
        case .quizPacks: "quizPacks"
        case .quizSession: "quizSession"
        case .quizSetup: "quizSetup"
        case .quotes: "quotes"
        case .search: "search"
        case .sectionEditor: "sectionEditor"
        case .settings: "settings"
        case .signIn: "signIn"
        case .speedRunSession(let region): "speedRunSession-\(region.rawValue)"
        case .speedRunSetup: "speedRunSetup"
        case .srsStudy: "srsStudy"
        case .territorialDisputes: "territorialDisputes"
        case .themes: "themes"
        case .timeline: "timeline"
        case .timeZones: "timeZones"
        case .travelBucketList: "travelBucketList"
        case .travelJournal: "travelJournal"
        case .travelMap: "travelMap"
        case .travelTracker: "travelTracker"
        case .trivia: "trivia"
        case .wordSearch: "wordSearch"
        case .wordSearchGame(let theme): "wordSearchGame-\(theme.rawValue)"
        case .worldRecords: "worldRecords"
        }
    }
}
