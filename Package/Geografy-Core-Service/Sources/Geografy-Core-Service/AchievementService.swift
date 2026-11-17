import Combine
import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
@MainActor
public final class AchievementService {
    public private(set) var unlockedAchievements: [UnlockedAchievement] = [] {
        didSet { unlockedIDs = Set(unlockedAchievements.map(\.id)) }
    }
    private var unlockedIDs: Set<String> = []

    /// Unlocked achievements still in the catalog. Stored unlocks can include retired ones, so count with this.
    public var unlockedCount: Int {
        AchievementCatalog.all.count { unlockedIDs.contains($0.id) }
    }
    public private(set) var pinnedIDs: [String] = []

    public let unlockPublisher = PassthroughSubject<AchievementDefinition, Never>()

    public var currentUserID: String

    private let db: DatabaseManager
    private let xpService: XPService
    // Progress belongs to one user, like unlocks do, so signing in or switching users never shows someone else's.
    private var progressKey: String { "achievement_progress_v3_\(currentUserID)" }
    private let pinnedKey = "achievement_pinned"
    /// The decoded progress for `cachedProgressKey`, so screens asking per row don't decode storage each time.
    @ObservationIgnored private var cachedProgress: [String: AchievementProgress]?
    @ObservationIgnored private var cachedProgressKey = ""

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
        unlockedIDs.contains(achievementID)
    }

    public func progress(for achievementID: String) -> AchievementProgress {
        let stored = loadProgress()
        if let existing = stored[achievementID] {
            return existing
        }
        let definition = AchievementCatalog.byID[achievementID]
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
        let definition = AchievementCatalog.byID[achievementID]
        let target = definition?.targetValue ?? 1

        var entry = allProgress[achievementID] ?? AchievementProgress(
            achievementID: achievementID,
            currentValue: 0,
            isUnlocked: false,
            targetValue: target
        )
        entry.currentValue = max(entry.currentValue, value)
        entry.targetValue = target

        // The stored flag can disagree with this user's unlocks, so the unlock records decide.
        if entry.currentValue >= target, !isUnlocked(achievementID) {
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

    public func checkFlashcardAchievements(proficientCount: Int) {
        updateProgress("flashcard_10", value: proficientCount)
        updateProgress("flashcard_50", value: proficientCount)
        updateProgress("flashcard_200", value: proficientCount)
    }

    /// The explorer count, each continent once all its countries are explored (the Americas count North and
    /// South together), and how many continents have at least one.
    public func checkExplorationAchievements(exploredCodes: Set<String>, countries: [Country]) {
        checkExplorerAchievements(totalExplored: exploredCodes.count)
        let byContinent = Dictionary(grouping: countries, by: \.continent)
        let goals: [(id: String, continents: [Country.Continent])] = [
            ("continent_europe", [.europe]),
            ("continent_asia", [.asia]),
            ("continent_africa", [.africa]),
            ("continent_americas", [.northAmerica, .southAmerica]),
            ("continent_oceania", [.oceania]),
        ]
        for goal in goals {
            let members = goal.continents.flatMap { byContinent[$0] ?? [] }
            if !members.isEmpty, members.allSatisfy({ exploredCodes.contains($0.code) }) {
                updateProgress(goal.id, value: 1)
            }
        }
        let reached = Set(
            countries
                .filter { exploredCodes.contains($0.code) && $0.continent != .antarctica }
                .map(\.continent)
        )
        updateProgress("all_continents", value: reached.count)
    }

    public func checkSocialAchievements(shareCount: Int) {
        updateProgress("share_1", value: shareCount)
        updateProgress("share_10", value: shareCount)
    }

    /// Counts a result shared from the app toward the sharing achievements.
    public func recordShare() {
        let key = UserScope.key("shared_results")
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)
        checkSocialAchievements(shareCount: count)
    }

    public func checkSpeedRunAchievements(region: QuizRegion, namedEveryCountry: Bool) {
        if region == .world, namedEveryCountry {
            updateProgress("speed_run_world", value: 1)
        }
    }
}

// MARK: - Persistence
extension AchievementService {
    public func unlock(_ achievementID: String) {
        guard !isUnlocked(achievementID),
              let definition = AchievementCatalog.byID[achievementID]
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
        let key = progressKey
        if let cachedProgress, cachedProgressKey == key {
            return cachedProgress
        }
        let decoded = UserDefaults.standard.data(forKey: key)
            .flatMap { try? JSONDecoder().decode([String: AchievementProgress].self, from: $0) } ?? [:]
        cachedProgress = decoded
        cachedProgressKey = key
        return decoded
    }

    public func saveProgress(_ progress: [String: AchievementProgress]) {
        let key = progressKey
        cachedProgress = progress
        cachedProgressKey = key
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    public func loadPinnedIDs() {
        pinnedIDs = UserDefaults.standard.stringArray(forKey: UserScope.key(pinnedKey)) ?? []
    }

    public func savePinnedIDs() {
        UserDefaults.standard.set(pinnedIDs, forKey: UserScope.key(pinnedKey))
    }
}
