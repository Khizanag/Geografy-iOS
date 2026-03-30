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

        case .friends:
            NavigatorView(canBeDismissed: false) {
                FriendsListScreen()
            }
            .presentationDetents([.large])

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
        case .profile, .countries, .favorites, .organizations,
             .organizationDetail, .countryDetail, .coinStore:
            coreContent(for: sheet)

        case .quizSetup, .speedRunSetup, .dailyChallenge, .exploreGame,
             .multiplayer, .quizPacks, .customQuiz, .srsStudy,
             .flagGame, .trivia, .spellingBee, .landmarkQuiz:
            playContent(for: sheet)

        case .distanceCalculator, .currencyConverter, .timeZones, .compare,
             .timeline, .travelTracker, .travelJournal, .travelBucketList,
             .wordSearch, .borderChallenge:
            exploreContent(for: sheet)

        case .search, .leaderboards, .achievements, .themes,
             .settings, .learningPath, .feed,
             .challengeRoom, .quotes, .countryNicknames, .localMultiplayer:
            appContent(for: sheet)

        default: EmptyView()
        }
    }
}

// MARK: - Core Content
private extension SheetFactory {
    @ViewBuilder
    static func coreContent(for sheet: Sheet) -> some View {
        switch sheet {
        case .profile: ProfileScreen()
        case .countries: CountryListScreen()
        case .favorites: FavoritesScreen()
        case .organizations: OrganizationsScreen()
        case .organizationDetail(let organization): OrganizationDetailScreen(organization: organization)
        case .countryDetail(let country): CountryDetailScreen(country: country)
        case .coinStore: CoinStoreScreen()
        default: EmptyView()
        }
    }
}

// MARK: - Play Content
private extension SheetFactory {
    @ViewBuilder
    static func playContent(for sheet: Sheet) -> some View {
        switch sheet {
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
        default: EmptyView()
        }
    }
}

// MARK: - Explore Content
private extension SheetFactory {
    @ViewBuilder
    static func exploreContent(for sheet: Sheet) -> some View {
        switch sheet {
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
        default: EmptyView()
        }
    }
}

// MARK: - App Content
private extension SheetFactory {
    @ViewBuilder
    static func appContent(for sheet: Sheet) -> some View {
        switch sheet {
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
        case .learningPath: LearningPathScreen()
        case .feed: FeedScreen()
        case .challengeRoom: ChallengeSetupScreen()
        case .quotes: QuotesScreen()
        case .countryNicknames: CountryNicknamesScreen()
        case .localMultiplayer: LocalMultiplayerEntryScreen()
        default: EmptyView()
        }
    }
}

// MARK: - Sheet Config
extension Sheet {
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
