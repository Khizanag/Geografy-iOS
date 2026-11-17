import Foundation
import GameKit
import Geografy_Core_Common
import Observation

@Observable
@MainActor
public final class GameCenterService {
    public private(set) var isAuthenticated = false
    public private(set) var playerDisplayName: String?

    private let pendingKey = "gamecenter_pending_submissions"

    public init() {}

    public func authenticatePlayer() {
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

    public func submitScore(_ score: Int, to leaderboardID: String) async {
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

    public func reportAchievement(id gameCenterID: String, percentComplete: Double) async {
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

    public func retryPendingSubmissions() async {
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
public extension GameCenterService {
    enum LeaderboardID {
        public static let totalXP = "com.khizanag.geografy.leaderboard.totalxp"
        public static let longestStreak = "com.khizanag.geografy.leaderboard.longeststreak"
        public static let quizHighScore = "com.khizanag.geografy.leaderboard.quizhighscore"
        public static let quizPerfectRuns = "com.khizanag.geografy.leaderboard.quizperfectruns"
        public static let countriesVisited = "com.khizanag.geografy.leaderboard.countriesvisited"
        public static let dailyChallengesWon = "com.khizanag.geografy.leaderboard.dailychallengeswon"
        public static let speedRunWorld = "com.khizanag.geografy.leaderboard.speedrun.world"
        public static let speedRunAfrica = "com.khizanag.geografy.leaderboard.speedrun.africa"
        public static let speedRunAsia = "com.khizanag.geografy.leaderboard.speedrun.asia"
        public static let speedRunEurope = "com.khizanag.geografy.leaderboard.speedrun.europe"
        public static let speedRunNorthAmerica = "com.khizanag.geografy.leaderboard.speedrun.northamerica"
        public static let speedRunSouthAmerica = "com.khizanag.geografy.leaderboard.speedrun.southamerica"
        public static let speedRunOceania = "com.khizanag.geografy.leaderboard.speedrun.oceania"
    }
}

// MARK: - Retry Queue
private extension GameCenterService {
    struct PendingSubmission: Codable {
        enum Kind: String, Codable {
            case score
            case achievement
        }
        let kind: Kind
        let identifier: String
        let value: Double
    }

    func enqueue(_ item: PendingSubmission) {
        var queue = loadQueue()
        queue.append(item)
        UserDefaults.standard.setEncoded(queue, forKey: pendingKey)
    }

    func loadQueue() -> [PendingSubmission] {
        UserDefaults.standard.decoded([PendingSubmission].self, forKey: pendingKey) ?? []
    }

    func clearQueue() {
        UserDefaults.standard.removeObject(forKey: pendingKey)
    }
}
