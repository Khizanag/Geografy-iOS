import Combine
import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
@MainActor
public final class AchievementService {
    public private(set) var unlockedAchievements: [UnlockedAchievement] = []
    public private(set) var pinnedIDs: [String] = []

    public let unlockPublisher = PassthroughSubject<AchievementDefinition, Never>()

    public var currentUserID: String

    private let db: DatabaseManager
    private let xpService: XPService
    private let progressKey = "achievement_progress_v2"
    private let pinnedKey = "achievement_pinned"

    public init(db: DatabaseManager, xpService: XPService, userID: String) {
        self.db = db
        self.xpService = xpService
        self.currentUserID = userID
    }

    public func switchUser(id: String) {
        currentUserID = id
        refreshUnlocked()
        loadPinnedIDs()
    }

    // MARK: - Query
    public func isUnlocked(_ achievementID: String) -> Bool {
        unlockedAchievements.contains { $0.id == achievementID }
    }

    public func progress(for achievementID: String) -> AchievementProgress {
        let stored = loadProgress()
        if let existing = stored[achievementID] {
            return existing
        }
        let definition = AchievementCatalog.all.first { $0.id == achievementID }
        return AchievementProgress(
            achievementID: achievementID,
            currentValue: 0,
            isUnlocked: isUnlocked(achievementID),
            targetValue: definition?.targetValue ?? 1
        )
    }

    public func isPinned(_ achievementID: String) -> Bool {
        pinnedIDs.contains(achievementID)
    }

    public var canPinMore: Bool {
        pinnedIDs.count < 3
    }

    // MARK: - Progress Tracking
    public func updateProgress(_ achievementID: String, value: Int) {
        var allProgress = loadProgress()
        let definition = AchievementCatalog.all.first { $0.id == achievementID }
        let target = definition?.targetValue ?? 1

        var entry = allProgress[achievementID] ?? AchievementProgress(
            achievementID: achievementID,
            currentValue: 0,
            isUnlocked: false,
            targetValue: target
        )
        entry.currentValue = max(entry.currentValue, value)
        entry.targetValue = target

        if entry.currentValue >= target, !entry.isUnlocked {
            entry.isUnlocked = true
            entry.unlockedAt = Date.now
            unlock(achievementID)
        }

        allProgress[achievementID] = entry
        saveProgress(allProgress)
    }

    // MARK: - Pinning
    public func togglePin(_ achievementID: String) {
        if let index = pinnedIDs.firstIndex(of: achievementID) {
            pinnedIDs.remove(at: index)
        } else if pinnedIDs.count < 3 {
            pinnedIDs.append(achievementID)
        }
        savePinnedIDs()
    }

    // MARK: - Check Methods
    public func checkExplorerAchievements(totalExplored: Int) {
        let milestones: [(Int, String)] = [
            (5, "explorer_5"),
            (10, "explorer_10"),
            (50, "explorer_50"),
            (100, "explorer_100"),
            (195, "explorer_195"),
        ]
        for (_, id) in milestones {
            updateProgress(id, value: totalExplored)
        }
    }

    public func checkQuizAchievements(history: [QuizHistoryRecord]) {
        let total = history.count
        updateProgress("quiz_1", value: total)
        updateProgress("quiz_10", value: total)
        updateProgress("quiz_50", value: total)
        updateProgress("quiz_100", value: total)

        let completedTypes = Set(history.map { $0.quizType })
        updateProgress("all_types", value: completedTypes.count)

        let perfectCount = history.filter { $0.accuracy == 1.0 }.count
        updateProgress("perfect_1", value: perfectCount)
        updateProgress("perfect_5", value: perfectCount)
        updateProgress("perfect_20", value: perfectCount)

        let flagCount = history.filter { $0.quizType == QuizType.flagQuiz.rawValue }.count
        updateProgress("flag_5", value: flagCount)

        let capitalCount = history.filter { $0.quizType == QuizType.capitalQuiz.rawValue }.count
        updateProgress("capital_5", value: capitalCount)

        let hardFast = history.contains {
            $0.difficulty == QuizDifficulty.hard.rawValue && $0.totalTimeSeconds < 60
        }
        if hardFast { updateProgress("speed_60", value: 1) }
    }

    public func checkTravelAchievements(visitedCount: Int, wantCount: Int) {
        updateProgress("travel_1", value: visitedCount)
        updateProgress("travel_10", value: visitedCount)
        updateProgress("travel_50", value: visitedCount)
        updateProgress("bucket_5", value: wantCount)
    }

    public func checkStreakAchievements(streak: Int) {
        updateProgress("streak_3", value: streak)
        updateProgress("streak_7", value: streak)
        updateProgress("streak_30", value: streak)
        updateProgress("streak_100", value: streak)
    }

    public func checkKnowledgeAchievements(orgsOpened: Int) {
        updateProgress("org_all", value: orgsOpened)
    }

    public func checkFlashcardAchievements(masteredCount: Int) {
        updateProgress("flashcard_10", value: masteredCount)
        updateProgress("flashcard_50", value: masteredCount)
        updateProgress("flashcard_200", value: masteredCount)
    }

    public func checkContinentAchievement(continentID: String) {
        updateProgress("continent_\(continentID)", value: 1)
    }

    public func checkSocialAchievements(shareCount: Int) {
        updateProgress("share_1", value: shareCount)
        updateProgress("share_10", value: shareCount)
    }
}

// MARK: - Persistence
extension AchievementService {
    public func unlock(_ achievementID: String) {
        guard !isUnlocked(achievementID),
              let definition = AchievementCatalog.all.first(where: { $0.id == achievementID })
        else { return }

        let record = UnlockedAchievement(id: achievementID, userID: currentUserID)
        db.mainContext.insert(record)
        try? db.mainContext.save()

        if definition.xpReward > 0 {
            xpService.award(definition.xpReward, source: .achievementUnlocked)
        }

        refreshUnlocked()
        unlockPublisher.send(definition)
    }

    public func refreshUnlocked() {
        let userID = currentUserID
        let descriptor = FetchDescriptor<UnlockedAchievement>(
            predicate: #Predicate { $0.userID == userID }
        )
        unlockedAchievements = (try? db.mainContext.fetch(descriptor)) ?? []
    }

    public func loadProgress() -> [String: AchievementProgress] {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let decoded = try? JSONDecoder().decode([String: AchievementProgress].self, from: data)
        else { return [:] }
        return decoded
    }

    public func saveProgress(_ progress: [String: AchievementProgress]) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: progressKey)
    }

    public func loadPinnedIDs() {
        pinnedIDs = UserDefaults.standard.stringArray(forKey: pinnedKey) ?? []
    }

    public func savePinnedIDs() {
        UserDefaults.standard.set(pinnedIDs, forKey: pinnedKey)
    }
}
