import SwiftUI

struct TVMoreScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List {
            Section("Games") {
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

            Section("Discover") {
                NavigationLink {
                    TVWorldRecordsScreen(countryDataService: countryDataService)
                } label: {
                    Label("World Records", systemImage: "trophy.fill")
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

            Section("Progress") {
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

                NavigationLink {
                    TVFavoritesScreen(countryDataService: countryDataService)
                } label: {
                    Label("Favorites", systemImage: "heart.fill")
                }
            }
        }
        .navigationTitle("More")
    }
}
