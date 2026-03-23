# Game Center Integration Plan

Plan for full Game Center integration in Geografy, including leaderboards, achievements, authentication, and ties to the existing gamification system.

---

## Current State

From `Feature/GameCenter/`:
- `LeaderboardScreen.swift` — basic leaderboard view exists
- `GameCenterViewControllerRepresentable.swift` — UIKit wrapper for native GKGameCenterViewController

Authentication and achievement reporting status is unclear — needs audit.

---

## Game Center Setup (App Store Connect)

### Enable Game Center
- Enable in App Capabilities in Xcode: `Signing & Capabilities → Game Center`
- Configure in App Store Connect under the app's Game Center tab

---

## Authentication

### Implementation

```swift
import GameKit

@Observable
final class GameCenterService {
    var isAuthenticated: Bool = false
    var localPlayer: GKLocalPlayer { GKLocalPlayer.local }

    func authenticate(in viewController: UIViewController? = nil) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            if let vc {
                // Present Game Center sign-in UI
                // Find the key window's rootViewController
                UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                self?.isAuthenticated = true
                self?.reportPendingAchievements()
            } else {
                self?.isAuthenticated = false
                // Game Center not available — continue without it
            }
        }
    }
}
```

### When to Authenticate
- On app launch (after splash) — non-blocking
- If not authenticated and user navigates to Profile/Leaderboards, prompt
- Never block gameplay for auth

### Guest Handling
- If user is in guest mode, Game Center auth is still possible (GC has its own account)
- GC auth and Geografy auth are independent; a guest Geografy user can still have GC leaderboard entries

---

## Leaderboards

### Proposed Leaderboard IDs

```swift
enum LeaderboardID: String {
    // Quiz Performance
    case quizHighScore         = "geografy.leaderboard.quiz.highscore"
    case quizPerfectRuns       = "geografy.leaderboard.quiz.perfectruns"
    case quizSpeedRecord       = "geografy.leaderboard.quiz.speedrecord"
    case quizTotalQuestions    = "geografy.leaderboard.quiz.totalquestions"

    // Knowledge / Exploration
    case countriesLearned      = "geografy.leaderboard.countries.learned"
    case totalXP               = "geografy.leaderboard.totalxp"
    case longestStreak         = "geografy.leaderboard.streak.longest"
    case currentStreak         = "geografy.leaderboard.streak.current"

    // Travel
    case countriesVisited      = "geografy.leaderboard.travel.visited"
    case countriesWantToVisit  = "geografy.leaderboard.travel.wanttovisit"

    // Daily Challenges
    case dailyChallengesWon    = "geografy.leaderboard.daily.won"
    case dailyChallengeStreak  = "geografy.leaderboard.daily.streak"
}
```

### Score Reporting

```swift
extension GameCenterService {
    func submitScore(_ score: Int, to leaderboard: LeaderboardID) async {
        guard isAuthenticated else { return }
        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboard.rawValue]
            )
        } catch {
            // Store pending submission in UserDefaults for retry
            pendingScoreSubmissions.append((leaderboard, score))
        }
    }

    func submitHighScore(for quizResult: QuizResult) async {
        await submitScore(quizResult.score, to: .quizHighScore)
        if quizResult.correctAnswers == quizResult.totalQuestions {
            await incrementScore(1, on: .quizPerfectRuns)
        }
        if let timeSeconds = quizResult.timeSeconds {
            await submitScore(timeSeconds, to: .quizSpeedRecord)
            // Note: For speed, LOWER is better — configure in App Store Connect
        }
    }
}
```

### Leaderboard Configuration in App Store Connect

| Leaderboard | Score Format | Order | Recurring? |
|-------------|-------------|-------|------------|
| Quiz High Score | Integer (0–100) | High to Low | No |
| Countries Learned | Integer (0–258) | High to Low | No |
| Total XP | Integer | High to Low | No |
| Longest Streak | Integer (days) | High to Low | No |
| Current Streak | Integer (days) | High to Low | Weekly reset |
| Speed Record | Seconds (integer) | Low to High | No |
| Perfect Runs | Integer count | High to Low | No |
| Countries Visited | Integer (0–197) | High to Low | No |

---

## Achievements

### Proposed Achievements

#### Quiz Achievements
| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `quiz.first` | First Quiz | Complete your first quiz | 5 | No |
| `quiz.perfect.1` | Perfect Score | Get 100% on a quiz | 10 | No |
| `quiz.perfect.10` | Perfect Master | Get 10 perfect scores | 25 | No |
| `quiz.speed.60` | Speed Demon | Complete a 10-question quiz in under 60s | 15 | Yes |
| `quiz.speed.30` | Lightning | Complete a 10-question quiz in under 30s | 50 | Yes |
| `quiz.100` | Century | Complete 100 quizzes | 25 | No |
| `quiz.500` | Marathon | Complete 500 quizzes | 50 | No |
| `quiz.allregions` | World Scholar | Complete a quiz for every continent | 25 | No |
| `quiz.alldifficulties` | Challenge Seeker | Complete quizzes on all 3 difficulties | 15 | No |

#### Geography Knowledge Achievements
| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `countries.10` | Getting Started | Learn 10 countries | 5 | No |
| `countries.50` | Explorer | Learn 50 countries | 15 | No |
| `countries.100` | Geographer | Learn 100 countries | 25 | No |
| `countries.197` | World Expert | Learn all 197 countries | 100 | No |
| `flags.all` | Vexillologist | Correctly identify every flag | 50 | Yes |
| `capitals.all` | Capital Master | Correctly name every capital | 50 | Yes |

