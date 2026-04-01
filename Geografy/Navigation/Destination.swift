import GeografyCore
import SwiftUI

// MARK: - Destination
enum Destination: Hashable, Identifiable {
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
    case spellingBee
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

    var id: String {
        switch self {
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
        case .lesson(let module, let lesson): "lesson-\(module.id)-\(lesson.id)"
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
        case .spellingBee: "spellingBee"
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

// MARK: - Content
@MainActor
extension Destination {
    @ViewBuilder
    var content: some View {
        switch self {
        case .achievements: AchievementsScreen()
        case .allMaps: AllMapsScreen()
        case .borderChallenge: BorderChallengeScreen()
        case .coinStore: CoinStoreScreen()
        case .compare(let country): CompareScreen(preselectedCountry: country)
        case .continentOverview(let continent): ContinentOverviewScreen(continent: continent)
        case .continentPicker: ContinentPickerScreen()
        case .continentStats(let name): ContinentStatsScreen(continentName: name)
        case .countries: CountryListScreen()
        case .countryDetail(let country): CountryDetailScreen(country: country)
        case .countryNicknames: CountryNicknamesScreen()
        case .countryNicknameQuiz: NicknameQuizScreen()
        case .cultureExplorer: CultureExplorerScreen()
        case .currencyConverter(let code): CurrencyConverterScreen(preselectedCurrencyCode: code)
        case .customQuiz: CustomQuizLibraryScreen()
        case .customQuizShare(let quiz): CustomQuizShareScreen(quiz: quiz)
        case .dailyChallenge: DailyChallengeScreen()
        case .dailyChallengeResult(let score, let maxScore, let type, let time, let streak):
            DailyChallengeResultView(
                score: score, maxScore: maxScore, challengeType: type, timeSpent: time, streak: streak
            )
        case .editProfile: EditProfileSheet()
        case .distanceCalculator: DistanceCalculatorScreen()
        case .economyExplorer: EconomyExplorerScreen()
        case .exploreGame: ExploreGameScreen()
        case .favorites: FavoritesScreen()
        case .featureFlags: FeatureFlagsScreen()
        case .feed: FeedScreen()
        case .flagGame: FlagGameScreen()
        case .flashcardSession(let deck, let cards): FlashcardSessionScreen(deck: deck, cards: cards)
        case .friends: FriendsListScreen()
        case .geographyFeatures: GeographyFeaturesScreen()
        case .historicalMap(let year): HistoricalMapScreen(initialYear: year)
        case .independenceTimeline: IndependenceTimelineScreen()
        case .landmarkGallery: LandmarkGalleryScreen()
        case .landmarkQuiz: LandmarkQuizScreen()
        case .languageExplorer: LanguageExplorerScreen()
        case .learningPath: LearningPathScreen()
        case .lesson(let module, let lesson): LessonScreen(module: module, lesson: lesson)
        case .leaderboards: LeaderboardScreen()
        case .localMultiplayer: LocalMultiplayerEntryScreen()
        case .map(let filter): MapScreen(continentFilter: filter?.rawValue)
        case .mapColoring: MapColoringScreen()
        case .mapFullScreen(let filter): MapScreen(continentFilter: filter)
        case .mapPuzzle: MapPuzzleSetupScreen()
        case .multiplayer: MultiplayerLobbyScreen(multiplayerService: MultiplayerService())
        case .neighborExplorer(let country): NeighborExplorerScreen(country: country)
        case .oceanExplorer: OceanExplorerScreen()
        case .organizationDetail(let org): OrganizationDetailScreen(organization: org)
        case .organizationMap(let org): OrganizationMapScreen(organization: org)
        case .organizations: OrganizationsScreen()
        case .paywall: PaywallScreen()
        case .profile: ProfileScreen()
        case .quizPacks: QuizPackBrowserScreen()
        case .quizSession(let config): QuizSessionScreen(configuration: config)
        case .quizSetup: QuizSetupScreen()
        case .quotes: QuotesScreen()
        case .search: SearchScreen()
        case .sectionEditor: HomeSectionEditorSheet(sections: HomeSection.allCases.map { $0 })
        case .settings: SettingsScreen()
        case .signIn: SignInOptionsSheet()
        case .speedRunSession(let region): SpeedRunSessionScreen(region: region)
        case .speedRunSetup: SpeedRunSetupScreen()
        case .spellingBee: SpellingBeeScreen()
        case .srsStudy: SRSStudyScreen()
        case .territorialDisputes: TerritorialDisputesScreen()
        case .themes: ThemesScreen()
        case .timeline: TimelineScreen()
        case .timeZones: TimeZoneScreen()
        case .travelBucketList: TravelBucketListScreen()
        case .travelJournal: TravelJournalScreen()
        case .travelMap(let filter): TravelMapScreen(filter: filter)
        case .travelTracker: TravelTrackerScreen()
        case .trivia: TriviaScreen()
        case .wordSearch: WordSearchScreen()
        case .wordSearchGame(let theme): WordSearchGameScreen(theme: theme)
        case .worldRecords: WorldRecordsScreen()
        }
    }
}
