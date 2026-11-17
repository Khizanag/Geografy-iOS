import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Discover
import Geografy_Feature_Play
import SwiftUI

/// Every app-wide service, made once and in dependency order. The app keeps one and hands each service to the
/// environment, so screens read them with `@Environment(Service.self)`.
@MainActor
final class AppDependencies {
    // MARK: - Properties
    let achievementService: AchievementService
    let authService: AuthService
    let collectionService = CollectionService()
    let countryDataService = CountryDataService()
    let currencyService = CurrencyService()
    #if !os(tvOS)
    let customQuizService = CustomQuizService()
    #endif
    let databaseManager: DatabaseManager
    let entitlementService = EntitlementService()
    let explorationService: ExplorationService
    let favoritesService: FavoritesService
    let flashcardService = FlashcardService()
    let gameCenterService = GameCenterService()
    let geoJSONCache = GeoJSONCache()
    let hapticsService = HapticsService()
    let languageService = LanguageService()
    let learningPathService: LearningPathService
    let pronunciationService = PronunciationService()
    let quizPackService = QuizPackService()
    let streakService: StreakService
    let testingModeService = TestingModeService()
    let timelineService = TimelineService()
    let travelService: TravelService
    let widgetDataBridge: WidgetDataBridge
    let worldBankService = WorldBankService()
    let xpService: XPService

    // MARK: - Init
    init() {
        let database = DatabaseManager()
        let auth = AuthService(db: database)
        let userID = auth.currentUserID
        // Before any store loads, so each one reads the signed-in user's data.
        UserScope.activate(userID)
        let xp = XPService(db: database, userID: userID)
        let achievement = AchievementService(db: database, xpService: xp, userID: userID)
        databaseManager = database
        authService = auth
        xpService = xp
        achievementService = achievement
        streakService = StreakService(db: database, xpService: xp, achievementService: achievement, userID: userID)
        favoritesService = FavoritesService(container: database.container, userID: userID)
        learningPathService = LearningPathService()
        travelService = TravelService()
        explorationService = ExplorationService()
        widgetDataBridge = WidgetDataBridge(countryDataService: countryDataService)
    }
}

// MARK: - Environment
extension View {
    /// Puts every app-wide service into the environment.
    func environment(_ dependencies: AppDependencies) -> some View {
        environment(dependencies.achievementService)
            .environment(dependencies.authService)
            .environment(dependencies.collectionService)
            .environment(dependencies.countryDataService)
            .environment(dependencies.currencyService)
            #if !os(tvOS)
            .environment(dependencies.customQuizService)
            #endif
            .environment(dependencies.databaseManager)
            .environment(dependencies.entitlementService)
            .environment(dependencies.explorationService)
            .environment(dependencies.favoritesService)
            .environment(dependencies.flashcardService)
            .environment(dependencies.gameCenterService)
            .environment(dependencies.geoJSONCache)
            .environment(dependencies.hapticsService)
            .environment(dependencies.languageService)
            .environment(dependencies.learningPathService)
            .environment(dependencies.pronunciationService)
            .environment(dependencies.quizPackService)
            .environment(dependencies.streakService)
            .environment(dependencies.testingModeService)
            .environment(dependencies.timelineService)
            .environment(dependencies.travelService)
            .environment(dependencies.worldBankService)
            .environment(dependencies.xpService)
    }
}