#### Streak Achievements
| ID | Name | Description | Points | Hidden |
|----|------|-------------|--------|--------|
| `streak.3` | Starting Habit | 3-day streak | 5 | No |
| `streak.7` | One Week | 7-day streak | 10 | No |
| `streak.30` | Dedicated | 30-day streak | 25 | No |
| `streak.100` | Unstoppable | 100-day streak | 75 | Yes |
| `streak.365` | Legend | 365-day streak | 100 | Yes |

#### Level Achievements (mirror existing XP levels)
| ID | Name | Description | Points |
|----|------|-------------|--------|
| `level.2` | Traveler | Reach Level 2 | 5 |
| `level.5` | Cartographer | Reach Level 5 | 25 |
| `level.10` | Master Geographer | Reach Level 10 (max) | 100 |

#### Travel Achievements
| ID | Name | Description | Points |
|----|------|-------------|--------|
| `travel.1` | First Stamp | Mark your first visited country | 5 |
| `travel.10` | Globetrotter | Visit 10 countries | 15 |
| `travel.50` | Adventurer | Visit 50 countries | 50 |
| `travel.continent` | Continent Conqueror | Visit all countries in a continent | 25 |
| `travel.all` | True Explorer | Visit all 197 countries | 200 |

#### Daily Challenge Achievements
| ID | Name | Description | Points |
|----|------|-------------|--------|
| `daily.first` | Daily Challenger | Complete your first daily challenge | 5 |
| `daily.7` | Weekly Warrior | Complete 7 daily challenges | 15 |
| `daily.30` | Monthly Champion | Complete 30 daily challenges | 50 |

### Achievement Reporting

```swift
extension GameCenterService {
    func reportAchievement(id: AchievementID, percentComplete: Double = 100.0) async {
        guard isAuthenticated else {
            pendingAchievements.append((id, percentComplete))
            return
        }
        let achievement = GKAchievement(identifier: id.rawValue)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true  // Game Center shows native banner

        do {
            try await GKAchievement.report([achievement])
        } catch {
            pendingAchievements.append((id, percentComplete))
        }
    }

    // Incremental achievement (e.g., quiz count)
    func reportIncrementalAchievement(id: AchievementID, current: Int, target: Int) async {
        let percent = min(100.0, (Double(current) / Double(target)) * 100.0)
        await reportAchievement(id: id, percentComplete: percent)
    }
}
```

---

## Integration with Existing Gamification

### XP → Game Center

When XP changes in `XPRecord`, also report to Game Center:

```swift
// In whatever service handles XP gains:
func awardXP(_ amount: Int, source: XPSource) async {
    // Existing local XP logic...
    let newTotal = currentXP + amount

    // Game Center sync
    await gameCenterService.submitScore(newTotal, to: .totalXP)

    // Check level-up achievements
    let newLevel = UserLevel.level(for: newTotal)
    let oldLevel = UserLevel.level(for: currentXP)
    if newLevel.level > oldLevel.level {
        if let achievementID = AchievementID.forLevel(newLevel.level) {
            await gameCenterService.reportAchievement(id: achievementID)
        }
    }
}
```

### Existing Achievement → Game Center

When `UnlockedAchievement` is created locally, mirror to Game Center:

```swift
func unlockAchievement(_ definition: AchievementDefinition) async {
    // Local unlock...
    let record = UnlockedAchievement(...)
    context.insert(record)

    // Game Center mirror
    if let gcID = definition.gameCenterAchievementID {
        await gameCenterService.reportAchievement(id: gcID)
    }
}
```

---

## Native UI vs. Custom UI

### Game Center Native Dashboard
```swift
// Present full Game Center dashboard
func showGameCenter() {
    let vc = GKGameCenterViewController(state: .dashboard)
    vc.gameCenterDelegate = self
    present(vc, animated: true)
}

// Present specific leaderboard
func showLeaderboard(_ id: LeaderboardID) {
    let vc = GKGameCenterViewController(
        leaderboardID: id.rawValue,
        playerScope: .global,
        timeScope: .allTime
    )
    present(vc, animated: true)
}
```

### Custom Leaderboard Screen (existing `LeaderboardScreen.swift`)

For a more branded experience, fetch scores manually:

```swift
func fetchTopScores(for leaderboard: LeaderboardID, limit: Int = 20) async -> [GKLeaderboard.Entry] {
    do {
        let leaderboards = try await GKLeaderboard.loadLeaderboards(
            IDs: [leaderboard.rawValue]
        )
        guard let leaderboard = leaderboards.first else { return [] }
        let (localEntry, entries, _) = try await leaderboard.loadEntries(
            for: .global,
            timeScope: .allTime,
            range: NSRange(location: 1, length: limit)
        )
        return entries
    } catch {
        return []
    }
}
```

---

## Pending Submissions (Offline Handling)

Game Center requires network. Store failed submissions for retry:

```swift
// Persist pending in UserDefaults (small data)
struct PendingGCSubmission: Codable {
    let leaderboardID: String
    let score: Int
    let achievementID: String?
    let achievementPercent: Double?
    let timestamp: Date
}
```

On next successful authentication, flush the pending queue.

---

## Summary: Implementation Priority

| Task | Priority | Effort |
|------|----------|--------|
| Authenticate on launch | High | 1 hour |
| Report XP to totalXP leaderboard | High | 1 hour |
| Report quiz high scores | High | 1 hour |
| Report streak leaderboard | High | 30 min |
| Mirror local achievements to GC | Medium | 2 hours |
| Achievement progress (incremental) | Medium | 2 hours |
| Custom leaderboard screen with GC data | Medium | 3 hours |
| Pending submissions queue | Low | 2 hours |
| All 30+ achievements | Low | 4 hours |
