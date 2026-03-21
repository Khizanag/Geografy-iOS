import SwiftUI

@main
struct GeografyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var favoritesService = FavoritesService()
    @State private var travelService = TravelService()
    @State private var gameCenterService = GameCenterService()
    @State private var databaseManager: DatabaseManager
    @State private var authService: AuthService
    @State private var xpService: XPService
    @State private var streakService: StreakService
    @State private var achievementService: AchievementService
    @State private var coinService = CoinService()
    @State private var subscriptionService = SubscriptionService()

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
                .environment(favoritesService)
                .environment(travelService)
                .environment(gameCenterService)
                .environment(databaseManager)
                .environment(authService)
                .environment(xpService)
                .environment(streakService)
                .environment(achievementService)
                .environment(coinService)
                .environment(subscriptionService)
                .task { await authService.validateOnLaunch() }
                .task { await subscriptionService.checkEntitlements() }
                .task { gameCenterService.authenticatePlayer() }
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
                }
                .onChange(of: travelService.visitedCodes.count) { _, count in
                    Task {
                        await gameCenterService.submitScore(
                            count,
                            to: GameCenterService.LeaderboardID.countriesVisited
                        )
                    }
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                streakService.recordDailyLogin()
            }
        }
    }
}
