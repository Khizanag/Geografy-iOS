import CoreSpotlight
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Country
import Geografy_Feature_Play
import Geografy_Feature_Profile
import SwiftUI
#if DEBUG
import TestingLab
#endif

struct ContentView: View {
    // MARK: - Properties
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.displayScale) private var displayScale
    #if DEBUG
    @Environment(DatabaseManager.self) private var databaseManager
    @Environment(StreakService.self) private var streakService
    @Environment(TestingModeService.self) private var testingModeService
    #endif

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
            // Initially too: a Shortcut that launched the app sent its request before this view existed.
            .onChange(of: AppRequests.shared.pending, initial: true) {
                if let request = AppRequests.shared.take() {
                    appCoordinator.handle(request, countries: countryDataService.countries)
                }
            }
            .onOpenURL { appCoordinator.handleDeepLink($0) }
            .task(id: countryDataService.countries.count, priority: .utility) { await prewarmListFlags() }
            #if DEBUG
            .task { appCoordinator.openHubItemFromLaunchArguments() }
            .testingLab(
                notes: BuildNotes(go: buildNoteRoutes).current,
                accent: DesignSystem.Color.accent,
                erase: { labData.eraseStore() },
                sections: { GeografyLabSections { appCoordinator.open($0) } }
            )
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
            Tab("Map", systemImage: "map.fill", value: AppTab.map) {
                CoordinatedNavigationStack(navigator: appCoordinator.mapNavigator) {
                    MapTabScreen()
                }
            }

            Tab("Explore", systemImage: "safari.fill", value: AppTab.explore) {
                CoordinatedNavigationStack(navigator: appCoordinator.exploreNavigator) {
                    ExploreScreen()
                }
            }

            Tab("Play", systemImage: "gamecontroller.fill", value: AppTab.play) {
                CoordinatedNavigationStack(navigator: appCoordinator.playNavigator) {
                    PlayScreen()
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

// MARK: - Testing Lab
#if DEBUG
private extension ContentView {
    var labData: TestingLabData {
        TestingLabData(
            database: databaseManager,
            xpService: xpService,
            achievementService: achievementService,
            streakService: streakService
        )
    }

    var buildNoteRoutes: BuildNoteRoutes {
        BuildNoteRoutes(
            open: { appCoordinator.open($0) },
            selectTab: { appCoordinator.selectedTab = $0 },
            showLevelUp: { xpService.levelUpPublisher.send(xpService.currentLevel) },
            enableTestingMode: { testingModeService.isEnabled = true }
        )
    }
}
#endif

// MARK: - Helpers
private extension ContentView {
    /// Lists draw every flag at row size, so decoding them up front keeps the first scroll smooth.
    func prewarmListFlags() async {
        await FlagImageCache.shared.prewarm(
            countryCodes: countryDataService.countries.map(\.code),
            pointHeight: DesignSystem.Size.Flag.row,
            displayScale: displayScale
        )
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
