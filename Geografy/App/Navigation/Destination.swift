import SwiftUI
import GeografyCore

// MARK: - Presentation Style
enum PresentationStyle {
    case push
    case sheet
    case fullScreenCover
}

// MARK: - Destination
enum Destination: Hashable, Identifiable {
    // Push destinations
    case map(continentFilter: Country.Continent? = nil)
    case countryDetail(Country)
    case organizationDetail(Organization)
    case allMaps
    case continentOverview(Country.Continent)
    case achievements
    case themes
    case settings
    case quizSetup
    case neighborExplorer(Country)
    case worldRecords
    case learningPath
    case mapPuzzle
    case continentPicker
    case continentStats(String)
    case oceanExplorer
    case languageExplorer
    case independenceTimeline
    case economyExplorer
    case geographyFeatures
    case cultureExplorer
    case landmarkGallery
    case mapColoring
    case territorialDisputes
    case lesson(LearningModule, Lesson)
    case challengeResult(ChallengeRoom)
    case dailyChallengeResult(
        score: Int,
        maxScore: Int,
        challengeType: DailyChallengeType,
        timeSpent: TimeInterval,
        streak: Int
    )

    // Sheet destinations
    case signIn
    case profile
    case countries
    case favorites
    case organizations
    case coinStore
    case paywall
    case speedRunSetup
    case dailyChallenge
    case exploreGame
    case multiplayer
    case quizPacks
    case customQuiz
    case distanceCalculator
    case currencyConverter
    case timeZones
    case compare
    case timeline
    case travelTracker
    case travelJournal
    case travelBucketList
    case leaderboards
    case search
    case srsStudy
    case flagGame
    case trivia
    case spellingBee
    case landmarkQuiz
    case feed
    case challengeRoom
    case quotes
    case countryNicknames
    case wordSearch
    case borderChallenge
    case localMultiplayer
    case sectionEditor
    case friends

    // Full screen cover destinations
    case mapFullScreen(continentFilter: String?)
    case quizSession(QuizConfiguration)
    case flashcardSession(deck: FlashcardDeck, cards: [FlashcardItem])
    case travelMap(TravelMapFilter)
    case historicalMap(initialYear: Int)
    case speedRunSession(region: QuizRegion)

    var id: String {
        switch self {
        // Push
        case .map(let filter): "map-\(filter?.rawValue ?? "world")"
        case .countryDetail(let country): "countryDetail-\(country.code)"
        case .organizationDetail(let organization): "orgDetail-\(organization.id)"
        case .allMaps: "allMaps"
        case .continentOverview(let continent): "continentOverview-\(continent.rawValue)"
        case .achievements: "achievements"
        case .themes: "themes"
        case .settings: "settings"
        case .quizSetup: "quizSetup"
        case .neighborExplorer(let country): "neighborExplorer-\(country.code)"
        case .worldRecords: "worldRecords"
        case .learningPath: "learningPath"
        case .mapPuzzle: "mapPuzzle"
        case .continentPicker: "continentPicker"
        case .continentStats(let name): "continentStats-\(name)"
        case .oceanExplorer: "oceanExplorer"
        case .languageExplorer: "languageExplorer"
        case .independenceTimeline: "independenceTimeline"
        case .economyExplorer: "economyExplorer"
        case .geographyFeatures: "geographyFeatures"
        case .cultureExplorer: "cultureExplorer"
        case .landmarkGallery: "landmarkGallery"
        case .mapColoring: "mapColoring"
        case .territorialDisputes: "territorialDisputes"
        case .lesson(let module, let lesson): "lesson-\(module.id)-\(lesson.id)"
        case .challengeResult: "challengeResult"
        case .dailyChallengeResult: "dailyChallengeResult"

        // Sheet
        case .signIn: "signIn"
        case .profile: "profile"
        case .countries: "countries"
        case .favorites: "favorites"
        case .organizations: "organizations"
        case .coinStore: "coinStore"
        case .paywall: "paywall"
        case .speedRunSetup: "speedRunSetup"
        case .dailyChallenge: "dailyChallenge"
        case .exploreGame: "exploreGame"
        case .multiplayer: "multiplayer"
        case .quizPacks: "quizPacks"
        case .customQuiz: "customQuiz"
        case .distanceCalculator: "distanceCalculator"
        case .currencyConverter: "currencyConverter"
        case .timeZones: "timeZones"
        case .compare: "compare"
        case .timeline: "timeline"
        case .travelTracker: "travelTracker"
        case .travelJournal: "travelJournal"
        case .travelBucketList: "travelBucketList"
        case .leaderboards: "leaderboards"
        case .search: "search"
        case .srsStudy: "srsStudy"
        case .flagGame: "flagGame"
        case .trivia: "trivia"
        case .spellingBee: "spellingBee"
        case .landmarkQuiz: "landmarkQuiz"
        case .feed: "feed"
        case .challengeRoom: "challengeRoom"
        case .quotes: "quotes"
        case .countryNicknames: "countryNicknames"
        case .wordSearch: "wordSearch"
        case .borderChallenge: "borderChallenge"
        case .localMultiplayer: "localMultiplayer"
        case .sectionEditor: "sectionEditor"
        case .friends: "friends"

        // Full screen cover
        case .mapFullScreen(let filter): "mapFullScreen-\(filter ?? "world")"
        case .quizSession: "quizSession"
        case .flashcardSession: "flashcardSession"
        case .travelMap: "travelMap"
        case .historicalMap(let year): "historicalMap-\(String(year))"
        case .speedRunSession(let region): "speedRunSession-\(region.rawValue)"
        }
    }
}

