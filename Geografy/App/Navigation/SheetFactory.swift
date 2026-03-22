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
            sheetWithCloseButton {
                CountryListScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }

        case .favorites:
            sheetWithCloseButton {
                FavoritesScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }

        case .organizations:
            sheetWithCloseButton { OrganizationsScreen() }

        case .organizationDetail(let organization):
            sheetWithCloseButton {
                OrganizationDetailScreen(organization: organization)
            }

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
            sheetWithCloseButton { QuizPackBrowserScreen() }

        case .customQuiz:
            NavigationStack { CustomQuizLibraryScreen() }
                .presentationDetents([.large])

        case .compare:
            sheetWithCloseButton { CompareScreen() }

        case .timeline:
            NavigationStack { TimelineScreen() }
                .presentationDetents([.large])

        case .travelTracker:
            sheetWithCloseButton {
                TravelTrackerScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }

        case .travelJournal:
            sheetWithCloseButton { TravelJournalScreen() }

        case .badges:
            sheetWithCloseButton {
                BadgeCollectionScreen(badgeService: BadgeService())
            }

        case .leaderboards:
            sheetWithCloseButton { LeaderboardScreen() }

        case .achievements:
            sheetWithCloseButton {
                AchievementsScreen()
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.large)
            }

        case .themes:
            sheetWithCloseButton {
                ThemesScreen()
                    .navigationTitle("Themes")
                    .navigationBarTitleDisplayMode(.large)
            }

        case .settings:
            sheetWithCloseButton { SettingsScreen() }

        case .sectionEditor:
            HomeSectionEditorSheet(sections: HomeSection.allCases.map { $0 })

        case .friends:
            ComingSoonSheet(title: "Friends", icon: "person.2.fill")
        }
    }
}

// MARK: - Helpers

private extension SheetFactory {
    static func sheetWithCloseButton<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CircleCloseButton()
                    }
                }
        }
        .presentationDetents([.large])
    }
}
