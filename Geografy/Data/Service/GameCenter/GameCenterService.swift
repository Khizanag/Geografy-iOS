import Foundation
import GameKit
import Geografy_Core_Common
import Observation

@Observable
@MainActor
final class GameCenterService {
    private(set) var isAuthenticated = false
    private(set) var playerDisplayName: String?

    private let pendingKey = "gamecenter_pending_submissions"

    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, error in
            guard let self else { return }
            let player = GKLocalPlayer.local
            if player.isAuthenticated {
                self.isAuthenticated = true
                self.playerDisplayName = player.displayName
                Task { await self.retryPendingSubmissions() }
            } else {
                self.isAuthenticated = false
                self.playerDisplayName = nil
                if let error = error as? NSError, error.code == GKError.notSupported.rawValue || error.code == 15 {
                    // Game Center not configured for this bundle ID — expected in dev builds
                }
            }
        }
    }

    func submitScore(_ score: Int, to leaderboardID: String) async {
        guard isAuthenticated else {
            enqueue(PendingSubmission(kind: .score, identifier: leaderboardID, value: Double(score)))
            return
        }
        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboardID]
            )
        } catch {
            enqueue(PendingSubmission(kind: .score, identifier: leaderboardID, value: Double(score)))
        }
    }

    func reportAchievement(id gameCenterID: String, percentComplete: Double) async {
        guard isAuthenticated else {
            enqueue(PendingSubmission(kind: .achievement, identifier: gameCenterID, value: percentComplete))
            return
        }
        do {
            let achievement = GKAchievement(identifier: gameCenterID)
            achievement.percentComplete = percentComplete
            achievement.showsCompletionBanner = true
            try await GKAchievement.report([achievement])
        } catch {
            enqueue(PendingSubmission(kind: .achievement, identifier: gameCenterID, value: percentComplete))
        }
    }

    func loadFriends() async -> [GKPlayer] {
        guard isAuthenticated else { return [] }
        do {
            let status = try await GKLocalPlayer.local.loadFriendsAuthorizationStatus()
            switch status {
            case .authorized:
                return try await GKLocalPlayer.local.loadFriends()
            case .notDetermined:
                // Triggers the system prompt asking user to share friends
                return try await GKLocalPlayer.local.loadFriends()
            default:
                return []
            }
        } catch {
            return []
        }
    }

    func loadFriendLeaderboardEntries(for leaderboardID: String) async -> [GKLeaderboard.Entry] {
        guard isAuthenticated else { return [] }
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return [] }
            let (_, entries, _) = try await leaderboard.loadEntries(
                for: .friendsOnly,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 25)
            )
            return entries
        } catch {
            return []
        }
    }

    func retryPendingSubmissions() async {
        guard isAuthenticated else { return }
        let pending = loadQueue()
        guard !pending.isEmpty else { return }
        clearQueue()
        for item in pending {
            switch item.kind {
            case .score:
                await submitScore(Int(item.value), to: item.identifier)
            case .achievement:
                await reportAchievement(id: item.identifier, percentComplete: item.value)
            }
        }
    }
}

// MARK: - Leaderboard IDs
extension GameCenterService {
    enum LeaderboardID {
        static let totalXP = "com.khizanag.geografy.leaderboard.totalxp"
        static let longestStreak = "com.khizanag.geografy.leaderboard.longeststreak"
        static let quizHighScore = "com.khizanag.geografy.leaderboard.quizhighscore"
        static let quizPerfectRuns = "com.khizanag.geografy.leaderboard.quizperfectruns"
        static let countriesVisited = "com.khizanag.geografy.leaderboard.countriesvisited"
        static let dailyChallengesWon = "com.khizanag.geografy.leaderboard.dailychallengeswon"
        static let speedRunWorld = "com.khizanag.geografy.leaderboard.speedrun.world"
        static let speedRunAfrica = "com.khizanag.geografy.leaderboard.speedrun.africa"
        static let speedRunAsia = "com.khizanag.geografy.leaderboard.speedrun.asia"
        static let speedRunEurope = "com.khizanag.geografy.leaderboard.speedrun.europe"
        static let speedRunNorthAmerica = "com.khizanag.geografy.leaderboard.speedrun.northamerica"
        static let speedRunSouthAmerica = "com.khizanag.geografy.leaderboard.speedrun.southamerica"
        static let speedRunOceania = "com.khizanag.geografy.leaderboard.speedrun.oceania"
    }

    enum AchievementID {
        static let quizFirst = "geografy.achievement.first_quiz"
        static let quizPerfect = "geografy.achievement.perfect_score"
        static let quizFanatic = "geografy.achievement.quiz_fanatic"
        static let quizLegend = "geografy.achievement.quiz_legend"
        static let speedDemon = "geografy.achievement.speed_demon"
        static let allTypes = "geografy.achievement.all_types"
        static let streak3 = "geografy.achievement.getting_started"
        static let streak7 = "geografy.achievement.week_warrior"
        static let streak30 = "geografy.achievement.monthly_champion"
        static let streak100 = "geografy.achievement.dedicated_scholar"
        static let level2 = "geografy.achievement.continental_explorer"
        static let level5 = "geografy.achievement.world_traveler"
        static let level10 = "geografy.achievement.globe_trotter"
        static let travel1 = "geografy.achievement.first_stamp"
        static let travel10 = "geografy.achievement.frequent_flyer"
        static let travel50 = "geografy.achievement.world_adventurer"
        static let dailyFirst = "geografy.achievement.first_steps"
        static let flagCollector = "geografy.achievement.flag_collector"
        static let capitalExpert = "geografy.achievement.capital_expert"
        static let orgScholar = "geografy.achievement.org_scholar"
        static let bucketList = "geografy.achievement.bucket_list"
        static let masterExplorer = "geografy.achievement.master_explorer"
    }
}

// MARK: - Retry Queue
private extension GameCenterService {
    struct PendingSubmission: Codable {
        enum Kind: String, Codable {
            case score, achievement
        }
        let kind: Kind
        let identifier: String
        let value: Double
    }

    func enqueue(_ item: PendingSubmission) {
        var queue = loadQueue()
        queue.append(item)
        guard let data = try? JSONEncoder().encode(queue) else { return }
        UserDefaults.standard.set(data, forKey: pendingKey)
    }

    func loadQueue() -> [PendingSubmission] {
        guard let data = UserDefaults.standard.data(forKey: pendingKey),
              let items = try? JSONDecoder().decode([PendingSubmission].self, from: data)
        else { return [] }
        return items
    }

    func clearQueue() {
        UserDefaults.standard.removeObject(forKey: pendingKey)
    }
}
