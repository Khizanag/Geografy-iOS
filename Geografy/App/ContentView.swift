import Combine
import CoreSpotlight
import GeografyCore
import GeografyDesign
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(CountryDataService.self) private var countryDataService

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
        .onOpenURL { url in
            appCoordinator.handleDeepLink(url)
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            if let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                appCoordinator.handleSpotlightActivity(identifier, countryDataService: countryDataService)
            }
        }
        .onContinueUserActivity("com.khizanag.geografy.viewCountry") { activity in
            if let code = activity.userInfo?["countryCode"] as? String {
                appCoordinator.handleSpotlightActivity("country-\(code)", countryDataService: countryDataService)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchTab)) { notification in
            if let tab = notification.object as? Int {
                appCoordinator.selectedTab = tab
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .startQuiz)) { _ in
            appCoordinator.selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .startDailyChallenge)) { _ in
            appCoordinator.selectedTab = 0
            appCoordinator.homeNavigator.sheet(.dailyChallenge)
        }
        #if targetEnvironment(macCatalyst)
        .onReceive(NotificationCenter.default.publisher(for: .macOpenSearch)) { _ in
            appCoordinator.homeNavigator.sheet(.search)
        }
        #endif
    }
}

// MARK: - Helpers
private extension ContentView {
    var tabContent: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                CoordinatedNavigationStack(navigator: appCoordinator.homeNavigator) {
                    HomeScreen()
                }
            }

            Tab("Quiz", systemImage: "gamecontroller.fill", value: 1) {
                CoordinatedNavigationStack(navigator: appCoordinator.quizNavigator) {
                    QuizSetupScreen()
                }
            }

            Tab("Countries", systemImage: "globe", value: 2) {
                CoordinatedNavigationStack(navigator: appCoordinator.countriesNavigator) {
                    CountryListScreen()
                }
            }

            Tab("All Maps", systemImage: "map.fill", value: 3) {
                CoordinatedNavigationStack(navigator: appCoordinator.allMapsNavigator) {
                    AllMapsScreen()
                }
            }

            Tab("More", systemImage: "ellipsis", value: 4) {
                CoordinatedNavigationStack(navigator: appCoordinator.moreNavigator) {
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
