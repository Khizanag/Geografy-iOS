import CoreSpotlight
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Achievement
import Geografy_Feature_CountryList
import Geografy_Feature_Map
import Geografy_Feature_Quiz
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(CountryDataService.self) private var countryDataService

    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @State private var appCoordinator = AppCoordinator()
    @State private var levelUpLevel: UserLevel?
    @State private var currentBannerAchievement: AchievementDefinition?
    @State private var bannerQueue: [AchievementDefinition] = []

    // MARK: - Body
    var body: some View {
        mainContent
            .tint(DesignSystem.Color.accent)
            .preferredColorScheme(colorScheme)
            .toolbarBackgroundVisibility(.hidden, for: .tabBar)
            .onReceive(xpService.levelUpPublisher) { levelUpLevel = $0 }
            .onReceive(achievementService.unlockPublisher) { achievement in
                bannerQueue.append(achievement)
                if currentBannerAchievement == nil { showNextBanner() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .switchTab)) { notification in
                if let rawValue = notification.object as? Int, let tab = AppTab(rawValue: rawValue) {
                    appCoordinator.selectedTab = tab
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .startQuiz)) { _ in
                appCoordinator.selectedTab = .play
                appCoordinator.playNavigator.push(.quizSetup)
            }
            .onReceive(NotificationCenter.default.publisher(for: .startDailyChallenge)) { _ in
                appCoordinator.selectedTab = .play
                appCoordinator.playNavigator.push(.dailyChallenge)
            }
            #if targetEnvironment(macCatalyst)
            .onReceive(NotificationCenter.default.publisher(for: .macOpenSearch)) { _ in
                appCoordinator.selectedTab = .explore
                appCoordinator.exploreNavigator.push(.search)
            }
            #endif
            .onOpenURL { appCoordinator.handleDeepLink($0) }
            #if DEBUG
            .task { appCoordinator.openHubItemFromLaunchArguments() }
            #endif
            .onContinueUserActivity(CSSearchableItemActionType) { activity in
                if let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    appCoordinator.handleSpotlightActivity(
                        identifier,
                        countryDataService: countryDataService
                    )
                }
            }
            .onContinueUserActivity("com.khizanag.geografy.viewCountry") { activity in
                if let code = activity.userInfo?["countryCode"] as? String {
                    appCoordinator.handleSpotlightActivity(
                        "country-\(code)",
                        countryDataService: countryDataService
                    )
                }
            }
    }
}

// MARK: - Subviews
private extension ContentView {
    var mainContent: some View {
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
                    levelUpLevel = nil
                }
                .zIndex(100)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentBannerAchievement?.id)
        .animation(.easeOut(duration: 0.3), value: levelUpLevel != nil)
    }

    var tabContent: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            Tab("Explore", systemImage: "globe.europe.africa.fill", value: AppTab.explore) {
                CoordinatedNavigationStack(navigator: appCoordinator.exploreNavigator) {
                    ExploreScreen()
                }
            }

            Tab("Play", systemImage: "gamecontroller.fill", value: AppTab.play) {
                CoordinatedNavigationStack(navigator: appCoordinator.playNavigator) {
                    PlayScreen()
                }
            }

            Tab("Map", systemImage: "map.fill", value: AppTab.map) {
                CoordinatedNavigationStack(navigator: appCoordinator.mapNavigator) {
                    MapScreen()
                }
            }

            Tab("Learn", systemImage: "book.fill", value: AppTab.learn) {
                CoordinatedNavigationStack(navigator: appCoordinator.learnNavigator) {
                    LearnScreen()
                }
            }

            Tab("Profile", systemImage: "person.crop.circle.fill", value: AppTab.profile) {
                CoordinatedNavigationStack(navigator: appCoordinator.profileNavigator) {
                    ProfileTabScreen()
                }
            }
        }
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

    func showNextBanner() {
        guard !bannerQueue.isEmpty else { return }
        currentBannerAchievement = bannerQueue.removeFirst()
    }
}