// MARK: - Presentation Style
extension Destination {
    var presentationStyle: PresentationStyle {
        switch self {
        // Push destinations
        case .map, .countryDetail, .organizationDetail, .allMaps, .continentOverview,
             .achievements, .themes, .settings, .quizSetup, .neighborExplorer,
             .worldRecords, .learningPath, .mapPuzzle, .continentPicker, .continentStats,
             .oceanExplorer, .languageExplorer, .independenceTimeline, .economyExplorer,
             .geographyFeatures, .cultureExplorer, .landmarkGallery, .mapColoring,
             .territorialDisputes, .lesson, .challengeResult, .dailyChallengeResult:
            .push

        // Full screen cover destinations
        case .mapFullScreen, .quizSession, .flashcardSession, .travelMap,
             .historicalMap, .speedRunSession:
            .fullScreenCover

        // Sheet destinations (everything else)
        default:
            .sheet
        }
    }

    var disableInteractiveDismiss: Bool {
        switch self {
        case .flagGame, .trivia, .spellingBee, .landmarkQuiz,
             .wordSearch, .borderChallenge, .challengeRoom,
             .localMultiplayer:
            true
        default:
            false
        }
    }
}

// MARK: - Content
@MainActor
extension Destination {
    @ViewBuilder
    var content: some View {
        switch self {
        // Push — core
        case .map(let continentFilter):
            MapScreen(continentFilter: continentFilter?.rawValue)
        case .countryDetail(let country):
            CountryDetailScreen(country: country)
        case .organizationDetail(let organization):
            OrganizationDetailScreen(organization: organization)
        case .allMaps:
            AllMapsScreen()
        case .continentOverview(let continent):
            ContinentOverviewScreen(continent: continent)
        case .achievements:
            AchievementsScreen()
        case .themes:
            ThemesScreen()
        case .settings:
            SettingsScreen()
        case .quizSetup:
            QuizSetupScreen()
        case .neighborExplorer(let country):
            NeighborExplorerScreen(country: country)

        // Push — explore
        case .worldRecords:
            WorldRecordsScreen()
        case .learningPath:
            LearningPathScreen()
        case .mapPuzzle:
            MapPuzzleSetupScreen()
        case .continentPicker:
            ContinentPickerScreen()
        case .continentStats(let continentName):
            ContinentStatsScreen(continentName: continentName)
        case .oceanExplorer:
            OceanExplorerScreen()
        case .languageExplorer:
            LanguageExplorerScreen()
        case .independenceTimeline:
            IndependenceTimelineScreen()

        // Push — discover
        case .economyExplorer:
            EconomyExplorerScreen()
        case .geographyFeatures:
            GeographyFeaturesScreen()
        case .cultureExplorer:
            CultureExplorerScreen()
        case .landmarkGallery:
            LandmarkGalleryScreen()
        case .mapColoring:
            MapColoringScreen()
        case .territorialDisputes:
            TerritorialDisputesScreen()
        case .lesson(let module, let lesson):
            LessonScreen(module: module, lesson: lesson)

        // Push — results
        case .challengeResult(let room):
            ChallengeResultScreen(room: room, onPlayAgain: nil)
        case .dailyChallengeResult(let score, let maxScore, let challengeType, let timeSpent, let streak):
            DailyChallengeResultView(
                score: score,
                maxScore: maxScore,
                challengeType: challengeType,
                timeSpent: timeSpent,
                streak: streak
            )

        // Sheet — auth
        case .signIn:
            SignInOptionsSheet()

        // Sheet — paywall
        case .paywall:
            PaywallScreen()

        // Sheet — section editor
        case .sectionEditor:
            HomeSectionEditorSheet(sections: HomeSection.allCases.map { $0 })

        // Sheet — core content
        case .profile:
            ProfileScreen()
        case .countries:
            CountryListScreen()
        case .favorites:
            FavoritesScreen()
        case .organizations:
            OrganizationsScreen()
        case .coinStore:
            CoinStoreScreen()

        // Sheet — play modes
        case .speedRunSetup:
            SpeedRunSetupScreen()
        case .dailyChallenge:
            DailyChallengeScreen()
        case .exploreGame:
            ExploreGameScreen()
        case .multiplayer:
            MultiplayerLobbyScreen(multiplayerService: MultiplayerService())
        case .quizPacks:
            QuizPackBrowserScreen()
        case .customQuiz:
            CustomQuizLibraryScreen()
        case .srsStudy:
            SRSStudyScreen()
        case .flagGame:
            FlagGameScreen()
        case .trivia:
            TriviaScreen()
        case .spellingBee:
            SpellingBeeScreen()
        case .landmarkQuiz:
            LandmarkQuizScreen()

        // Sheet — tools
        case .distanceCalculator:
            DistanceCalculatorScreen()
        case .currencyConverter:
            CurrencyConverterScreen()
        case .timeZones:
            TimeZoneScreen()
        case .compare:
            CompareScreen()
        case .timeline:
            TimelineScreen()

        // Sheet — travel
        case .travelTracker:
            TravelTrackerScreen()
        case .travelJournal:
            TravelJournalScreen()
        case .travelBucketList:
            TravelBucketListScreen()

        // Sheet — app
        case .search:
            SearchScreen()
        case .leaderboards:
            LeaderboardScreen()
        case .feed:
            FeedScreen()
        case .challengeRoom:
            ChallengeSetupScreen()
        case .quotes:
            QuotesScreen()
        case .countryNicknames:
            CountryNicknamesScreen()
        case .localMultiplayer:
            LocalMultiplayerEntryScreen()
        case .wordSearch:
            WordSearchScreen()
        case .borderChallenge:
            BorderChallengeScreen()
        case .friends:
            FriendsListScreen()

        // Full screen cover
        case .mapFullScreen(let continentFilter):
            MapScreen(continentFilter: continentFilter)
        case .quizSession(let configuration):
            QuizSessionScreen(configuration: configuration)
        case .flashcardSession(let deck, let cards):
            FlashcardSessionScreen(deck: deck, cards: cards)
        case .travelMap(let filter):
            TravelMapScreen(filter: filter)
        case .historicalMap(let initialYear):
            HistoricalMapScreen(initialYear: initialYear)
        case .speedRunSession(let region):
            SpeedRunSessionScreen(region: region)
        }
    }
}
