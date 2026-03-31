import StoreKit
import SwiftUI
import GeografyCore

@main
struct GeografyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var hapticsService = HapticsService()
    @State private var testingModeService = TestingModeService()
    @State private var favoritesService: FavoritesService
    @State private var travelService = TravelService()
    @State private var gameCenterService = GameCenterService()
    @State private var homeSectionOrderService = HomeSectionOrderService()
    @State private var databaseManager: DatabaseManager
    @State private var authService: AuthService
    @State private var xpService: XPService
    @State private var streakService: StreakService
    @State private var achievementService: AchievementService
    @State private var coinService = CoinService()
    @State private var flashcardService = FlashcardService()
    @State private var subscriptionService = SubscriptionService()
    @State private var worldBankService = WorldBankService()
    @State private var currencyService = CurrencyService()
    @State private var learningPathService = LearningPathService()
    @State private var pronunciationService = PronunciationService()
    @State private var widgetDataBridge = WidgetDataBridge()

    init() {
        let db = DatabaseManager()
        let auth = AuthService(db: db)
        let userID = auth.currentUserID
        let xp = XPService(db: db, userID: userID)
        let achievement = AchievementService(db: db, xpService: xp, userID: userID)
        let streak = StreakService(db: db, xpService: xp, achievementService: achievement, userID: userID)
        let favorites = FavoritesService(container: db.container)
        _databaseManager = State(wrappedValue: db)
        _authService = State(wrappedValue: auth)
        _xpService = State(wrappedValue: xp)
        _achievementService = State(wrappedValue: achievement)
        _streakService = State(wrappedValue: streak)
        _favoritesService = State(wrappedValue: favorites)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(hapticsService)
                .environment(favoritesService)
                .environment(travelService)
                .environment(gameCenterService)
                .environment(homeSectionOrderService)
                .environment(databaseManager)
                .environment(authService)
                .environment(xpService)
                .environment(streakService)
                .environment(achievementService)
                .environment(coinService)
                .environment(flashcardService)
                .environment(subscriptionService)
                .environment(worldBankService)
                .environment(currencyService)
                .environment(learningPathService)
                .environment(pronunciationService)
                .environment(testingModeService)
                .task { await authService.validateOnLaunch() }
                .task {
                    #if os(iOS)
                    let granted = await NotificationService.requestPermission()
                    if granted {
                        NotificationService.scheduleStreakReminder()
                        NotificationService.scheduleDailyChallengeReminder()
                    }
                    #endif
                }
                .task { await subscriptionService.checkEntitlements() }
                .task {
                    gameCenterService.authenticatePlayer()
                    let longestStreak = authService.currentProfile?.longestStreak
                        ?? streakService.currentStreak
                    if longestStreak > 0 {
                        await gameCenterService.submitScore(
                            longestStreak,
                            to: GameCenterService.LeaderboardID.longestStreak
                        )
                    }
                }
                .task {
                    let countryService = CountryDataService()
                    countryService.loadCountries()
                    #if os(iOS)
                    SpotlightIndexer.indexCountries(countryService.countries)
                    #endif
                }
                .task {
                    widgetDataBridge.loadCountriesIfNeeded()
                    widgetDataBridge.synchronize(
                        streak: streakService.currentStreak,
                        totalXP: xpService.totalXP,
                        level: xpService.currentLevel,
                        progressFraction: xpService.progressFraction,
                        visitedCount: travelService.visitedCodes.count
                    )
                }
                .onReceive(achievementService.unlockPublisher) { definition in
                    Task {
                        if let gameCenterID = definition.gameCenterID {
                            await gameCenterService.reportAchievement(
                                id: gameCenterID,
                                percentComplete: 100.0
                            )
                        }
                    }
                    requestReviewIfAppropriate()
                }
                .onChange(of: authService.currentUserID) { _, newUserID in
                    xpService.switchUser(id: newUserID)
                    streakService.switchUser(id: newUserID)
                    achievementService.switchUser(id: newUserID)
                }
                .onChange(of: xpService.totalXP) { _, newXP in
                    Task {
                        await gameCenterService.submitScore(
                            newXP,
                            to: GameCenterService.LeaderboardID.totalXP
                        )
                    }
                    widgetDataBridge.synchronize(
                        streak: streakService.currentStreak,
                        totalXP: newXP,
                        level: xpService.currentLevel,
                        progressFraction: xpService.progressFraction,
                        visitedCount: travelService.visitedCodes.count
                    )
                }
                .onChange(of: streakService.currentStreak) { _, newStreak in
                    let longestStreak = max(
                        newStreak,
                        authService.currentProfile?.longestStreak ?? 0
                    )
                    Task {
                        await gameCenterService.submitScore(
                            longestStreak,
                            to: GameCenterService.LeaderboardID.longestStreak
                        )
                    }
                    widgetDataBridge.synchronize(
                        streak: newStreak,
                        totalXP: xpService.totalXP,
                        level: xpService.currentLevel,
                        progressFraction: xpService.progressFraction,
                        visitedCount: travelService.visitedCodes.count
                    )
                }
                .onChange(of: travelService.visitedCodes.count) { _, count in
                    Task {
                        await gameCenterService.submitScore(
                            count,
                            to: GameCenterService.LeaderboardID.countriesVisited
                        )
                    }
                    widgetDataBridge.synchronize(
                        streak: streakService.currentStreak,
                        totalXP: xpService.totalXP,
                        level: xpService.currentLevel,
                        progressFraction: xpService.progressFraction,
                        visitedCount: count
                    )
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                streakService.recordDailyLogin()
            }
        }
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 1200, height: 800)
        #endif
        #if targetEnvironment(macCatalyst)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    NotificationCenter.default.post(name: .macSwitchTab, object: 4)
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
                    NotificationCenter.default.post(name: .macStartQuiz, object: nil)
                }
                .keyboardShortcut("q", modifiers: [.command, .shift])
            }

            CommandMenu("Navigate") {
                Button("Home") {
                    NotificationCenter.default.post(name: .macSwitchTab, object: 0)
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Quiz") {
                    NotificationCenter.default.post(name: .macSwitchTab, object: 1)
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("Countries") {
                    NotificationCenter.default.post(name: .macSwitchTab, object: 2)
                }
                .keyboardShortcut("3", modifiers: .command)

                Button("Maps") {
                    NotificationCenter.default.post(name: .macSwitchTab, object: 3)
                }
                .keyboardShortcut("4", modifiers: .command)

                Button("More") {
                    NotificationCenter.default.post(name: .macSwitchTab, object: 4)
                }
                .keyboardShortcut("5", modifiers: .command)

                Divider()

                Button("Search") {
                    NotificationCenter.default.post(name: .macOpenSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)

                Button("Random Country") {
                    NotificationCenter.default.post(name: .macRandomCountry, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        #endif
    }
}

// MARK: - App Review
private extension GeografyApp {
    func requestReviewIfAppropriate() {
        let key = "app_review_milestone"
        let unlocked = achievementService.unlockedAchievements.count
        let lastMilestone = UserDefaults.standard.integer(forKey: key)
        let milestones = [3, 7, 15]
        guard let milestone = milestones.first(where: { unlocked >= $0 && lastMilestone < $0 }) else { return }
        UserDefaults.standard.set(milestone, forKey: key)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

#if targetEnvironment(macCatalyst)
// MARK: - Mac Notification Names
extension Notification.Name {
    static let macSwitchTab = Notification.Name("macSwitchTab")
    static let macStartQuiz = Notification.Name("macStartQuiz")
    static let macRandomCountry = Notification.Name("macRandomCountry")
    static let macOpenSearch = Notification.Name("macOpenSearch")
}
#endif
