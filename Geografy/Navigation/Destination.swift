import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Country
import Geografy_Feature_Discover
import Geografy_Feature_Map
import Geografy_Feature_Play
import Geografy_Feature_Profile
import Geografy_Feature_Travel
import SwiftUI

// MARK: - Content
@MainActor
extension Destination {
    @ViewBuilder
    var content: some View {
        switch self {
        case .achievementDetail(let definition): AchievementDetailView(definition: definition)
        case .achievements: AchievementsScreen()
        case .collectionDetail(let name): CollectionDetailScreen(collectionName: name)
        case .compare(let country): CompareScreen(preselectedCountry: country)
        case .continents: ContinentsScreen()
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
        case let .flashcardSession(deck, cards): FlashcardSessionScreen(deck: deck, cards: cards)
        case .historicalMap(let year): HistoricalMapScreen(initialYear: year)
        case .learningPath: LearningPathScreen()
        case .learningModule(let module): ModuleLessonsScreen(module: module)
        case let .lesson(module, lesson): LessonScreen(module: module, lesson: lesson)
        case .leaderboards: LeaderboardScreen()
        case .map(let filter): MapScreen(continentFilter: filter?.displayName)
        case .mapColors: MapColorsScreen()
        case .mapPuzzle: MapPuzzleSetupScreen()
        case .pinDrop: PinDropSetupScreen()
        case .multiplayer: LocalMultiplayerEntryScreen()
        case .neighborExplorer(let country): NeighborExplorerScreen(country: country)
        case .organizationDetail(let org): OrganizationDetailScreen(organization: org)
        case .organizationMap(let org): OrganizationMapScreen(organization: org)
        case .organizations: OrganizationsScreen()
        case .profile: ProfileScreen()
        case .quizPackDetail(let packID): QuizPackDetailScreen(packID: packID)
        case .quizLibrary(let tab): QuizLibraryScreen(tab: tab)
        case .quizSession(let config): QuizSessionScreen(configuration: config)
        case .quizSetup: QuizSetupScreen()
        case let .saveToCollection(code, name): CountrySaveToCollectionSheet(countryCode: code, countryName: name)
        case .search: SearchScreen()
        case .settings: SettingsScreen()
        case .signIn: SignInOptionsSheet()
        case .speedRunSession(let region): SpeedRunSessionScreen(region: region)
        case .speedRunSetup: SpeedRunSetupScreen()
        case .srsStudy: SRSStudyScreen()
        case .storage: StorageScreen()
        case .territorialDisputes: TerritorialDisputesScreen()
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
