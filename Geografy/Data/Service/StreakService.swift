import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class StreakService {
    private(set) var currentStreak: Int = 0

    var currentUserID: String

    private let db: DatabaseManager
    private let xpService: XPService
    private let achievementService: AchievementService

    init(db: DatabaseManager, xpService: XPService, achievementService: AchievementService, userID: String) {
        self.db = db
        self.xpService = xpService
        self.achievementService = achievementService
        self.currentUserID = userID
        refreshStreak()
    }

    func switchUser(id: String) {
        currentUserID = id
        refreshStreak()
    }

    /// Call on every app foreground event.
    func recordDailyLogin() {
        let today = Calendar.current.startOfDay(for: .now)
        let userID = currentUserID

        let descriptor = FetchDescriptor<StreakRecord>(
            predicate: #Predicate { $0.userID == userID && $0.date == today }
        )
        let existing = (try? db.mainContext.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let record = StreakRecord(userID: userID, date: today)
        db.mainContext.insert(record)
        try? db.mainContext.save()

        xpService.award(10, source: .dailyLogin)

        refreshStreak()
        checkMilestones()
        updateProfileStreak()
        achievementService.checkStreakAchievements(streak: currentStreak)
    }
}

// MARK: - Helpers

private extension StreakService {
    func refreshStreak() {
        let userID = currentUserID
        var descriptor = FetchDescriptor<StreakRecord>(
            predicate: #Predicate { $0.userID == userID }
        )
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        let records = (try? db.mainContext.fetch(descriptor)) ?? []
        currentStreak = computeConsecutiveDays(from: records)
    }

    func computeConsecutiveDays(from records: [StreakRecord]) -> Int {
        guard !records.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        guard let first = records.first,
              calendar.isDate(first.date, inSameDayAs: today) ||
              calendar.isDate(first.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        else { return 0 }

        var streak = 1
        for index in 1..<records.count {
            let expected = calendar.date(byAdding: .day, value: -1, to: records[index - 1].date)!
            if calendar.isDate(records[index].date, inSameDayAs: expected) {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    func checkMilestones() {
        switch currentStreak {
        case 7:
            xpService.award(50, source: .streakMilestone7)
        case 30:
            xpService.award(200, source: .streakMilestone30)
        case 100:
            xpService.award(500, source: .streakMilestone100)
        default:
            break
        }
    }

    func updateProfileStreak() {
        let userID = currentUserID
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.id == userID }
        )
        guard let profile = (try? db.mainContext.fetch(descriptor))?.first else { return }
        profile.currentStreak = currentStreak
        if currentStreak > profile.longestStreak {
            profile.longestStreak = currentStreak
        }
        try? db.mainContext.save()
    }
}
