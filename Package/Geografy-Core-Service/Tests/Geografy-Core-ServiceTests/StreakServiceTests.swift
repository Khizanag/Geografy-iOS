import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@MainActor
@Suite("StreakService")
struct StreakServiceTests {
    @Test("Learning counts today toward the streak and pays the daily bonus once")
    func learningCountsToday() {
        let (xp, streak) = Self.makeServices()

        xp.award(20, source: .quizCompletedEasy)
        #expect(streak.hasPlayedToday)
        #expect(streak.currentStreak == 1)
        #expect(xp.totalXP == 30)

        xp.award(20, source: .pinDropCompleted)
        #expect(xp.totalXP == 50)
    }

    @Test("Exploring, travel, and achievements don't count as learning")
    func nonLearningDoesNotCount() {
        let (xp, streak) = Self.makeServices()

        xp.award(5, source: .countryExplored)
        xp.award(20, source: .travelVisited)
        xp.award(50, source: .achievementUnlocked)

        #expect(!streak.hasPlayedToday)
        #expect(streak.currentStreak == 0)
    }
}

// MARK: - Helpers
private extension StreakServiceTests {
    static func makeServices() -> (XPService, StreakService) {
        let userID = UUID().uuidString
        let database = DatabaseManager(inMemory: true)
        let xp = XPService(db: database, userID: userID)
        let achievements = AchievementService(db: database, xpService: xp, userID: userID)
        let streak = StreakService(db: database, xpService: xp, achievementService: achievements, userID: userID)
        return (xp, streak)
    }
}
