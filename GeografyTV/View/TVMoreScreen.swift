import SwiftUI

struct TVMoreScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List {
            Section("Games") {
                NavigationLink {
                    TVTriviaScreen(countryDataService: countryDataService)
                } label: {
                    Label("True or False", systemImage: "brain.fill")
                }

                NavigationLink {
                    TVCompareScreen(countryDataService: countryDataService)
                } label: {
                    Label("Compare Countries", systemImage: "arrow.left.arrow.right")
                }

                NavigationLink {
                    TVNicknamesScreen()
                } label: {
                    Label("Country Nicknames", systemImage: "quote.bubble.fill")
                }
            }

            Section("Learn") {
                NavigationLink {
                    TVLearningPathScreen()
                } label: {
                    Label("Learning Path", systemImage: "book.fill")
                }

                NavigationLink {
                    TVCultureScreen(countryDataService: countryDataService)
                } label: {
                    Label("Culture Explorer", systemImage: "music.note")
                }

                NavigationLink {
                    TVLanguageScreen()
                } label: {
                    Label("Languages", systemImage: "text.bubble.fill")
                }
            }

            Section("Discover") {
                NavigationLink {
                    TVWorldRecordsScreen(countryDataService: countryDataService)
                } label: {
                    Label("World Records", systemImage: "trophy.fill")
                }

                NavigationLink {
                    TVGeographyFeaturesScreen()
                } label: {
                    Label("Geography Features", systemImage: "mountain.2.fill")
                }

                NavigationLink {
                    TVOceanScreen()
                } label: {
                    Label("Oceans & Seas", systemImage: "water.waves")
                }

                NavigationLink {
                    TVLandmarkScreen()
                } label: {
                    Label("Landmarks", systemImage: "building.columns.fill")
                }

                NavigationLink {
                    TVContinentStatsScreen(countryDataService: countryDataService)
                } label: {
                    Label("Continent Stats", systemImage: "chart.pie.fill")
                }

                NavigationLink {
                    TVOrganizationsScreen(countryDataService: countryDataService)
                } label: {
                    Label("Organizations", systemImage: "building.2.fill")
                }
            }

            Section("History") {
                NavigationLink {
                    TVTimelineScreen()
                } label: {
                    Label("Timeline", systemImage: "clock.fill")
                }

                NavigationLink {
                    TVIndependenceScreen()
                } label: {
                    Label("Independence", systemImage: "flag.fill")
                }
            }

            Section("Content") {
                NavigationLink {
                    TVFeedScreen(countryDataService: countryDataService)
                } label: {
                    Label("Feed", systemImage: "newspaper.fill")
                }

                NavigationLink {
                    TVQuotesScreen()
                } label: {
                    Label("Quotes", systemImage: "quote.opening")
                }
            }

            Section("Travel") {
                NavigationLink {
                    TVTravelScreen(countryDataService: countryDataService)
                } label: {
                    Label("Travel Tracker", systemImage: "airplane.departure")
                }

                NavigationLink {
                    TVFavoritesScreen(countryDataService: countryDataService)
                } label: {
                    Label("Favorites", systemImage: "heart.fill")
                }
            }

            Section("Progress") {
                NavigationLink {
                    TVProfileScreen()
                } label: {
                    Label("Profile", systemImage: "person.fill")
                }

                NavigationLink {
                    TVAchievementsScreen()
                } label: {
                    Label("Achievements", systemImage: "medal.fill")
                }

                NavigationLink {
                    TVLeaderboardScreen()
                } label: {
                    Label("Leaderboard", systemImage: "list.number")
                }
            }

            Section("Tools") {
                NavigationLink {
                    TVToolsScreen(countryDataService: countryDataService)
                } label: {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
            }

            Section {
                NavigationLink {
                    TVSettingsScreen()
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }
        .navigationTitle("More")
    }
}
