import SwiftUI

@MainActor
enum SheetFactory {
    @ViewBuilder
    static func view(for sheet: Sheet) -> some View {
        switch sheet {
        case .signIn, .profile, .countries, .favorites, .organizations,
             .organizationDetail, .coinStore, .paywall:
            coreView(for: sheet)

        case .quizSetup, .speedRunSetup, .exploreGame,
             .multiplayer, .quizPacks, .customQuiz, .dailyChallenge,
             .srsStudy, .flagGame, .trivia, .spellingBee, .landmarkQuiz:
            playView(for: sheet)

        case .distanceCalculator, .currencyConverter, .timeZones,
             .compare, .timeline, .travelTracker, .travelJournal, .travelBucketList,
             .wordSearch, .borderChallenge:
            exploreView(for: sheet)

        case .badges, .leaderboards, .achievements, .themes, .settings,
             .sectionEditor, .friends, .search, .feed, .learningPath:
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

    

        case .countries:
            NavigationStack {
                CountryListScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])


        case .favorites:
            NavigationStack {
                FavoritesScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])


        case .organizations:
            NavigationStack { OrganizationsScreen() }
                .presentationDetents([.large])

    

        case .organizationDetail(let organization):
            NavigationStack {
                OrganizationDetailScreen(organization: organization)
            }
            .presentationDetents([.large])


        case .coinStore:
            NavigationStack { CoinStoreScreen() }
                .presentationDetents([.large])

    

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

    

        case .speedRunSetup:
            NavigationStack { SpeedRunSetupScreen() }
                .presentationDetents([.large])

    

        case .dailyChallenge:
            NavigationStack { DailyChallengeScreen() }
                .presentationDetents([.large])

    

        case .exploreGame:
            NavigationStack { ExploreGameScreen() }
                .presentationDetents([.large])

    

        case .multiplayer:
            NavigationStack {
                MultiplayerLobbyScreen(multiplayerService: MultiplayerService())
            }
            .presentationDetents([.large])


        case .quizPacks:
            NavigationStack { QuizPackBrowserScreen() }
                .presentationDetents([.large])

    

        case .customQuiz:
            NavigationStack { CustomQuizLibraryScreen() }
                .presentationDetents([.large])

    

        case .srsStudy:
            NavigationStack { SRSStudyScreen() }
                .presentationDetents([.large])

    

        case .flagGame:
            NavigationStack { FlagGameScreen() }
                .presentationDetents([.large])
                .interactiveDismissDisabled()

        case .trivia:
            NavigationStack { TriviaScreen() }
                .presentationDetents([.large])
                .interactiveDismissDisabled()

        case .spellingBee:
            NavigationStack { SpellingBeeScreen() }
                .presentationDetents([.large])
                .interactiveDismissDisabled()

        case .landmarkQuiz:
            NavigationStack { LandmarkQuizScreen() }
                .presentationDetents([.large])
                .interactiveDismissDisabled()

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

    

        case .currencyConverter:
            NavigationStack { CurrencyConverterScreen() }
                .presentationDetents([.large])

    

        case .timeZones:
            NavigationStack { TimeZoneScreen() }
                .presentationDetents([.large])

    

        case .compare:
            NavigationStack { CompareScreen() }
                .presentationDetents([.large])

    

        case .timeline:
            NavigationStack { TimelineScreen() }
                .presentationDetents([.large])

    

        case .travelTracker:
            NavigationStack {
                TravelTrackerScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])


        case .travelJournal:
            NavigationStack { TravelJournalScreen() }
                .presentationDetents([.large])

    

        case .travelBucketList:
            NavigationStack { TravelBucketListScreen() }
                .presentationDetents([.large])

    

        case .wordSearch:
            NavigationStack { WordSearchScreen() }
                .presentationDetents([.large])
                .interactiveDismissDisabled()

        case .borderChallenge:
            NavigationStack { BorderChallengeScreen() }
                .presentationDetents([.large])
                .interactiveDismissDisabled()

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

    

        case .badges:
            NavigationStack {
                BadgeCollectionScreen(badgeService: BadgeService())
            }
            .presentationDetents([.large])


        case .leaderboards:
            NavigationStack { LeaderboardScreen() }
                .presentationDetents([.large])

    

        case .achievements:
            NavigationStack {
                AchievementsScreen()
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.large)
            }
            .presentationDetents([.large])


        case .themes:
            NavigationStack {
                ThemesScreen()
                    .navigationTitle("Themes")
                    .navigationBarTitleDisplayMode(.large)
            }
            .presentationDetents([.large])


        case .settings:
            NavigationStack { SettingsScreen() }
                .presentationDetents([.large])

    

        case .sectionEditor:
            HomeSectionEditorSheet(sections: HomeSection.allCases.map { $0 })

        case .friends:
            NavigationStack { FriendsListScreen() }
                .presentationDetents([.large])
    

        case .learningPath:
            NavigationStack { LearningPathScreen() }
                .presentationDetents([.large])

        case .feed:
            NavigationStack { FeedScreen() }
                .presentationDetents([.large])

    

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
                .interactiveDismissDisabled()

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

    

        case .countryNicknames:
            NavigationStack { CountryNicknamesScreen() }
                .presentationDetents([.large])

    

        default:
            EmptyView()
        }
    }
}
