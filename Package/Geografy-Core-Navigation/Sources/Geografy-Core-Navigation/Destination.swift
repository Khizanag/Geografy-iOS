import Geografy_Core_Common
import SwiftUI

// MARK: - Destination
public enum Destination: Hashable, Identifiable {
    case achievementDetail(AchievementDefinition)
    case achievements
    case allMaps
    case collectionDetail(String)
    case compare(preselectedCountry: Country? = nil)
    case continentOverview(Country.Continent)
    case countries
    case countryDetail(Country)
    case currencyConverter(preselectedCode: String? = nil)
    case customQuizShare(CustomQuiz)
    case dailyChallenge
    case dailyChallengeResult(
        score: Int, maxScore: Int, challengeType: DailyChallengeType,
        timeSpent: TimeInterval, streak: Int
    )
    case editProfile
    case distanceCalculator
    case saved(SavedTab)
    case feed
    case flashcardSession(deck: FlashcardDeck, cards: [FlashcardItem])
    case friends
    case historicalMap(initialYear: Int)
    case learningPath
    case learningModule(LearningModule)
    case lesson(LearningModule, Lesson)
    case leaderboards
    case localMultiplayer
    case map(continentFilter: Country.Continent? = nil)
    case mapColoring
    case mapFullScreen(continentFilter: String?)
    case mapPuzzle
    case multiplayer
    case neighborExplorer(Country)
    case organizationDetail(Organization)
    case organizationMap(Organization)
    case organizations
    case profile
    case quizPackDetail(packID: String)
    case quizLibrary(QuizLibraryTab)
    case quizSession(QuizConfiguration)
    case quizSetup
    case quotes
    case saveToCollection(countryCode: String, countryName: String)
    case search
    case settings
    case signIn
    case speedRunSession(region: QuizRegion)
    case speedRunSetup
    case srsStudy
    case territorialDisputes
    case themes
    case timeline
    case timeZones
    case travelStatusPicker(Country)
    case travelMap(TravelMapFilter)
    case travelTracker
    case wordSearch
    case wordSearchGame(WordSearchTheme)
    case worldFacts(WorldFactsTopic)

    public var id: String {
        switch self {
        case .achievementDetail(let definition): "achievementDetail-\(definition.id)"
        case .achievements: "achievements"
        case .allMaps: "allMaps"
        case .collectionDetail(let name): "collectionDetail-\(name)"
        case .compare(let country): "compare-\(country?.code ?? "none")"
        case .continentOverview(let continent): "continentOverview-\(continent.rawValue)"
        case .countries: "countries"
        case .countryDetail(let country): "countryDetail-\(country.code)"
        case .currencyConverter(let code): "currencyConverter-\(code ?? "none")"
        case .customQuizShare(let quiz): "customQuizShare-\(quiz.id)"
        case .dailyChallenge: "dailyChallenge"
        case .dailyChallengeResult: "dailyChallengeResult"
        case .editProfile: "editProfile"
        case .distanceCalculator: "distanceCalculator"
        case .saved(let tab): "saved-\(tab.rawValue)"
        case .feed: "feed"
        case .flashcardSession: "flashcardSession"
        case .friends: "friends"
        case .historicalMap(let year): "historicalMap-\(year)"
        case .learningPath: "learningPath"
        case .learningModule(let module): "learningModule-\(module.id)"
        case let .lesson(module, lesson): "lesson-\(module.id)-\(lesson.id)"
        case .leaderboards: "leaderboards"
        case .localMultiplayer: "localMultiplayer"
        case .map(let filter): "map-\(filter?.rawValue ?? "world")"
        case .mapColoring: "mapColoring"
        case .mapFullScreen(let filter): "mapFullScreen-\(filter ?? "world")"
        case .mapPuzzle: "mapPuzzle"
        case .multiplayer: "multiplayer"
        case .neighborExplorer(let country): "neighborExplorer-\(country.code)"
        case .organizationDetail(let org): "orgDetail-\(org.id)"
        case .organizationMap(let org): "orgMap-\(org.id)"
        case .organizations: "organizations"
        case .profile: "profile"
        case .quizPackDetail(let id): "quizPackDetail-\(id)"
        case .quizLibrary(let tab): "quizLibrary-\(tab.rawValue)"
        case .quizSession: "quizSession"
        case .quizSetup: "quizSetup"
        case .quotes: "quotes"
        case let .saveToCollection(code, _): "saveToCollection-\(code)"
        case .search: "search"
        case .settings: "settings"
        case .signIn: "signIn"
        case .speedRunSession(let region): "speedRunSession-\(region.rawValue)"
        case .speedRunSetup: "speedRunSetup"
        case .srsStudy: "srsStudy"
        case .territorialDisputes: "territorialDisputes"
        case .themes: "themes"
        case .timeline: "timeline"
        case .timeZones: "timeZones"
        case .travelStatusPicker(let country): "travelStatusPicker-\(country.code)"
        case .travelMap: "travelMap"
        case .travelTracker: "travelTracker"
        case .wordSearch: "wordSearch"
        case .wordSearchGame(let theme): "wordSearchGame-\(theme.rawValue)"
        case .worldFacts(let topic): "worldFacts-\(topic.rawValue)"
        }
    }
}
