import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Country
import Geografy_Feature_Discover
import Geografy_Feature_Map
import Geografy_Feature_Play
import Geografy_Feature_Profile
import Geografy_Feature_Travel
import StoreKit
import SwiftUI

@main
struct GeografyApp: App {
    // MARK: - Properties
    @Environment(\.scenePhase) private var scenePhase

    @State private var dependencies = AppDependencies()

    // MARK: - Init
    init() {
        #if os(iOS)
        BackgroundTaskService.registerTasks()
        #endif
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            contentView
                .environment(\.routes, Self.routes)
        }
        .onChange(of: scenePhase) { _, newPhase in handleScenePhaseChange(newPhase) }
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 1_200, height: 800)
        .commands { macCommands }
        #endif
    }
}

// MARK: - Content View
private extension GeografyApp {
    var contentView: some View {
        ContentView()
            .modifier(AppLanguageLocale())
            .environment(dependencies)
            .task { await bootstrap() }
            .task(priority: .utility) { await dependencies.geoJSONCache.preload() }
            .task(priority: .utility) { await dependencies.authService.validateOnLaunch() }
            .task(priority: .utility) { await authenticateGameCenter() }
            .task(priority: .background) { await setupNotificationsAndSpotlight() }
            .task(priority: .background) { await syncWidgetData() }
            .onReceive(dependencies.achievementService.unlockPublisher) { handleAchievementUnlock($0) }
            .modifier(
                ServiceChangeHandlers(
                    authService: dependencies.authService,
                    xpService: dependencies.xpService,
                    streakService: dependencies.streakService,
                    travelService: dependencies.travelService,
                    onUserSwitch: handleUserSwitch,
                    onXPChange: handleXPChange,
                    onStreakChange: handleStreakChange,
                    onVisitedChange: handleVisitedChange
                )
            )
    }

    /// Every feature's screens, filled once for the app's lifetime and read by each navigation stack.
    static let routes: RouteRegistry = {
        var registry = RouteRegistry()
        registry.registerMapScreens()
        registry.registerCountryScreens()
        registry.registerPlayScreens()
        registry.registerDiscoverScreens()
        registry.registerProfileScreens()
        registry.registerTravelScreens()
        return registry
    }()
}

// MARK: - App Language Locale
/// Hands every screen the locale of the language chosen in the app, so text switches in place.
private struct AppLanguageLocale: ViewModifier {
    @Environment(LanguageService.self) private var languageService

    func body(content: Content) -> some View {
        content.environment(\.locale, languageService.locale)
    }
}

// MARK: - Service Change Handlers
/// Watches the services the app reacts to. Reading them here rather than in the app's `body`
/// means an XP award or a visited country re-runs only this modifier, not the whole scene.
private struct ServiceChangeHandlers: ViewModifier {
    let authService: AuthService
    let xpService: XPService
    let streakService: StreakService
    let travelService: TravelService
    let onUserSwitch: (String) -> Void
    let onXPChange: (Int) -> Void
    let onStreakChange: (Int) -> Void
    let onVisitedChange: (Int) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: authService.currentUserID) { _, id in onUserSwitch(id) }
            .onChange(of: xpService.totalXP) { _, xp in onXPChange(xp) }
            .onChange(of: streakService.currentStreak) { _, streak in onStreakChange(streak) }
            .onChange(of: travelService.visitedCodes.count) { _, count in onVisitedChange(count) }
    }
}

// MARK: - Bootstrap
private extension GeografyApp {
    func bootstrap() async {
        await dependencies.countryDataService.loadCountries()
        dependencies.favoritesService.fetchEntries()
        dependencies.flashcardService.loadData()
        dependencies.collectionService.configure(container: dependencies.databaseManager.container)
        dependencies.xpService.refreshXP()
        dependencies.achievementService.refreshUnlocked()
        dependencies.achievementService.loadPinnedIDs()
        dependencies.streakService.refreshStreak()
    }
}

// MARK: - Lifecycle Tasks
private extension GeografyApp {
    func authenticateGameCenter() async {
        dependencies.gameCenterService.authenticatePlayer()
        let longestStreak = dependencies.authService.currentProfile?.longestStreak
            ?? dependencies.streakService.currentStreak
        if longestStreak > 0 {
            await dependencies.gameCenterService.submitScore(
                longestStreak,
                to: GameCenterService.LeaderboardID.longestStreak
            )
        }
    }

    func setupNotificationsAndSpotlight() async {
        #if os(iOS)
        // Permission is asked for when the person turns reminders on in Settings, not at launch.
        await NotificationService.syncReminders(
            enabled: UserDefaults.standard.bool(forKey: NotificationService.preferenceKey)
        )
        SpotlightIndexer.indexCountriesIfNeeded(dependencies.countryDataService.countries)
        #endif
    }

    func syncWidgetData() async {
        await dependencies.widgetDataBridge.loadCountriesIfNeeded()
        await synchronizeWidgetData()
    }
}

// MARK: - Event Handlers
private extension GeografyApp {
    func handleAchievementUnlock(_ definition: AchievementDefinition) {
        Task {
            if let gameCenterID = definition.gameCenterID {
                await dependencies.gameCenterService.reportAchievement(
                    id: gameCenterID,
                    percentComplete: 100.0
                )
            }
        }
        requestReviewIfAppropriate()
    }

