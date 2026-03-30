import Combine
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService

    @State private var appCoordinator = AppCoordinator()
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
        .toolbarBackgroundVisibility(.hidden, for: .tabBar)
        #if targetEnvironment(macCatalyst)
        .onReceive(NotificationCenter.default.publisher(for: .macSwitchTab)) { notification in
            if let tab = notification.object as? Int {
                appCoordinator.selectedTab = tab
            }
        }
        #endif
    }
}

// MARK: - Helpers
private extension ContentView {
    var tabContent: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                CoordinatedNavigationStack(coordinator: appCoordinator.homeCoordinator) {
                    HomeScreen()
                }
            }

            Tab("Quiz", systemImage: "gamecontroller.fill", value: 1) {
                CoordinatedNavigationStack(coordinator: appCoordinator.quizCoordinator) {
                    QuizSetupScreen()
                }
            }

            Tab("Countries", systemImage: "globe", value: 2) {
                CoordinatedNavigationStack(coordinator: appCoordinator.countriesCoordinator) {
                    CountryListScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                }
            }

            Tab("All Maps", systemImage: "map.fill", value: 3) {
                CoordinatedNavigationStack(coordinator: appCoordinator.allMapsCoordinator) {
                    AllMapsScreen()
                }
            }

            Tab("More", systemImage: "ellipsis", value: 4) {
                CoordinatedNavigationStack(coordinator: appCoordinator.moreCoordinator) {
                    MoreScreen()
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "Light": .light
        case "Dark": .dark
        default: nil
        }
    }

    func showNextBanner() {
        guard !bannerQueue.isEmpty else { return }
        currentBannerAchievement = bannerQueue.removeFirst()
    }
}
