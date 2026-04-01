import Geografy_Core_Service
import Geografy_Core_Common
import SwiftUI

@main
struct GeografyTVApp: App {
    @State private var databaseManager: DatabaseManager
    @State private var authService: AuthService
    @State private var xpService: XPService
    @State private var streakService: StreakService
    @State private var achievementService: AchievementService
    @State private var favoritesService: FavoritesService
    @State private var travelService = TravelService()
    @State private var gameCenterService = GameCenterService()
    @State private var coinService = CoinService()
    @State private var flashcardService = FlashcardService()
    @State private var subscriptionService = SubscriptionService()
    @State private var pronunciationService = PronunciationService()
    @State private var countryDataService = CountryDataService()

    init() {
        let db = DatabaseManager()
        let auth = AuthService(db: db)
        let userID = auth.currentUserID
        let xp = XPService(db: db, userID: userID)
        let achievement = AchievementService(db: db, xpService: xp, userID: userID)
        let streak = StreakService(
            db: db,
            xpService: xp,
            achievementService: achievement,
            userID: userID
        )
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
            HomeScreen()
                .environment(databaseManager)
                .environment(authService)
                .environment(xpService)
                .environment(streakService)
                .environment(achievementService)
                .environment(favoritesService)
                .environment(travelService)
                .environment(gameCenterService)
                .environment(coinService)
                .environment(flashcardService)
                .environment(subscriptionService)
                .environment(pronunciationService)
                .task {
                    countryDataService.loadCountries()
                    gameCenterService.authenticatePlayer()
                    await subscriptionService.checkEntitlements()
                }
        }
    }
}
