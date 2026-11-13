import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Achievement
import Geografy_Feature_Auth
import Geografy_Feature_Compare
import Geografy_Feature_CountryDetail
import Geografy_Feature_CountryList
import Geografy_Feature_CurrencyConverter
import Geografy_Feature_DailyChallenge
import Geografy_Feature_DistanceCalculator
import Geografy_Feature_Favorite
import Geografy_Feature_Feed
import Geografy_Feature_Flashcard
import Geografy_Feature_GameCenter
import Geografy_Feature_LearningPath
import Geografy_Feature_Map
import Geografy_Feature_MapColoring
import Geografy_Feature_MapPuzzle
import Geografy_Feature_Multiplayer
import Geografy_Feature_NationalSymbols
import Geografy_Feature_NeighborExplorer
import Geografy_Feature_Organization
import Geografy_Feature_Profile
import Geografy_Feature_Quiz
import Geografy_Feature_QuizLibrary
import Geografy_Feature_Quotes
import Geografy_Feature_Search
import Geografy_Feature_Setting
import Geografy_Feature_SizeVisualization
import Geografy_Feature_Theme
import Geografy_Feature_Timeline
import Geografy_Feature_TimeZone
import Geografy_Feature_Travel
import Geografy_Feature_WordSearch
import Geografy_Feature_WorldFacts
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
        case .allMaps: AllMapsScreen().navigationTitle("All Maps").navigationBarTitleDisplayMode(.inline)
        case .collectionDetail(let name): CollectionDetailScreen(collectionName: name)
        case .compare(let country): CompareScreen(preselectedCountry: country)
        case .continentOverview(let continent): ContinentOverviewScreen(continent: continent)
        case .countries: CountryListScreen().navigationTitle("Countries").navigationBarTitleDisplayMode(.inline)
        case .countryDetail(let country): CountryDetailScreen(country: country)
        case .currencyConverter(let code): CurrencyConverterScreen(preselectedCurrencyCode: code)
        case .customQuizShare(let quiz): CustomQuizShareScreen(quiz: quiz)
        case .dailyChallenge: DailyChallengeScreen()
        case let .dailyChallengeResult(score, maxScore, type, time, streak):
            DailyChallengeResultView(
                score: score, maxScore: maxScore, challengeType: type, timeSpent: time, streak: streak
            )
        case .editProfile: EditProfileSheet()
        case .distanceCalculator: DistanceCalculatorScreen()
        case .saved(let tab): SavedScreen(tab: tab)
        case .feed: FeedScreen()
        case let .flashcardSession(deck, cards): FlashcardSessionScreen(deck: deck, cards: cards)
        case .friends: FriendsListScreen()
        case .historicalMap(let year): HistoricalMapScreen(initialYear: year)
        case .learningPath: LearningPathScreen()
        case .learningModule(let module): ModuleLessonsScreen(module: module)
        case let .lesson(module, lesson): LessonScreen(module: module, lesson: lesson)
        case .leaderboards: LeaderboardScreen()
        case .localMultiplayer: LocalMultiplayerEntryScreen()
        case .map(let filter): MapScreen(continentFilter: filter?.rawValue)
        case .mapColoring: MapColoringScreen()
        case .mapFullScreen(let filter): MapScreen(continentFilter: filter)
        case .mapPuzzle: MapPuzzleSetupScreen()
        case .multiplayer: MultiplayerLobbyScreen(multiplayerService: Self.multiplayerService)
        case .neighborExplorer(let country): NeighborExplorerScreen(country: country)
        case .organizationDetail(let org): OrganizationDetailScreen(organization: org)
        case .organizationMap(let org): OrganizationMapScreen(organization: org)
        case .organizations: OrganizationsScreen()
        case .profile: ProfileScreen()
        case .quizPackDetail(let packID): QuizPackDetailScreen(packID: packID)
        case .quizLibrary(let tab): QuizLibraryScreen(tab: tab)
        case .quizSession(let config): QuizSessionScreen(configuration: config)
        case .quizSetup: QuizSetupScreen()
        case .quotes: QuotesScreen()
        case let .saveToCollection(code, name): CountrySaveToCollectionSheet(countryCode: code, countryName: name)
        case .search: SearchScreen()
        case .settings: SettingsScreen()
        case .signIn: SignInOptionsSheet()
        case .speedRunSession(let region): SpeedRunSessionScreen(region: region)
        case .speedRunSetup: SpeedRunSetupScreen()
        case .srsStudy: SRSStudyScreen()
        case .territorialDisputes: TerritorialDisputesScreen()
        case .themes: ThemesScreen()
        case .timeline: TimelineScreen()
        case .timeZones: TimeZoneScreen()
        case .travelMap(let filter): TravelMapScreen(filter: filter)
        case .travelTracker: TravelScreen()
        case .wordSearch: WordSearchScreen()
        case .wordSearchGame(let theme): WordSearchGameScreen(theme: theme)
        case .worldFacts(let topic): WorldFactsScreen(topic: topic)
        }
    }
}
