import Foundation
import GameKit
import Observation

@Observable
@MainActor
final class GameCenterService {
    private(set) var isAuthenticated = false

    private let pendingKey = "gamecenter_pending_submissions"

    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, _ in
            guard let self else { return }
            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                Task { await self.retryPendingSubmissions() }
            } else {
                self.isAuthenticated = false
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
        static let quizHighScore = "com.khizanag.geografy.leaderboard.quizhighscore"
        static let countriesVisited = "com.khizanag.geografy.leaderboard.countriesvisited"
        static let speedRunWorld = "com.khizanag.geografy.leaderboard.speedrun.world"
        static let speedRunAfrica = "com.khizanag.geografy.leaderboard.speedrun.africa"
        static let speedRunAsia = "com.khizanag.geografy.leaderboard.speedrun.asia"
        static let speedRunEurope = "com.khizanag.geografy.leaderboard.speedrun.europe"
        static let speedRunNorthAmerica = "com.khizanag.geografy.leaderboard.speedrun.northamerica"
        static let speedRunSouthAmerica = "com.khizanag.geografy.leaderboard.speedrun.southamerica"
        static let speedRunOceania = "com.khizanag.geografy.leaderboard.speedrun.oceania"
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
