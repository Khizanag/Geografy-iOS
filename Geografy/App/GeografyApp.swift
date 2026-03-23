import SwiftUI

@main
struct GeografyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var hapticsService = HapticsService()
    @State private var favoritesService = FavoritesService()
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
    @State private var pronunciationService = PronunciationService()
    @State private var widgetDataBridge = WidgetDataBridge()

    init() {
        let db = DatabaseManager()
        let auth = AuthService(db: db)
        let userID = auth.currentUserID
        let xp = XPService(db: db, userID: userID)
        let achievement = AchievementService(db: db, xpService: xp, userID: userID)
        let streak = StreakService(db: db, xpService: xp, achievementService: achievement, userID: userID)
        _databaseManager = State(wrappedValue: db)
        _authService = State(wrappedValue: auth)
        _xpService = State(wrappedValue: xp)
        _achievementService = State(wrappedValue: achievement)
        _streakService = State(wrappedValue: streak)
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
                .environment(pronunciationService)
                .task { await authService.validateOnLaunch() }
                .task { await subscriptionService.checkEntitlements() }
                .task { gameCenterService.authenticatePlayer() }
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
                        await gameCenterService.reportAchievement(
                            id: definition.gameCenterID,
                            percentComplete: 100.0
                        )
                    }
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
    }
}
