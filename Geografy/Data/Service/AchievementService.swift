import Combine
import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class AchievementService {
    private(set) var unlockedAchievements: [UnlockedAchievement] = []

    let unlockPublisher = PassthroughSubject<AchievementDefinition, Never>()

    var currentUserID: String

    private let db: DatabaseManager
    private let xpService: XPService

    init(db: DatabaseManager, xpService: XPService, userID: String) {
        self.db = db
        self.xpService = xpService
        self.currentUserID = userID
        refreshUnlocked()
    }

    func switchUser(id: String) {
        currentUserID = id
        refreshUnlocked()
    }

    func isUnlocked(_ achievementID: String) -> Bool {
        unlockedAchievements.contains { $0.id == achievementID }
    }

    func checkExplorerAchievements(totalExplored: Int) {
        let milestones: [(Int, String)] = [
            (1, "first_steps"),
            (10, "continental_explorer"),
            (50, "world_traveler"),
            (100, "globe_trotter"),
            (195, "master_explorer"),
        ]
        for (threshold, id) in milestones where totalExplored >= threshold {
            unlock(id)
        }
    }

    func checkQuizAchievements(history: [QuizHistoryRecord]) {
        let total = history.count
        if total >= 1 { unlock("first_quiz") }
        if total >= 10 { unlock("quiz_fanatic") }
        if total >= 100 { unlock("quiz_legend") }

        if history.contains(where: { $0.accuracy == 1.0 }) {
            unlock("perfect_score")
        }

        let hardFast = history.contains {
            $0.difficulty == QuizDifficulty.hard.rawValue && $0.totalTimeSeconds < 60
        }
        if hardFast { unlock("speed_demon") }

        let completedTypes = Set(history.map { $0.quizType })
        if QuizType.allCases.allSatisfy({ completedTypes.contains($0.rawValue) }) {
            unlock("all_types")
        }

        let flagCount = history.filter { $0.quizType == QuizType.flagQuiz.rawValue }.count
        if flagCount >= 5 { unlock("flag_collector") }

        let capitalCount = history.filter { $0.quizType == QuizType.capitalQuiz.rawValue }.count
        if capitalCount >= 5 { unlock("capital_expert") }
    }

    func checkTravelAchievements(visitedCount: Int, wantCount: Int) {
        if visitedCount >= 1 { unlock("first_stamp") }
        if visitedCount >= 10 { unlock("frequent_flyer") }
        if visitedCount >= 50 { unlock("world_adventurer") }
        if wantCount >= 5 { unlock("bucket_list") }
    }

    func checkStreakAchievements(streak: Int) {
        if streak >= 3 { unlock("getting_started") }
        if streak >= 7 { unlock("week_warrior") }
        if streak >= 30 { unlock("monthly_champion") }
        if streak >= 100 { unlock("dedicated_scholar") }
    }

    func checkKnowledgeAchievements(orgsOpened: Int) {
        if orgsOpened >= 16 { unlock("org_scholar") }
    }
}

// MARK: - Helpers

private extension AchievementService {
    func unlock(_ achievementID: String) {
        guard !isUnlocked(achievementID),
              let definition = AchievementCatalog.all.first(where: { $0.id == achievementID })
        else { return }

        let record = UnlockedAchievement(id: achievementID, userID: currentUserID)
        db.mainContext.insert(record)
        try? db.mainContext.save()

        xpService.award(definition.xpReward, source: .achievementUnlocked)
        refreshUnlocked()
        unlockPublisher.send(definition)
    }

    func refreshUnlocked() {
        let userID = currentUserID
        let descriptor = FetchDescriptor<UnlockedAchievement>(
            predicate: #Predicate { $0.userID == userID }
        )
        unlockedAchievements = (try? db.mainContext.fetch(descriptor)) ?? []
    }
}
