import Combine
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService

    @State private var selectedTab = 0
    @State private var levelUpLevel: UserLevel?
    @State private var currentBannerAchievement: AchievementDefinition?
    @State private var bannerQueue: [AchievementDefinition] = []

    var body: some View {
        ZStack(alignment: .top) {
            tabContent
            if let achievement = currentBannerAchievement {
                AchievementUnlockedBanner(
                    achievement: achievement,
                    onDismiss: {
                        currentBannerAchievement = nil
                        showNextBanner()
                    }
                )
                .zIndex(50)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            if let level = levelUpLevel {
                LevelUpSheet(newLevel: level) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        levelUpLevel = nil
                    }
                }
                .zIndex(100)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentBannerAchievement?.id)
        .animation(.easeOut(duration: 0.3), value: levelUpLevel != nil)
        .onReceive(xpService.levelUpPublisher) { newLevel in
            levelUpLevel = newLevel
        }
        .onReceive(achievementService.unlockPublisher) { achievement in
            bannerQueue.append(achievement)
            if currentBannerAchievement == nil {
                showNextBanner()
            }
        }
        .tint(DesignSystem.Color.accent)
        .preferredColorScheme(colorScheme)
    }
}

// MARK: - Helpers

private extension ContentView {
    var tabContent: some View {
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

            Tab("Quiz", systemImage: "gamecontroller.fill", value: 1) {
                QuizSetupScreen()
            }

            Tab("Flashcards", systemImage: "rectangle.on.rectangle.angled", value: 2) {
                FlashcardScreen()
            }

            Tab("All Maps", systemImage: "map.fill", value: 3) {
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

            Tab("More", systemImage: "ellipsis", value: 4) {
                MoreScreen()
            }
        }
    }

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

    func showNextBanner() {
        guard !bannerQueue.isEmpty else { return }
        currentBannerAchievement = bannerQueue.removeFirst()
    }
}
