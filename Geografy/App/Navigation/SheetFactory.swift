import SwiftUI

@MainActor
enum SheetFactory {
    @ViewBuilder
    static func view(for sheet: Sheet) -> some View {
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

        case .quizSetup:
            NavigationStack { QuizSetupScreen() }
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

        case .search:
            NavigationStack { SearchScreen() }
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
            ComingSoonSheet(title: "Friends", icon: "person.2.fill")
        }
    }
}
