import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                NavigationStack {
                    HomeScreen()
                        .navigationDestination(for: NavigationRoute.self) { route in
                            destinationView(for: route)
                        }
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                }
            }

            Tab("All Maps", systemImage: "map.fill", value: 1) {
                NavigationStack {
                    AllMapsScreen()
                        .navigationDestination(for: NavigationRoute.self) { route in
                            destinationView(for: route)
                        }
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                }
            }

            Tab("Countries", systemImage: "list.bullet", value: 2) {
                NavigationStack {
                    CountryListScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                }
            }

            Tab("Achievements", systemImage: "trophy.fill", value: 3) {
                NavigationStack {
                    AchievementsScreen()
                }
            }

            Tab("Themes", systemImage: "paintbrush.fill", value: 4) {
                NavigationStack {
                    ThemesScreen()
                }
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 5) {
                NavigationStack {
                    SettingsScreen()
                }
            }
        }
        .tint(DesignSystem.Color.accent)
        .preferredColorScheme(colorScheme)
    }
}

// MARK: - Helpers

private extension ContentView {
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "Light": .light
        case "Dark": .dark
        default: nil
        }
    }

    @ViewBuilder
    func destinationView(for route: NavigationRoute) -> some View {
        switch route {
        case .map:
            MapScreen()
        case .countryDetail(let country):
            CountryDetailScreen(country: country)
        case .allMaps:
            AllMapsScreen()
        case .achievements:
            AchievementsScreen()
        case .themes:
            ThemesScreen()
        case .settings:
            SettingsScreen()
        case .quiz:
            QuizSetupScreen()
        }
    }
}