    func handleUserSwitch(_ newUserID: String) {
        UserScope.activate(newUserID)
        dependencies.favoritesService.switchUser(id: newUserID)
        dependencies.collectionService.switchUser(id: newUserID)
        dependencies.travelService.reload()
        dependencies.explorationService.reload()
        dependencies.learningPathService.reload()
        dependencies.flashcardService.loadData()
        dependencies.xpService.switchUser(id: newUserID)
        dependencies.streakService.switchUser(id: newUserID)
        dependencies.achievementService.switchUser(id: newUserID)
    }

    func handleXPChange(_ newXP: Int) {
        Task {
            await dependencies.gameCenterService.submitScore(
                newXP,
                to: GameCenterService.LeaderboardID.totalXP
            )
            await synchronizeWidgetData()
        }
    }

    func handleStreakChange(_ newStreak: Int) {
        let longestStreak = max(
            newStreak,
            dependencies.authService.currentProfile?.longestStreak ?? 0
        )
        Task {
            await dependencies.gameCenterService.submitScore(
                longestStreak,
                to: GameCenterService.LeaderboardID.longestStreak
            )
            await synchronizeWidgetData()
        }
    }

    func handleVisitedChange(_ count: Int) {
        Task {
            await dependencies.gameCenterService.submitScore(
                count,
                to: GameCenterService.LeaderboardID.countriesVisited
            )
            await synchronizeWidgetData()
        }
    }

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .active {
            dependencies.streakService.recordDailyLogin()
        }
        #if os(iOS)
        if newPhase == .background {
            BackgroundTaskService.scheduleWidgetRefresh()
        }
        #endif
    }
}

// MARK: - Widget Sync
private extension GeografyApp {
    func synchronizeWidgetData() async {
        await dependencies.widgetDataBridge.synchronize(
            streak: dependencies.streakService.currentStreak,
            totalXP: dependencies.xpService.totalXP,
            level: dependencies.xpService.currentLevel,
            progressFraction: dependencies.xpService.progressFraction,
            visitedCount: dependencies.travelService.visitedCodes.count
        )
    }
}

// MARK: - App Review
private extension GeografyApp {
    func requestReviewIfAppropriate() {
        let key = "app_review_milestone"
        let unlocked = dependencies.achievementService.unlockedAchievements.count
        let lastMilestone = UserDefaults.standard.integer(forKey: key)
        let milestones = [3, 7, 15]
        guard let milestone = milestones.first(where: { unlocked >= $0 && lastMilestone < $0 }) else { return }
        UserDefaults.standard.set(milestone, forKey: key)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                AppStore.requestReview(in: scene)
            }
        }
    }
}

// MARK: - Mac Commands
#if targetEnvironment(macCatalyst)
private extension GeografyApp {
    @CommandsBuilder
    var macCommands: some Commands {
        CommandGroup(replacing: .newItem) {}

        CommandGroup(replacing: .appSettings) {
            Button("Settings...") {
                NotificationCenter.default.post(name: .switchTab, object: AppTab.profile.rawValue)
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        CommandGroup(replacing: .help) {
            Button("Geografy Help") {
                if let url = URL(string: "https://github.com/Khizanag/Geografy-iOS") {
                    UIApplication.shared.open(url)
                }
            }
        }

        CommandMenu("Quiz") {
            Button("Start Quick Quiz") {
                NotificationCenter.default.post(name: .startQuiz, object: nil)
            }
            .keyboardShortcut("q", modifiers: [.command, .shift])
        }

        CommandMenu("Navigate") {
            navigateMenuItems
        }
    }

    @ViewBuilder
    var navigateMenuItems: some View {
        Button("Map") { NotificationCenter.default.post(name: .switchTab, object: AppTab.map.rawValue) }
            .keyboardShortcut("1", modifiers: .command)
        Button("Explore") { NotificationCenter.default.post(name: .switchTab, object: AppTab.explore.rawValue) }
            .keyboardShortcut("2", modifiers: .command)
        Button("Play") { NotificationCenter.default.post(name: .switchTab, object: AppTab.play.rawValue) }
            .keyboardShortcut("3", modifiers: .command)
        Button("Profile") { NotificationCenter.default.post(name: .switchTab, object: AppTab.profile.rawValue) }
            .keyboardShortcut("4", modifiers: .command)

        Divider()

        Button("Search") { NotificationCenter.default.post(name: .macOpenSearch, object: nil) }
            .keyboardShortcut("f", modifiers: .command)
        Button("Random Country") { NotificationCenter.default.post(name: .macRandomCountry, object: nil) }
            .keyboardShortcut("r", modifiers: .command)
    }
}
#endif

// MARK: - Notification Names
extension Notification.Name {
    static let switchTab = Notification.Name("switchTab")
    static let startQuiz = Notification.Name("startQuiz")
    static let startDailyChallenge = Notification.Name("startDailyChallenge")
    #if targetEnvironment(macCatalyst)
    static let macRandomCountry = Notification.Name("macRandomCountry")
    static let macOpenSearch = Notification.Name("macOpenSearch")
    #endif
}
