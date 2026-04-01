import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Quotes
import Geografy_Feature_SizeVisualization
import Geografy_Feature_TimeZone
import SwiftUI

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
