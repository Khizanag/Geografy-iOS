#if DEBUG
import Foundation
import Geografy_Core_Common
import Geografy_Core_Service
import SwiftData

/// The Testing Lab's changes to stored progress: each one writes the store the same way the app does, then has the
/// owning service reload, so every screen shows the result at once.
@MainActor
struct TestingLabData {
    let database: DatabaseManager
    let xpService: XPService
    let achievementService: AchievementService
    let streakService: StreakService

    private var context: ModelContext { database.mainContext }
    private var userID: String { xpService.currentUserID }

    // MARK: - XP
    /// Awards exactly what's left of the current level, so the real level-up celebration plays.
    func reachNextLevel() {
        let level = xpService.currentLevel
        guard level.maxXP != Int.max else { return }
        xpService.award(level.maxXP - xpService.totalXP, source: .dailyBonus)
    }

    func resetXP() {
        let userID = userID
        try? context.delete(model: XPRecord.self, where: #Predicate { $0.userID == userID })
        context.saveOrLog()
        xpService.refreshXP()
    }

    // MARK: - Achievements
    /// The first achievement still locked, unlocked the usual way: its XP is awarded and its banner shows.
    func unlockNextAchievement() {
        guard let next = AchievementCatalog.all.first(where: { !achievementService.isUnlocked($0.id) }) else { return }
        achievementService.unlock(next.id)
    }

    func resetAchievements() {
        let userID = userID
        try? context.delete(model: UnlockedAchievement.self, where: #Predicate { $0.userID == userID })
        context.saveOrLog()
        achievementService.saveProgress([:])
        achievementService.pinnedIDs.forEach(achievementService.togglePin)
        achievementService.refreshUnlocked()
    }

    // MARK: - Streak
    /// Replaces the login history with one login a day for the last `days` days, today included.
    func setStreak(days: Int) {
        let userID = userID
        try? context.delete(model: StreakRecord.self, where: #Predicate { $0.userID == userID })
        let today = Calendar.current.startOfDay(for: .now)
        for offset in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { continue }
            context.insert(StreakRecord(userID: userID, date: date))
        }
        context.saveOrLog()
        streakService.refreshStreak()
    }

    // MARK: - Settings
    /// Forgets every game's last setup, such as the quiz type and region, so each opens on its defaults.
    static func resetGameSetups() {
        let prefixes = ["quiz_", "pinDrop_", "speedrun_", "mapPuzzle_", "wordSearch_"]
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where prefixes.contains(where: key.hasPrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    /// Empties the open store before the lab deletes the app's files, so nothing writes to it on the way out.
    func eraseStore() {
        database.container.deleteAllData()
    }
}
#endif
