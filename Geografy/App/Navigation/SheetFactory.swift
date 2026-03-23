import SwiftUI

@MainActor
enum SheetFactory {
    @ViewBuilder
    static func view(for sheet: Sheet) -> some View {
        switch sheet {
        case .signIn, .profile, .countries, .favorites, .organizations,
             .organizationDetail, .coinStore, .paywall:
            coreView(for: sheet)

        case .quizSetup, .speedRunSetup, .capitalQuiz, .exploreGame,
             .multiplayer, .quizPacks, .customQuiz, .dailyChallenge,
             .srsStudy, .flagGame, .geoTrivia, .spellingBee, .landmarkQuiz:
            playView(for: sheet)

        case .distanceCalculator, .currencyConverter, .timeZones,
             .compare, .timeline, .travelTracker, .travelJournal, .travelBucketList,
             .nationalSymbolsQuiz, .wordSearch, .borderChallenge:
            exploreView(for: sheet)

        case .badges, .leaderboards, .achievements, .themes, .settings,
             .sectionEditor, .friends, .search, .geoFeed:
            appView(for: sheet)

        case .challengeRoom:
            challengeView(for: sheet)

        case .geoQuotes, .countryNicknames:
            discoverView(for: sheet)
        }
    }
}

// MARK: - Core

private extension SheetFactory {
    @ViewBuilder
    static func coreView(for sheet: Sheet) -> some View {
        switch sheet {
        case .signIn:
            SignInOptionsSheet()

        case .profile:
            NavigationStack { ProfileScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .countries:
            NavigationStack {
                CountryListScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .favorites:
            NavigationStack {
                FavoritesScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .organizations:
            NavigationStack { OrganizationsScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .organizationDetail(let organization):
            NavigationStack {
                OrganizationDetailScreen(organization: organization)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .coinStore:
            NavigationStack { CoinStoreScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .paywall:
            PaywallScreen()

        default:
            EmptyView()
        }
    }
}

// MARK: - Play

private extension SheetFactory {
    @ViewBuilder
    static func playView(for sheet: Sheet) -> some View {
        switch sheet {
        case .quizSetup:
            NavigationStack { QuizSetupScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .speedRunSetup:
            NavigationStack { SpeedRunSetupScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .dailyChallenge:
            NavigationStack { DailyChallengeScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .capitalQuiz:
            NavigationStack { CapitalQuizSetupScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .exploreGame:
            NavigationStack { ExploreGameScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .multiplayer:
            NavigationStack {
                MultiplayerLobbyScreen(multiplayerService: MultiplayerService())
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .quizPacks:
            NavigationStack { QuizPackBrowserScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .customQuiz:
            NavigationStack { CustomQuizLibraryScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .srsStudy:
            NavigationStack { SRSStudyScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .flagGame:
            NavigationStack { FlagGameScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .geoTrivia:
            NavigationStack { GeoTriviaScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .spellingBee:
            NavigationStack { SpellingBeeScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .landmarkQuiz:
            NavigationStack { LandmarkQuizScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        default:
            EmptyView()
        }
    }
}

// MARK: - Explore

private extension SheetFactory {
    @ViewBuilder
    static func exploreView(for sheet: Sheet) -> some View {
        switch sheet {
        case .distanceCalculator:
            NavigationStack { DistanceCalculatorScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .currencyConverter:
            NavigationStack { CurrencyConverterScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .timeZones:
            NavigationStack { TimeZoneScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .compare:
            NavigationStack { CompareScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .timeline:
            NavigationStack { TimelineScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .travelTracker:
            NavigationStack {
                TravelTrackerScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .travelJournal:
            NavigationStack { TravelJournalScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .travelBucketList:
            NavigationStack { TravelBucketListScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .nationalSymbolsQuiz:
            NavigationStack { NationalSymbolsQuizScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .wordSearch:
            NavigationStack { WordSearchScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .borderChallenge:
            NavigationStack { BorderChallengeScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        default:
            EmptyView()
        }
    }
}

// MARK: - App

private extension SheetFactory {
    @ViewBuilder
    static func appView(for sheet: Sheet) -> some View {
        switch sheet {
        case .search:
            NavigationStack { SearchScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .badges:
            NavigationStack {
                BadgeCollectionScreen(badgeService: BadgeService())
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .leaderboards:
            NavigationStack { LeaderboardScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .achievements:
            NavigationStack {
                AchievementsScreen()
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.large)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .themes:
            NavigationStack {
                ThemesScreen()
                    .navigationTitle("Themes")
                    .navigationBarTitleDisplayMode(.large)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)

        case .settings:
            NavigationStack { SettingsScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .sectionEditor:
            HomeSectionEditorSheet(sections: HomeSection.allCases.map { $0 })

        case .friends:
            NavigationStack { FriendsListScreen() }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)

        case .geoFeed:
            NavigationStack { GeoFeedScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        default:
            EmptyView()
        }
    }
}

// MARK: - Challenge

private extension SheetFactory {
    @ViewBuilder
    static func challengeView(for sheet: Sheet) -> some View {
        switch sheet {
        case .challengeRoom:
            NavigationStack { ChallengeSetupScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        default:
            EmptyView()
        }
    }
}

// MARK: - Discover

private extension SheetFactory {
    @ViewBuilder
    static func discoverView(for sheet: Sheet) -> some View {
        switch sheet {
        case .geoQuotes:
            NavigationStack { GeoQuotesScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        case .countryNicknames:
            NavigationStack { CountryNicknamesScreen() }
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
                .presentationDragIndicator(.visible)

        default:
            EmptyView()
        }
    }
}
