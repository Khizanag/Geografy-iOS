import SwiftUI

@MainActor
enum SheetFactory {
    @ViewBuilder
    static func view(for sheet: Sheet) -> some View {
        switch sheet {
        case .signIn:
            SignInOptionsSheet()

        case .paywall:
            PaywallScreen()

        case .sectionEditor:
            HomeSectionEditorSheet(sections: HomeSection.allCases.map { $0 })

        default:
            NavigatorView {
                sheetContent(for: sheet)
            }
            .presentationDetents([.large])
            .interactiveDismissDisabled(sheet.disableInteractiveDismiss)
        }
    }
}

// MARK: - Sheet Content
private extension SheetFactory {
    @ViewBuilder
    static func sheetContent(for sheet: Sheet) -> some View {
        switch sheet {
        // Core
        case .profile: ProfileScreen()
        case .countries: CountryListScreen()
        case .favorites: FavoritesScreen()
        case .organizations: OrganizationsScreen()
        case .organizationDetail(let organization): OrganizationDetailScreen(organization: organization)
        case .countryDetail(let country): CountryDetailScreen(country: country)
        case .coinStore: CoinStoreScreen()

        // Play
        case .quizSetup: QuizSetupScreen()
        case .speedRunSetup: SpeedRunSetupScreen()
        case .dailyChallenge: DailyChallengeScreen()
        case .exploreGame: ExploreGameScreen()
        case .multiplayer: MultiplayerLobbyScreen(multiplayerService: MultiplayerService())
        case .quizPacks: QuizPackBrowserScreen()
        case .customQuiz: CustomQuizLibraryScreen()
        case .srsStudy: SRSStudyScreen()
        case .flagGame: FlagGameScreen()
        case .trivia: TriviaScreen()
        case .spellingBee: SpellingBeeScreen()
        case .landmarkQuiz: LandmarkQuizScreen()

        // Explore
        case .distanceCalculator: DistanceCalculatorScreen()
        case .currencyConverter: CurrencyConverterScreen()
        case .timeZones: TimeZoneScreen()
        case .compare: CompareScreen()
        case .timeline: TimelineScreen()
        case .travelTracker: TravelTrackerScreen()
        case .travelJournal: TravelJournalScreen()
        case .travelBucketList: TravelBucketListScreen()
        case .wordSearch: WordSearchScreen()
        case .borderChallenge: BorderChallengeScreen()

        // App
        case .search: SearchScreen()
        case .leaderboards: LeaderboardScreen()
        case .achievements:
            AchievementsScreen()
                .navigationTitle("Achievements")
                .navigationBarTitleDisplayMode(.large)
        case .themes:
            ThemesScreen()
                .navigationTitle("Themes")
                .navigationBarTitleDisplayMode(.large)
        case .settings: SettingsScreen()
        case .friends: FriendsListScreen()
        case .learningPath: LearningPathScreen()
        case .feed: FeedScreen()

        // Challenge
        case .challengeRoom: ChallengeSetupScreen()

        // Discover
        case .quotes: QuotesScreen()
        case .countryNicknames: CountryNicknamesScreen()

        default: EmptyView()
        }
    }
}

// MARK: - Sheet Config
extension Sheet {
    var disableInteractiveDismiss: Bool {
        switch self {
        case .flagGame, .trivia, .spellingBee, .landmarkQuiz,
             .wordSearch, .borderChallenge, .challengeRoom:
            true
        default:
            false
        }
    }
}
