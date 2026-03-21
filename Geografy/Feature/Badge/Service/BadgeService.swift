import Combine
import Foundation
import Observation

@Observable
@MainActor
final class BadgeService {
    private(set) var unlockedBadges: [UnlockedBadge] = []
    private(set) var pinnedBadgeIDs: [String] = []

    let unlockPublisher = PassthroughSubject<BadgeDefinition, Never>()

    private let userDefaultsKey = "com.khizanag.geografy.unlockedBadges"
    private let pinnedKey = "com.khizanag.geografy.pinnedBadges"

    init() {
        loadUnlockedBadges()
        loadPinnedBadges()
    }

    func isUnlocked(_ badgeID: String) -> Bool {
        unlockedBadges.contains { $0.id == badgeID }
    }

    func unlockedBadge(for badgeID: String) -> UnlockedBadge? {
        unlockedBadges.first { $0.id == badgeID }
    }

    func isPinned(_ badgeID: String) -> Bool {
        pinnedBadgeIDs.contains(badgeID)
    }

    func togglePin(_ badgeID: String) {
        guard isUnlocked(badgeID) else { return }
        if let index = pinnedBadgeIDs.firstIndex(of: badgeID) {
            pinnedBadgeIDs.remove(at: index)
        } else {
            guard pinnedBadgeIDs.count < 3 else { return }
            pinnedBadgeIDs.append(badgeID)
        }
        savePinnedBadges()
    }

    var pinnedBadges: [BadgeDefinition] {
        pinnedBadgeIDs.compactMap { pinID in
            BadgeDefinition.all.first { $0.id == pinID }
        }
    }

    var collectionProgress: Double {
        let total = BadgeDefinition.all.count
        guard total > 0 else { return 0 }
        return Double(unlockedBadges.count) / Double(total)
    }

    func progress(for badge: BadgeDefinition) -> BadgeProgress {
        let unlocked = unlockedBadge(for: badge.id)
        let currentValue = unlocked?.currentValue
            ?? storedProgress(for: badge.id)
        let fraction = min(
            Double(currentValue) / Double(max(badge.targetValue, 1)),
            1.0
        )
        return BadgeProgress(
            currentValue: currentValue,
            targetValue: badge.targetValue,
            fraction: fraction,
            isComplete: unlocked != nil
        )
    }
}

// MARK: - Badge Progress Model

struct BadgeProgress {
    let currentValue: Int
    let targetValue: Int
    let fraction: Double
    let isComplete: Bool
}

// MARK: - Unlock Logic

extension BadgeService {
    func checkAndUnlock(
        badgeID: String,
        currentValue: Int
    ) {
        guard let definition = BadgeDefinition.all.first(
            where: { $0.id == badgeID }
        ) else { return }

        storeProgress(badgeID: badgeID, value: currentValue)

        guard !isUnlocked(badgeID),
              currentValue >= definition.targetValue
        else { return }

        let badge = UnlockedBadge(
            id: badgeID,
            unlockedAt: .now,
            currentValue: currentValue
        )
        unlockedBadges.append(badge)
        saveUnlockedBadges()
        unlockPublisher.send(definition)
    }

    func checkExplorerBadges(totalExplored: Int) {
        let explorerBadges = BadgeDefinition.all.filter {
            $0.category == .explorer
        }
        for badge in explorerBadges {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: totalExplored
            )
        }
    }

    func checkQuizBadges(totalCompleted: Int) {
        let quizBadges = BadgeDefinition.all.filter {
            $0.category == .quizMaster
        }
        for badge in quizBadges {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: totalCompleted
            )
        }
    }

    func checkStreakBadges(currentStreak: Int) {
        let streakBadges = BadgeDefinition.all.filter {
            $0.category == .streakWarrior
        }
        for badge in streakBadges {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: currentStreak
            )
        }
    }

    func checkPerfectScoreBadges(perfectCount: Int) {
        let perfectBadges = BadgeDefinition.all.filter {
            $0.category == .perfectScore
        }
        for badge in perfectBadges {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: perfectCount
            )
        }
    }

    func checkSpeedBadges(completionTimeSeconds: Int) {
        let speedBadges = BadgeDefinition.all.filter {
            $0.category == .speedDemon
        }
        for badge in speedBadges where completionTimeSeconds <= badge.targetValue {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: badge.targetValue
            )
        }
    }

    func checkTimeBadges(hour: Int, totalEarly: Int, totalNight: Int) {
        if hour < 8 {
            let earlyBadges = BadgeDefinition.all.filter {
                $0.category == .earlyBird
            }
            for badge in earlyBadges {
                checkAndUnlock(
                    badgeID: badge.id,
                    currentValue: totalEarly
                )
            }
        }
        if hour >= 22 {
            let nightBadges = BadgeDefinition.all.filter {
                $0.category == .nightOwl
            }
            for badge in nightBadges {
                checkAndUnlock(
                    badgeID: badge.id,
                    currentValue: totalNight
                )
            }
        }
    }

    func checkSocialBadges(shareCount: Int) {
        let socialBadges = BadgeDefinition.all.filter {
            $0.category == .socialButterfly
        }
        for badge in socialBadges {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: shareCount
            )
        }
    }

    func checkFlashcardBadges(masteredCount: Int) {
        let flashcardBadges = BadgeDefinition.all.filter {
            $0.category == .flashcardScholar
        }
        for badge in flashcardBadges {
            checkAndUnlock(
                badgeID: badge.id,
                currentValue: masteredCount
            )
        }
    }

    func unlockContinentBadge(continentID: String) {
        checkAndUnlock(
            badgeID: "badge_continent_\(continentID)",
            currentValue: 1
        )
    }
}

// MARK: - Persistence

private extension BadgeService {
    func loadUnlockedBadges() {
        guard let data = UserDefaults.standard.data(
            forKey: userDefaultsKey
        ) else { return }
        unlockedBadges = (try? JSONDecoder().decode(
            [UnlockedBadge].self,
            from: data
        )) ?? []
    }

    func saveUnlockedBadges() {
        guard let data = try? JSONEncoder().encode(unlockedBadges)
        else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    func loadPinnedBadges() {
        pinnedBadgeIDs = UserDefaults.standard.stringArray(
            forKey: pinnedKey
        ) ?? []
    }

    func savePinnedBadges() {
        UserDefaults.standard.set(pinnedBadgeIDs, forKey: pinnedKey)
    }

    func storeProgress(badgeID: String, value: Int) {
        let key = "com.khizanag.geografy.badgeProgress.\(badgeID)"
        let current = UserDefaults.standard.integer(forKey: key)
        if value > current {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    func storedProgress(for badgeID: String) -> Int {
        let key = "com.khizanag.geografy.badgeProgress.\(badgeID)"
        return UserDefaults.standard.integer(forKey: key)
    }
}
