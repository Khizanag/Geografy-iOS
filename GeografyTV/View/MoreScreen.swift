import GeografyCore
import SwiftUI

struct MoreScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List {
            Section("Games") {
                NavigationLink {
                    TriviaScreen(countryDataService: countryDataService)
                } label: {
                    Label("True or False", systemImage: "brain.fill")
                }

                NavigationLink {
                    CompareScreen(countryDataService: countryDataService)
                } label: {
                    Label("Compare Countries", systemImage: "arrow.left.arrow.right")
                }

                NavigationLink {
                    NicknamesScreen()
                } label: {
                    Label("Country Nicknames", systemImage: "quote.bubble.fill")
                }
            }

            Section("Learn") {
                NavigationLink {
                    LearningPathScreen()
                } label: {
                    Label("Learning Path", systemImage: "book.fill")
                }

                NavigationLink {
                    CultureScreen(countryDataService: countryDataService)
                } label: {
                    Label("Culture Explorer", systemImage: "music.note")
                }

                NavigationLink {
                    LanguageScreen()
                } label: {
                    Label("Languages", systemImage: "text.bubble.fill")
                }
            }

            Section("Discover") {
                NavigationLink {
                    EconomyScreen(countryDataService: countryDataService)
                } label: {
                    Label("Economy Rankings", systemImage: "chart.bar.fill")
                }

                NavigationLink {
                    NeighborScreen(countryDataService: countryDataService)
                } label: {
                    Label("Neighbor Explorer", systemImage: "point.3.connected.trianglepath.dotted")
                }

                NavigationLink {
                    WorldRecordsScreen(countryDataService: countryDataService)
                } label: {
                    Label("World Records", systemImage: "trophy.fill")
                }

                NavigationLink {
                    GeographyFeaturesScreen()
                } label: {
                    Label("Geography Features", systemImage: "mountain.2.fill")
                }

                NavigationLink {
                    OceanScreen()
                } label: {
                    Label("Oceans & Seas", systemImage: "water.waves")
                }

                NavigationLink {
                    LandmarkScreen()
                } label: {
                    Label("Landmarks", systemImage: "building.columns.fill")
                }

                NavigationLink {
                    ContinentStatsScreen(countryDataService: countryDataService)
                } label: {
                    Label("Continent Stats", systemImage: "chart.pie.fill")
                }

                NavigationLink {
                    OrganizationsScreen(countryDataService: countryDataService)
                } label: {
                    Label("Organizations", systemImage: "building.2.fill")
                }
            }

            Section("History") {
                NavigationLink {
                    TimelineScreen()
                } label: {
                    Label("Timeline", systemImage: "clock.fill")
                }

                NavigationLink {
                    IndependenceScreen()
                } label: {
                    Label("Independence", systemImage: "flag.fill")
                }
            }

            Section("Content") {
                NavigationLink {
                    FeedScreen(countryDataService: countryDataService)
                } label: {
                    Label("Feed", systemImage: "newspaper.fill")
                }

                NavigationLink {
                    QuotesScreen()
                } label: {
                    Label("Quotes", systemImage: "quote.opening")
                }
            }

            Section("Travel") {
                NavigationLink {
                    TravelScreen(countryDataService: countryDataService)
                } label: {
                    Label("Travel Tracker", systemImage: "airplane.departure")
                }

                NavigationLink {
                    FavoritesScreen(countryDataService: countryDataService)
                } label: {
                    Label("Favorites", systemImage: "heart.fill")
                }
            }

            Section("Progress") {
                NavigationLink {
                    ProfileScreen()
                } label: {
                    Label("Profile", systemImage: "person.fill")
                }

                NavigationLink {
                    AchievementsScreen()
                } label: {
                    Label("Achievements", systemImage: "medal.fill")
                }

                NavigationLink {
                    LeaderboardScreen()
                } label: {
                    Label("Leaderboard", systemImage: "list.number")
                }
            }

            Section("Tools") {
                NavigationLink {
                    ToolsScreen(countryDataService: countryDataService)
                } label: {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
            }

            Section {
                NavigationLink {
                    SettingsScreen()
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }
        .navigationTitle("More")
    }
}
