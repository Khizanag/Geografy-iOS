import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Achievement
import Geografy_Feature_AllMap
import Geografy_Feature_Auth
import Geografy_Feature_BorderChallenge
import Geografy_Feature_Coin
import Geografy_Feature_Compare
import Geografy_Feature_ContinentStats
import Geografy_Feature_CountryDetail
import Geografy_Feature_CountryList
import Geografy_Feature_CountryNicknames
import Geografy_Feature_CultureExplorer
import Geografy_Feature_CurrencyConverter
import Geografy_Feature_CustomQuiz
import Geografy_Feature_DailyChallenge
import Geografy_Feature_DistanceCalculator
import Geografy_Feature_EconomyExplorer
import Geografy_Feature_ExploreGame
import Geografy_Feature_Favorite
import Geografy_Feature_Feed
import Geografy_Feature_FlagGame
import Geografy_Feature_Flashcard
import Geografy_Feature_GameCenter
import Geografy_Feature_GeographyFeatures
import Geografy_Feature_IndependenceTimeline
import Geografy_Feature_LandmarkGallery
import Geografy_Feature_LandmarkQuiz
import Geografy_Feature_LanguageExplorer
import Geografy_Feature_LearningPath
import Geografy_Feature_Map
import Geografy_Feature_MapColoring
import Geografy_Feature_MapPuzzle
import Geografy_Feature_Multiplayer
import Geografy_Feature_NationalSymbols
import Geografy_Feature_NeighborExplorer
import Geografy_Feature_OceanExplorer
import Geografy_Feature_Organization
import Geografy_Feature_Profile
import Geografy_Feature_Quiz
import Geografy_Feature_QuizPack
import Geografy_Feature_Quotes
import Geografy_Feature_Search
import Geografy_Feature_Setting
import Geografy_Feature_SizeVisualization
import Geografy_Feature_Subscription
import Geografy_Feature_Theme
import Geografy_Feature_Timeline
import Geografy_Feature_TimeZone
import Geografy_Feature_Travel
import Geografy_Feature_TravelJournal
import Geografy_Feature_Trivia
import Geografy_Feature_WordSearch
import Geografy_Feature_WorldRecords
import SwiftUI

// MARK: - Content
@MainActor
extension Destination {
    private static let multiplayerService = MultiplayerService()

    @ViewBuilder
    var content: some View {
        switch self {
        case .achievementDetail(let definition): AchievementDetailView(definition: definition)
        case .achievements: AchievementsScreen()
        case .allMaps: AllMapsScreen()
        case .borderChallenge: BorderChallengeScreen()
        case .collectionDetail(let name): CollectionDetailScreen(collectionName: name)
        case .collections: CollectionsScreen()
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
        case let .dailyChallengeResult(score, maxScore, type, time, streak):
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
        case let .flashcardSession(deck, cards): FlashcardSessionScreen(deck: deck, cards: cards)
        case .friends: FriendsListScreen()
        case .geographyFeatures: GeographyFeaturesScreen()
        case .historicalMap(let year): HistoricalMapScreen(initialYear: year)
        case .independenceTimeline: IndependenceTimelineScreen()
        case .landmarkGallery: LandmarkGalleryScreen()
        case .landmarkQuiz: LandmarkQuizScreen()
        case .languageExplorer: LanguageExplorerScreen()
        case .learningPath: LearningPathScreen()
        case let .lesson(module, lesson): LessonScreen(module: module, lesson: lesson)
        case .leaderboards: LeaderboardScreen()
        case .localMultiplayer: LocalMultiplayerEntryScreen()
        case .map(let filter): MapScreen(continentFilter: filter?.rawValue)
        case .mapColoring: MapColoringScreen()
        case .mapFullScreen(let filter): MapScreen(continentFilter: filter)
        case .mapPuzzle: MapPuzzleSetupScreen()
        case .multiplayer: MultiplayerLobbyScreen(multiplayerService: Self.multiplayerService)
        case .neighborExplorer(let country): NeighborExplorerScreen(country: country)
        case .oceanExplorer: OceanExplorerScreen()
        case .organizationDetail(let org): OrganizationDetailScreen(organization: org)
        case .organizationMap(let org): OrganizationMapScreen(organization: org)
        case .organizations: OrganizationsScreen()
        case .paywall: PaywallScreen()
        case .profile: ProfileScreen()
        case .quizPackDetail(let packID): QuizPackDetailScreen(packID: packID)
        case .quizPacks: QuizPackBrowserScreen()
        case .quizSession(let config): QuizSessionScreen(configuration: config)
        case .quizSetup: QuizSetupScreen()
        case .quotes: QuotesScreen()
        case let .saveToCollection(code, name): CountrySaveToCollectionSheet(countryCode: code, countryName: name)
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
