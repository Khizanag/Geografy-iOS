# Geografy — Architecture Plan: Auth, Profile, Gamification, Game Center, Subscriptions

> Generated: 2026-03-21
> Status: Approved for implementation
> Scope: Phases A–H covering authentication, user profiles, XP/leveling, achievements, Game Center, and StoreKit 2 subscriptions.

---

## Current Codebase State

**85 Swift files.** The app is in solid Phase 1-2 MVP state:

- Interactive world map (GeoJSON, pinch/zoom, country selection, tap-to-select)
- Country detail screen (flag, capital, area, population, organizations, language chart)
- 6 quiz types (Flag Quiz, Capital Quiz, Country-from-Flag, Reverse Flag, Reverse Capital, Population Order, Area Order)
- Travel tracker (visited / want-to-visit, stored in UserDefaults)
- Favorites system (UserDefaults)
- 16 international organizations with detail screens
- Home screen with map carousel and hardcoded XP progress card
- `AchievementsScreen` — `ComingSoonView` placeholder only

**Not yet implemented:** Auth, user profiles, XP system, achievement logic, Game Center, subscriptions.

**Existing persistence:** 100% UserDefaults. No SwiftData, no Keychain, no cloud.

---

## 1. Persistence Strategy

Three layers, each with a clear responsibility:

| Layer | What lives here | Framework |
|---|---|---|
| **Keychain** | Auth tokens, Apple user identifier, guest UUID | `Security` |
| **SwiftData** | All user data: profile, XP log, quiz history, achievements, streaks | `SwiftData` |
| **UserDefaults** | Existing: favorites, travel status, theme, territory settings — **unchanged** | `Foundation` |
| **Future** | Cloud sync — schema already compatible | `CloudKit` |

### CloudKit Readiness Rule

Design every SwiftData `@Model` with CloudKit-compatible field types from day one:
- Use `String` for enum storage (raw values), never store enum cases directly
- No non-optional optional relationships
- No non-primitive `Codable` types without a value transformer
- No `UUID` primary keys (CloudKit uses String record IDs) — use `String` IDs

This means enabling CloudKit later requires only a one-line change to `ModelConfiguration`. Zero schema migration, zero data loss.

---

## 2. SwiftData Models

Five new `@Model` types. All fields listed.

### `UserProfile`

```swift
@Model final class UserProfile {
    var id: String                // Apple user ID, Google sub, or generated guest UUID
    var displayName: String
    var email: String?
    var isGuest: Bool
    var createdAt: Date
    var lastLoginAt: Date
    var currentStreak: Int        // consecutive days — updated by StreakService
    var longestStreak: Int        // all-time longest — updated whenever currentStreak exceeds it
}
```

### `XPRecord`

```swift
@Model final class XPRecord {
    var id: String                // UUID().uuidString
    var userID: String
    var amount: Int
    var source: String            // XPSource.rawValue
    var earnedAt: Date
    var metadata: String?         // optional JSON blob: {"quizID": "...", "countryCode": "US"}
}
```

Stored as an **append-only log**. Never mutated after creation. `totalXP = XPRecord.where(userID).sum(\.amount)`.

### `QuizHistoryRecord`

```swift
@Model final class QuizHistoryRecord {
    var id: String                // UUID().uuidString
    var userID: String
    var quizType: String          // QuizType.rawValue
    var difficulty: String        // QuizDifficulty.rawValue
    var region: String            // QuizRegion.rawValue
    var correctCount: Int
    var totalCount: Int
    var totalTimeSeconds: Double
    var xpEarned: Int
    var completedAt: Date
}
```

Computed from this: `accuracy = Double(correctCount) / Double(totalCount)`.

### `UnlockedAchievement`

```swift
@Model final class UnlockedAchievement {
    var id: String                // matches AchievementDefinition.id (e.g. "first_quiz")
    var userID: String
    var unlockedAt: Date
    var gameCenterReported: Bool  // false until GK submission succeeds — drives retry queue
}
```

### `StreakRecord`

```swift
@Model final class StreakRecord {
    var id: String                // UUID().uuidString
    var userID: String
    var date: Date                // Calendar.current.startOfDay(for: Date()) — one record per calendar day
}
```

Current streak = count of consecutive `StreakRecord.date` values ending today (sorted descending, checking each is exactly 1 day before the previous).

### `DatabaseManager`

Single entry point for `ModelContainer`. Created once in `GeografyApp`, injected via SwiftUI environment.

```swift
@Observable final class DatabaseManager {
    let container: ModelContainer
    var mainContext: ModelContext { container.mainContext }

    init(inMemory: Bool = false) {
        let schema = Schema([
            UserProfile.self,
            XPRecord.self,
            QuizHistoryRecord.self,
            UnlockedAchievement.self,
            StreakRecord.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        container = try! ModelContainer(for: schema, configurations: [config])
    }
}
```

`inMemory: true` for SwiftUI Previews and unit tests.

---

## 3. Services Architecture

Eight new services. All use `@Observable` unless noted.

### `AuthService` (`@Observable`)

Central auth state machine.

**States (enum `AuthState`):**
- `.loading` — checking Keychain on cold launch
- `.guest(UserProfile)` — no account, stable guest UUID
- `.authenticated(UserProfile)` — signed in via Apple or Google

**Methods:**
- `signInWithApple() async throws`
- `signInWithGoogle() async throws`
- `continueAsGuest()`
- `signOut()`
- `deleteAccount() async throws`
- `migrateGuestData(from guestID: String, to newID: String) async`

**Initialization flow:** On init, reads Keychain. If Apple token found → validates with `ASAuthorizationAppleIDProvider`, loads `UserProfile` from SwiftData → `.authenticated`. If no token → reads guest UUID from Keychain → loads or creates guest `UserProfile` → `.guest`.

### `KeychainService` (plain struct, no `@Observable`)

```swift
struct KeychainService {
    static func save(key: String, data: Data)
    static func load(key: String) -> Data?
    static func delete(key: String)
}
```

**Keychain keys used:**
- `auth.apple.userIdentifier` — Apple's opaque user ID string
- `auth.credential.token` — auth token
- `auth.guest.uuid` — stable guest identifier

### `AppleSignInHandler`

Implements `ASAuthorizationControllerDelegate` + `ASAuthorizationControllerPresentationContextProviding`. Returns:

```swift
struct AppleSignInResult {
    let userIdentifier: String
    let fullName: PersonNameComponents?
    let email: String?
}
```

Note: Apple only provides `fullName` and `email` on the **first** sign-in. Cache these immediately.

### `GoogleSignInHandler`

Uses **native `ASWebAuthenticationSession`** — zero external dependencies. Performs Google OAuth2 PKCE flow.

**Setup required (one-time):**
1. Create project in Google Cloud Console
2. Create OAuth 2.0 credentials (iOS app type)
3. Add client ID to `Info.plist` as `GIDClientID`
4. Add custom URL scheme `com.googleusercontent.apps.<client-id>` to `Info.plist`

Returns:

```swift
struct GoogleSignInResult {
    let sub: String           // Google's stable user identifier
    let name: String?
    let email: String?
}
```

### `XPService` (`@Observable`)

**Exposed properties:**
- `totalXP: Int` — sum of all XPRecords for current user (recomputed on each award)
- `currentLevel: UserLevel` — derived from totalXP against static thresholds
- `xpInCurrentLevel: Int` — XP earned within the current level band
- `xpRequiredForNextLevel: Int` — total XP needed to reach next level
- `progressFraction: Double` — 0.0–1.0, drives `XPProgressBar`

**Methods:**
- `award(_ amount: Int, source: XPSource, metadata: [String: String]? = nil) async` — writes `XPRecord`, recomputes level, fires `levelUpPublisher` if level changed

**Publisher:**
- `levelUpPublisher: PassthroughSubject<UserLevel, Never>` — `ContentView` subscribes to present `LevelUpSheet`

### `AchievementService` (`@Observable`)

Holds a reference to the static `AchievementCatalog`. Checks conditions after relevant user actions. On unlock:
1. Writes `UnlockedAchievement` to SwiftData
2. Calls `xpService.award(definition.xpReward, source: .achievementUnlocked)`
3. Fires `unlockPublisher` for toast overlay
4. Sets `gameCenterReported = false` — GK retry queue picks this up

**Check methods (called externally after each action):**
- `checkExplorerAchievements(totalExplored: Int)`
- `checkQuizAchievements(history: [QuizHistoryRecord])`
- `checkTravelAchievements(visitedCount: Int, wantCount: Int)`
- `checkStreakAchievements(streak: Int)`
- `checkKnowledgeAchievements(flagQuizCount: Int, capitalQuizCount: Int, orgsOpened: Int)`

**Publisher:**
- `unlockPublisher: PassthroughSubject<AchievementDefinition, Never>` — `ContentView` subscribes to present `AchievementUnlockedBanner`

### `StreakService` (`@Observable`)

Called on every app foreground event (via `scenePhase` in `GeografyApp`).

**Logic:**
1. Check if a `StreakRecord` exists for today's start-of-day date
2. If not: insert new record, call `xpService.award(10, source: .dailyLogin)`
3. Recompute `currentStreak` from consecutive StreakRecords (sorted descending)
4. If `currentStreak > userProfile.longestStreak`: update `longestStreak`
5. Check streak milestone achievements: 3d, 7d, 30d, 100d

**Exposed properties:**
- `currentStreak: Int`

### `GameCenterService` (`@Observable`)

**On app launch:**
- Sets `GKLocalPlayer.local.authenticateHandler`
- Never forces sign-in; if user skips Game Center, service is disabled silently
- After successful auth: retry all `UnlockedAchievement` where `gameCenterReported == false`

**Methods:**
- `submitScore(_ score: Int, leaderboardID: String) async`
- `reportAchievement(id: String, percentComplete: Double) async`
- `presentLeaderboard(id: String)` — wraps `GKGameCenterViewController` via `UIViewControllerRepresentable`

**Retry queue:**
On launch, fetch all `UnlockedAchievement` where `gameCenterReported == false` and call `reportAchievement` for each. On success, set `gameCenterReported = true`.

### `SubscriptionService` (`@Observable`)

StoreKit 2, fully native.

**Product IDs:**
```swift
static let productIDs = [
    "com.khizanag.geografy.premium.monthly",
    "com.khizanag.geografy.premium.yearly",
    "com.khizanag.geografy.premium.lifetime",
]
```

**Exposed properties:**
- `products: [Product]` — loaded on init, sorted monthly / yearly / lifetime
- `isPremium: Bool` — derived live from `Transaction.currentEntitlements`
- `isLoading: Bool`

**Methods:**
- `purchase(_ product: Product) async throws -> Transaction`
- `restorePurchases() async throws` — calls `AppStore.sync()`

**Transaction listener (runs for app lifetime):**
```swift
Task {
    for await result in Transaction.updates {
        guard case .verified(let transaction) = result else { continue }
        await transaction.finish()
        await refreshPremiumStatus()
    }
}
```
Handles renewals, family sharing grants, and revocations automatically.

---

## 4. XP System

### `XPSource` (enum, `String` raw values)

```swift
enum XPSource: String {
    case dailyLogin
    case quizCompletedEasy
    case quizCompletedMedium
    case quizCompletedHard
    case countryExplored
    case travelVisited
    case travelWantToVisit
    case achievementUnlocked
    case streakMilestone7
    case streakMilestone30
    case streakMilestone100
}
```

### XP Amounts

| Action | Base XP | Bonus | Total range |
|---|---|---|---|
| Daily login | 10 | — | 10 |
| Quiz — Easy | 15 | up to +10 (accuracy) | 15–25 |
| Quiz — Medium | 25 | up to +15 (accuracy) | 25–40 |
| Quiz — Hard | 40 | up to +20 (accuracy) | 40–60 |
| First open of a country detail | 5 | — | 5 |
| Mark country as Visited | 20 | — | 20 |
| Mark country as Want to Visit | 5 | — | 5 |
| Achievement unlocked | 25–200 | — | per definition |
| 7-day streak milestone | 50 | — | 50 |
| 30-day streak milestone | 200 | — | 200 |
| 100-day streak milestone | 500 | — | 500 |

**Accuracy bonus formula:** `floor(accuracy * maxBonus)` where `accuracy = Double(correctCount) / Double(totalCount)`.

### Level Thresholds

```swift
struct UserLevel {
    let level: Int
    let title: String
    let minXP: Int
    let maxXP: Int       // minXP of the next level; Int.max for level 10
}

static let thresholds: [UserLevel] = [
    UserLevel(level: 1,  title: "Explorer",          minXP: 0,      maxXP: 100),
    UserLevel(level: 2,  title: "Traveler",          minXP: 100,    maxXP: 300),
    UserLevel(level: 3,  title: "Adventurer",        minXP: 300,    maxXP: 700),
    UserLevel(level: 4,  title: "Geographer",        minXP: 700,    maxXP: 1_500),
    UserLevel(level: 5,  title: "Cartographer",      minXP: 1_500,  maxXP: 3_000),
    UserLevel(level: 6,  title: "Navigator",         minXP: 3_000,  maxXP: 5_500),
    UserLevel(level: 7,  title: "Ambassador",        minXP: 5_500,  maxXP: 9_000),
    UserLevel(level: 8,  title: "World Citizen",     minXP: 9_000,  maxXP: 14_000),
    UserLevel(level: 9,  title: "Global Expert",     minXP: 14_000, maxXP: 21_000),
    UserLevel(level: 10, title: "Master Geographer", minXP: 21_000, maxXP: Int.max),
]
```

`UserLevel` is a **value type computed on demand** from total XP. Never persisted.

---

## 5. Achievement Catalog (all 21)

All definitions are **static** — a `[AchievementDefinition]` constant in `AchievementCatalog.swift`. Not stored in SwiftData. Only `UnlockedAchievement` (the unlock event) is persisted.

```swift
struct AchievementDefinition {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let xpReward: Int
    let gameCenterID: String     // "geografy.achievement.<id>"
    let iconName: String         // SF Symbol name
    let isSecret: Bool
}

enum AchievementCategory: String {
    case explorer
    case quizMaster
    case travelTracker
    case streak
    case knowledge
}
```

### Explorer Category (countries opened in CountryDetailScreen)

| id | title | description | condition | XP | GC ID |
|---|---|---|---|---|---|
| `first_steps` | First Steps | Open your first country | 1 country opened | 25 | `geografy.achievement.first_steps` |
| `continental_explorer` | Continental Explorer | Explore 10 countries | 10 countries opened | 50 | `geografy.achievement.continental_explorer` |
| `world_traveler` | World Traveler | Explore 50 countries | 50 countries opened | 100 | `geografy.achievement.world_traveler` |
| `globe_trotter` | Globe Trotter | Explore 100 countries | 100 countries opened | 150 | `geografy.achievement.globe_trotter` |
| `master_explorer` | Master Explorer | Explore all 195 countries | 195 countries opened | 200 | `geografy.achievement.master_explorer` |

GC progress reporting: `Double(countriesOpened) / 195.0 * 100` (percentage-based achievement).

### Quiz Master Category

| id | title | description | condition | XP | GC ID | Secret |
|---|---|---|---|---|---|---|
| `first_quiz` | First Quiz | Complete your first quiz | 1 quiz completed | 25 | `geografy.achievement.first_quiz` | no |
| `perfect_score` | Perfect Score | Get 100% on any quiz | accuracy == 1.0 | 75 | `geografy.achievement.perfect_score` | no |
| `quiz_fanatic` | Quiz Fanatic | Complete 10 quizzes | 10 quizzes completed | 50 | `geografy.achievement.quiz_fanatic` | no |
| `quiz_legend` | Quiz Legend | Complete 100 quizzes | 100 quizzes completed | 150 | `geografy.achievement.quiz_legend` | no |
| `speed_demon` | Speed Demon | Finish a Hard quiz in under 60 seconds | Hard + totalTime < 60 | 100 | `geografy.achievement.speed_demon` | yes |
| `all_types` | Polymath | Complete all 6 quiz types at least once | all 6 QuizType values in history | 75 | `geografy.achievement.all_types` | no |

### Travel Tracker Category

| id | title | description | condition | XP | GC ID |
|---|---|---|---|---|---|
| `first_stamp` | First Stamp | Mark your first visited country | 1 country visited | 25 | `geografy.achievement.first_stamp` |
| `frequent_flyer` | Frequent Flyer | Visit 10 countries | 10 countries visited | 75 | `geografy.achievement.frequent_flyer` |
| `world_adventurer` | World Adventurer | Visit 50 countries | 50 countries visited | 150 | `geografy.achievement.world_adventurer` |
| `bucket_list` | Bucket List | Add 5 want-to-visit countries | 5 countries want-to-visit | 50 | `geografy.achievement.bucket_list` |

### Streak Category

| id | title | description | condition | XP | GC ID | Secret |
|---|---|---|---|---|---|---|
| `getting_started` | Getting Started | Log in 3 days in a row | 3-day streak | 25 | `geografy.achievement.getting_started` | no |
| `week_warrior` | Week Warrior | Log in 7 days in a row | 7-day streak | 50 | `geografy.achievement.week_warrior` | no |
| `monthly_champion` | Monthly Champion | Log in 30 days in a row | 30-day streak | 150 | `geografy.achievement.monthly_champion` | no |
| `dedicated_scholar` | Dedicated Scholar | Log in 100 days in a row | 100-day streak | 200 | `geografy.achievement.dedicated_scholar` | **yes** |

### Knowledge Category

| id | title | description | condition | XP | GC ID |
|---|---|---|---|---|---|
| `flag_collector` | Flag Collector | Complete 5 flag quizzes | 5 flag quiz completions | 50 | `geografy.achievement.flag_collector` |
| `capital_expert` | Capital Expert | Complete 5 capital quizzes | 5 capital quiz completions | 50 | `geografy.achievement.capital_expert` |
| `org_scholar` | Org Scholar | Explore all 16 organizations | all 16 org detail screens opened | 75 | `geografy.achievement.org_scholar` |

**Total: 21 achievements across 5 categories.**

---

## 6. Game Center Integration

### Leaderboards (3)

| Leaderboard ID | Display name | Metric | Score type | Submitted after |
|---|---|---|---|---|
| `geografy.leaderboard.xp_total` | XP Rankings | All-time total XP | Integer, ascending | Every XP award |
| `geografy.leaderboard.quiz_best` | Quiz Champions | Best quiz accuracy × 100 | Integer 0–100, descending | Every quiz completion |
| `geografy.leaderboard.countries_visited` | World Explorers | Countries marked visited | Integer, ascending | Every TravelService status change |

### Achievement → Game Center Mapping

Every `AchievementDefinition` has a `gameCenterID` in the format `geografy.achievement.<id>`.

**Progress-based (Explorer, Travel Tracker categories):** Report as percentage, e.g.:
- Explorer: `Double(countriesOpened) / 195.0 * 100`
- Frequent Flyer: `Double(visitedCount) / 10.0 * 100` (capped at 100)

**Binary (all others):** Report `100.0` on unlock.

Must be registered in App Store Connect → your app → Game Center → Achievements, with matching IDs.

### `GameCenterViewControllerRepresentable`

```swift
struct GameCenterViewControllerRepresentable: UIViewControllerRepresentable {
    let leaderboardID: String
    // wraps GKGameCenterViewController(leaderboardID:playerScope:timeScope:)
}
```

Presented as a SwiftUI `.sheet` from `LeaderboardScreen`.

### Retry Queue Logic

On every app launch (after GK auth succeeds):
1. Fetch all `UnlockedAchievement` where `gameCenterReported == false`
2. For each: call `GKAchievement.report([achievement])`
3. On success: set `gameCenterReported = true` and save

This transparently handles achievements earned while offline.

---

## 7. Authentication Flow

### Cold Launch State Machine

```
App Launch
    │
    ├── DatabaseManager.setup() — ModelContainer ready
    │
    └── AuthService.restore()
            │
            ├── Keychain: Apple user identifier found
            │       └── ASAuthorizationAppleIDProvider.getCredentialState()
            │               ├── .authorized → load UserProfile from SwiftData → .authenticated(profile)
            │               ├── .revoked → clear Keychain → fall through to guest
            │               └── .notFound → clear Keychain → fall through to guest
            │
            └── No Apple identifier in Keychain
                    │
                    ├── Guest UUID in Keychain
                    │       └── Load existing guest UserProfile from SwiftData → .guest(profile)
                    │
                    └── No guest UUID
                            └── Generate UUID, store in Keychain
                                Create new UserProfile(isGuest: true)
                                Save to SwiftData → .guest(new profile)
```

### Guest Experience

- App is fully usable as a guest immediately — zero friction, no sign-in screen shown on launch
- All free features available
- Data accumulates under the stable guest UUID (Keychain-persisted across restarts and app updates)
- Guest users appear as authenticated in the UI for XP/level/achievements — they just lack cloud backup and cross-device sync

### Soft Nudge Points (dismissable prompts to create account)

| Trigger | UI | Frequency |
|---|---|---|
| First quiz completed | Bottom sheet: "Save your progress — create a free account" | Once ever |
| User reaches Level 3 | Full-screen banner: "Your progress only lives on this device" | Once ever |
| Tapping a premium feature | Hard gate → `SignInOptionsSheet` → `PaywallScreen` | Every time |

### Account Creation + Guest Data Migration

When a guest successfully signs in with Apple (or Google):

**Step 1 — Check for existing account:**
- Query SwiftData for `UserProfile` where `id == appleUserIdentifier`
- If found → **returning user**: restore profile, update `lastLoginAt`, dismiss sheet. Done.

**Step 2 — New user: create profile + migrate data:**
```
let guestID = KeychainService.load("auth.guest.uuid")
let newID = appleResult.userIdentifier

// Create new profile
let profile = UserProfile(id: newID, displayName: appleResult.fullName, ...)

// Migrate all SwiftData records
XPRecord.where(userID == guestID)           → set userID = newID
QuizHistoryRecord.where(userID == guestID)  → set userID = newID
UnlockedAchievement.where(userID == guestID)→ set userID = newID
StreakRecord.where(userID == guestID)       → set userID = newID

// Store new credentials
KeychainService.save("auth.apple.userIdentifier", newID)

// Update AuthService state
authService.state = .authenticated(profile)
```

**UserDefaults data (favorites, travel) stays as-is.** It's already device-local. No migration needed. If the user later installs on a second device, UserDefaults data starts fresh there until CloudKit sync is implemented.

### Sign Out

1. Clear `auth.apple.userIdentifier` and `auth.credential.token` from Keychain
2. Generate new guest UUID, store as `auth.guest.uuid` in Keychain
3. Create new guest `UserProfile` in SwiftData
4. Set `AuthService.state = .guest(newProfile)`

Existing SwiftData records for the old user ID remain on device. If the user signs back in, Step 1 of migration finds the existing profile and restores it.

### Delete Account

1. Revoke Apple credential: `ASAuthorizationAppleIDProvider().createCredentialRevokeRequest(token:)` — required by App Store guidelines
2. Batch-delete from SwiftData: all `XPRecord`, `QuizHistoryRecord`, `UnlockedAchievement`, `StreakRecord`, and `UserProfile` where `userID == currentUserID`
3. Clear all Keychain entries
4. Generate new guest UUID → create fresh guest `UserProfile` → `.guest(newProfile)`

---

## 8. Profile Page

### `ProfileScreen` — full layout (single scrollable `ScrollView`)

**1. Header Section (`ProfileHeaderSection`)**
- Circular avatar (initials-based until image upload is supported; initials = first letter of each word in `displayName`)
- Avatar background color: deterministic from `displayName` hash → one of 8 accent colors
- Display name (large, bold)
- Level badge: colored pill showing "Level N · Title"
- "Edit" button (top-right) → `EditProfileSheet`
- If guest: "Sign In to save your progress" subtle subtitle below name

**2. Stats Grid (`ProfileStatsSection`) — 2×3 `GeoCard` tiles**

| Tile | Data source |
|---|---|
| Countries Explored | Unique country codes from `XPRecord` where `source == .countryExplored` |
| Countries Visited | `TravelService.visitedCount` |
| Quizzes Completed | `QuizHistoryRecord.count` for userID |
| Avg Quiz Score | `mean(QuizHistoryRecord.accuracy)` for userID, formatted as "73%" |
| Current Streak | `StreakService.currentStreak`, formatted as "12 days" |
| Longest Streak | `UserProfile.longestStreak`, formatted as "30 days" |

**3. XP Progress Section (`ProfileXPSection`)**
- Large level badge (circle with level number, accent-colored ring)
- Level title (e.g., "Geographer")
- `XPProgressBar` (full-width, showing progress within current level band)
- "3,420 / 5,500 XP" label (current total XP / maxXP of current level)
- "1,080 XP to Level 6 · Navigator" subtitle

**4. Recent Achievements (`ProfileAchievementsPreview`)**
- Section header: "Achievements" + "See All (N) →"
- Horizontal `ScrollView` showing 3 most recently unlocked `AchievementCard` tiles
- If no achievements yet: empty state "Complete quizzes and explore countries to earn achievements"
- "See All" navigates to `AchievementsScreen`

**5. Account Section (`ProfileAccountSection`)**

*If guest:*
- "Create Account" primary button → `SignInOptionsSheet`
- Explanation: "Save your progress and sync across devices"

*If authenticated:*
- Display name row (icon + value)
- Email row (icon + value, only if email was granted by Apple)
- Sign In method row (icon + "Apple ID" or "Google")

*Always (bottom, destructive):*
- "Sign Out" button (secondary style)
- "Delete Account" button (destructive red, text style)
  - Tap → `DeleteAccountConfirmationSheet` (two-step: type "DELETE" or tap confirm twice)

### Supporting Views

**`EditProfileSheet`** — `TextField` for display name with character limit (30). Save button calls `AuthService.updateDisplayName(_:)`.

**`DeleteAccountConfirmationSheet`** — Shows consequences ("All your XP, achievements, and quiz history will be permanently deleted"), requires explicit confirmation tap.

---

## 9. Free vs Premium Breakdown

### Free (always, no account required, no sign-in)

- Full interactive world map with all countries and GeoJSON boundaries
- Country details: flag, capital, continent, area (km²), population, population density
- Quiz types available: **Flag Quiz**, **Capital Quiz**, **Country from Flag** (3 of 6)
- Travel tracker — mark visited / want-to-visit, unlimited countries
- Favorites — unlimited
- Full XP and leveling system (all 10 levels)
- Full achievement system (all 21 achievements earnable)
- Game Center leaderboards — participate and view
- Profile page
- Organizations screen — all 16 organizations
- Settings

### Premium (Monthly / Yearly / Lifetime)

- **All 6 quiz types** — unlocks: Reverse Flag, Reverse Capital, Population Order, Area Order
- **Advanced country stats:**
  - GDP (current, per capita, PPP)
  - Form of government
  - Currency (name + code)
  - International organizations membership
  - Language breakdown (pie chart)
  - Population trend chart
  - GDP trend chart
- **Quiz history log** — browse all past results, filter by type/region/difficulty
- **Stats / analytics screen** — score trends, by quiz type, by region, accuracy over time
- **All map themes** — premium color palettes (when `ThemesScreen` ships)
- **Continent-specific map tabs** as separate experiences
- **No ads** (forward-compatibility — if ads are added to the free tier)
- Custom avatar / profile image (future)

### Feature Gating Implementation

- `SubscriptionService.isPremium: Bool` injected into SwiftUI environment via `GeografyApp`
- **Locked quiz types** in `QuizSetupScreen`: displayed with lock icon overlay; tap → `PaywallScreen` presented as full-screen sheet
- **Locked country stats** in `CountryDetailScreen`: `GeoInfoTile` shown with blur overlay and lock icon; tap → `PaywallScreen`
- **Paywall presented** as `.fullScreenCover` (not `.sheet`) for higher conversion

---

## 10. StoreKit 2 Subscriptions

### Product IDs

```
com.khizanag.geografy.premium.monthly    — $1.99/month
com.khizanag.geografy.premium.yearly     — $19.99/year  (saves ~16% vs monthly)
com.khizanag.geografy.premium.lifetime   — $49.99 one-time purchase
```

Configure in **App Store Connect → Subscriptions** for monthly and yearly (same subscription group), and **In-App Purchases → Non-Consumable** for lifetime.

### `PaywallScreen` Layout

```
┌──────────────────────────────────────┐
│ ✕                                    │  ← dismiss button (top-left)
│                                      │
│      [Globe illustration]            │
│   Unlock the Full World              │
│   Geography experience               │
│                                      │
│ ✓  All 6 quiz types                  │
│ ✓  Advanced country stats            │
│ ✓  Quiz history & analytics          │
│ ✓  Premium map themes                │
│ ✓  Continent maps                    │
│                                      │
│  ┌─────────┐ ┌─────────┐ ┌────────┐ │
│  │ Monthly │ │ Yearly  │ │Lifetime│ │  ← SubscriptionCard ×3
│  │  $1.99  │ │ $19.99  │ │ $49.99 │ │
│  │  /month │ │  /year  │ │  once  │ │
│  │         │ │ ★ Best  │ │        │ │
│  └─────────┘ └─────────┘ └────────┘ │
│                                      │
│      [Continue] ← primary CTA        │
│                                      │
│  Restore Purchases · Privacy · Terms │
└──────────────────────────────────────┘
```

"Yearly" card is highlighted (accent border + "Best Value" badge).

### `SubscriptionService` Implementation Notes

- Load products once on init; if loading fails, retry on next purchase attempt
- `isPremium` always derived live from `Transaction.currentEntitlements` — never cached as a separate stored property
- Always verify transactions: discard `.unverified` silently
- Background `Task` listening to `Transaction.updates` runs for entire app lifetime
- `restorePurchases()` calls `AppStore.sync()` which triggers the update listener for any pending transactions
- For lifetime purchase: check `Transaction.currentEntitlements` for the non-consumable product ID

---

## 11. Complete File Structure

Files marked `← NEW` are new. Files marked `← UPDATED` require changes.

```
Geografy/
  App/
    GeografyApp.swift              ← UPDATED: inject all new services
    ContentView.swift              ← UPDATED: auth overlay, profile tab, level-up overlay
    NavigationRoute.swift          ← UPDATED: add .profile, .paywall, .leaderboard

  Data/
    Model/
      Country.swift                (existing — unchanged)
      Organization.swift           (existing — unchanged)
      TravelStatus.swift           (existing — unchanged)
      GeoJSONModels.swift          (existing — unchanged)
      UserProfile.swift            ← NEW  (@Model)
      XPRecord.swift               ← NEW  (@Model)
      QuizHistoryRecord.swift      ← NEW  (@Model)
      UnlockedAchievement.swift    ← NEW  (@Model)
      StreakRecord.swift           ← NEW  (@Model)
    Service/
      CountryDataService.swift     (existing — unchanged)
      FavoritesService.swift       (existing — unchanged)
      TravelService.swift          ← UPDATED: add XP award + achievement check hooks
      CountryBasicInfo.swift       (existing — unchanged)
      GeoJSONParser.swift          (existing — unchanged)
    Storage/
      DatabaseManager.swift        ← NEW

  Feature/
    Auth/
      Model/
        AuthState.swift            ← NEW
        AuthError.swift            ← NEW
        AppleSignInResult.swift    ← NEW
        GoogleSignInResult.swift   ← NEW
      Service/
        AuthService.swift          ← NEW
        KeychainService.swift      ← NEW
        AppleSignInHandler.swift   ← NEW
        GoogleSignInHandler.swift  ← NEW
      View/
        SignInOptionsSheet.swift   ← NEW
        GuestModePromptBanner.swift ← NEW

    Profile/
      View/
        ProfileScreen.swift              ← NEW
        ProfileHeaderSection.swift       ← NEW
        ProfileStatsSection.swift        ← NEW
        ProfileXPSection.swift           ← NEW
        ProfileAchievementsPreview.swift ← NEW
        ProfileAccountSection.swift      ← NEW
        EditProfileSheet.swift           ← NEW
        DeleteAccountConfirmationSheet.swift ← NEW

    Gamification/
      Model/
        XPSource.swift             ← NEW  (enum, String raw values)
        UserLevel.swift            ← NEW  (struct + static thresholds array)
        AchievementDefinition.swift ← NEW (struct)
        AchievementCategory.swift  ← NEW  (enum)
        AchievementCatalog.swift   ← NEW  (static [AchievementDefinition], all 21)
      Service/
        XPService.swift            ← NEW
        AchievementService.swift   ← NEW
        StreakService.swift        ← NEW
      View/
        LevelBadgeView.swift       ← NEW  (reusable Design/Component-level)
        XPProgressBar.swift        ← NEW  (reusable Design/Component-level)
        LevelUpSheet.swift         ← NEW  (full-screen celebration overlay)
        AchievementUnlockedBanner.swift ← NEW (toast overlay)

    Achievements/
      View/
        AchievementsScreen.swift   ← REPLACE (currently ComingSoonView)
        AchievementCard.swift      ← NEW
        AchievementDetailSheet.swift ← NEW

    Leaderboard/
      Service/
        GameCenterService.swift    ← NEW
      View/
        LeaderboardScreen.swift    ← NEW
        GameCenterViewControllerRepresentable.swift ← NEW

    Subscription/
      Model/
        SubscriptionTier.swift     ← NEW  (enum: free/monthly/yearly/lifetime)
      Service/
        SubscriptionService.swift  ← NEW
      View/
        PaywallScreen.swift        ← NEW
        SubscriptionCard.swift     ← NEW
        FeatureComparisonSection.swift ← NEW

  Design/
    Theme/ (existing — all unchanged)
    Component/
      (all existing components unchanged)
      LevelBadgeView.swift         (reference from Gamification/View — or copy here if used in 3+ places)
      XPProgressBar.swift          (reference from Gamification/View — or copy here if used in 3+ places)
```

**New files: ~40. Modified files: 8.**

---

## 12. Touch Points on Existing Files

| File | Required change |
|---|---|
| `GeografyApp.swift` | Instantiate `DatabaseManager`, `AuthService`, `XPService`, `AchievementService`, `StreakService`, `GameCenterService`, `SubscriptionService`. Inject all into SwiftUI environment. Call `streakService.checkToday()` in `.onChange(of: scenePhase)` when phase becomes `.active`. |
| `ContentView.swift` | Add Profile tab (between Favorites and Achievements, or after Settings). Subscribe to `xpService.levelUpPublisher` → present `LevelUpSheet` as `.fullScreenCover`. Subscribe to `achievementService.unlockPublisher` → present `AchievementUnlockedBanner` as overlay with auto-dismiss. Show `SignInOptionsSheet` on first launch if `authService.state == .guest` and it's a brand new install (check a `hasLaunchedBefore` UserDefaults flag). |
| `QuizResultsScreen.swift` | On `.onAppear`: (1) compute XP from quiz result, (2) call `xpService.award(xp, source: quizSource, metadata: ...)`, (3) save `QuizHistoryRecord` to SwiftData, (4) call `achievementService.checkQuizAchievements(history:)`, (5) submit score to `gameCenter.submitScore(...)`. |
| `TravelService.swift` | After `setStatus(_:for:)`: (1) call `xpService.award(amount, source: .travelVisited or .travelWantToVisit)`, (2) call `achievementService.checkTravelAchievements(visitedCount:wantCount:)`, (3) call `gameCenterService.submitScore(visitedCount, leaderboardID: "geografy.leaderboard.countries_visited")`. |
| `CountryDetailScreen.swift` | On `.onAppear(of: country.code)`: check if country code is in "exploredCountryCodes" set (UserDefaults, keyed by userID). If not: add it, call `xpService.award(5, source: .countryExplored, metadata: {"countryCode": country.code})`, call `achievementService.checkExplorerAchievements(totalExplored: newCount)`. Gate advanced stat tiles (GDP, government, currency, organizations, language chart, trend charts) behind `subscriptionService.isPremium`. |
| `QuizSetupScreen.swift` | For quiz type buttons: if type is `.reverseFlag`, `.reverseCapital`, `.populationOrder`, or `.areaOrder`, and `!subscriptionService.isPremium`: show lock icon overlay on button; tap → present `PaywallScreen` as `.fullScreenCover` instead of proceeding to quiz setup. |
| `HomeProgressCard.swift` | Replace all hardcoded values with live data: level from `xpService.currentLevel`, progressFraction from `xpService.progressFraction`, streak from `streakService.currentStreak`. |
| `AchievementsScreen.swift` | Full replacement of `ComingSoonView`. Fetch `UnlockedAchievement` from SwiftData for current userID. Map against `AchievementCatalog.all`. Display in sections by `AchievementCategory`. Show locked achievements as grayed-out `AchievementCard` with `isSecret` achievements hidden until unlocked. |
| `SettingsScreen.swift` | Add "Subscription" section with current tier display and "Manage Subscription" button (opens `PaywallScreen` or `SK.manageSubscriptionsSheet` if already subscribed). |
| `OrganizationDetailScreen.swift` | Track that this org has been opened (UserDefaults set of opened org IDs, keyed by userID). When all 16 opened: call `achievementService` to check `org_scholar`. |

---

## 13. Updated App Environment

`GeografyApp.swift` body after changes:

```swift
@main struct GeografyApp: App {
    @State private var database = DatabaseManager()
    @State private var authService = AuthService()
    @State private var xpService = XPService()
    @State private var achievementService = AchievementService()
    @State private var streakService = StreakService()
    @State private var gameCenterService = GameCenterService()
    @State private var subscriptionService = SubscriptionService()
    @State private var favoritesService = FavoritesService()     // existing
    @State private var travelService = TravelService()           // existing
    @State private var countryDataService = CountryDataService() // existing
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(database)
                .environment(authService)
                .environment(xpService)
                .environment(achievementService)
                .environment(streakService)
                .environment(gameCenterService)
                .environment(subscriptionService)
                .environment(favoritesService)
                .environment(travelService)
                .environment(countryDataService)
                .modelContainer(database.container)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await streakService.checkToday() }
                Task { await gameCenterService.retryPendingReports() }
            }
        }
    }
}
```

---

## 14. Implementation Phases

### Phase A — Data Foundation *(prerequisite for everything)*

1. Create all 5 SwiftData `@Model` types with all fields
2. `DatabaseManager` — ModelContainer, CloudKit-safe config, preview support
3. `XPSource` enum (String raw values)
4. `UserLevel` struct + static `thresholds` array (10 levels)
5. `XPService` — award method, level computation, `levelUpPublisher`
6. `StreakService` — daily check, login XP, streak computation
7. `AchievementDefinition`, `AchievementCategory`, `AchievementCatalog` (all 21 static definitions)
8. `AchievementService` — unlock logic, XP bonus delegation, `unlockPublisher`

**Validation:** Wire `XPService` into a test button in Settings to verify level-up events fire correctly.

### Phase B — Authentication

9. `KeychainService` — save/load/delete
10. `AppleSignInHandler` — `ASAuthorizationControllerDelegate` wrapper
11. `AuthState` enum, `AuthError` enum
12. `AuthService` — state machine, restore on launch, guest UUID management
13. `SignInOptionsSheet` — Apple Sign In button, Google Sign In button (placeholder), Continue as Guest link
14. `GuestModePromptBanner` — dismissable bottom sheet for nudge points
15. Guest data migration logic in `AuthService.migrateGuestData(from:to:)`
16. Wire `SignInOptionsSheet` into `ContentView` for first-launch condition

**Validation:** Cold launch as guest → verify guest UUID is stable across restarts. Sign in with Apple → verify migration → verify profile appears.

### Phase C — Wire Gamification into Existing Features

17. `QuizResultsScreen` — award XP, save `QuizHistoryRecord`, check quiz achievements, submit leaderboard score
18. `TravelService` — award XP on status change, check travel achievements, submit leaderboard
19. `CountryDetailScreen` — award first-explore XP per country code, check Explorer achievements; add premium gates for advanced stats
20. `OrganizationDetailScreen` — track opened orgs, check `org_scholar` achievement
21. `StreakService` — wire into `GeografyApp` `.onChange(scenePhase: .active)`
22. `HomeProgressCard` — real XP/level/streak data (remove hardcoded values)

**Validation:** Complete a quiz → verify XP awards, history record saved, achievements trigger.

### Phase D — Gamification UI

23. `LevelBadgeView` — level number + colored ring, configurable size
24. `XPProgressBar` — animated fill, configurable height and color
25. `LevelUpSheet` — full-screen celebration with level title, confetti animation, close button
26. `AchievementUnlockedBanner` — toast overlay, auto-dismiss after 3 seconds, shows icon + title
27. Wire `levelUpPublisher` → `LevelUpSheet` in `ContentView`
28. Wire `unlockPublisher` → `AchievementUnlockedBanner` in `ContentView`
29. `AchievementsScreen` — real achievement grid, sectioned by category, lock states, secret handling
30. `AchievementCard` — icon, title, locked/unlocked state, lock icon for secrets
31. `AchievementDetailSheet` — full achievement details, date unlocked, XP reward, Game Center status

### Phase E — Profile Page

32. `ProfileHeaderSection` — avatar, name, level badge, edit button
33. `ProfileStatsSection` — 2×3 stat grid
34. `ProfileXPSection` — large level badge, progress bar, XP label
35. `ProfileAchievementsPreview` — horizontal scroll of 3 recent achievements
36. `ProfileAccountSection` — sign-in buttons (guest) or account info (authenticated) + sign out + delete
37. `ProfileScreen` — compose all sections
38. `EditProfileSheet` — display name edit
39. `DeleteAccountConfirmationSheet` — two-step confirmation
40. Add Profile tab to `ContentView` tab bar

### Phase F — Game Center

41. `GameCenterService` — silent auth, score submission, achievement reporting, retry queue
42. `GameCenterViewControllerRepresentable` — UIKit wrapper for `GKGameCenterViewController`
43. `LeaderboardScreen` — display 3 leaderboards, present GK view controller
44. Wire leaderboard submissions into quiz completion and travel service hooks (Phase C work already called stubs — implement the actual GK calls now)
45. Wire achievement progress reporting into AchievementService unlock (call `gameCenterService.reportAchievement` from `AchievementService.unlock`)

**Prerequisite:** Game Center must be enabled in App Store Connect and all leaderboard/achievement IDs registered before testing.

### Phase G — Subscriptions (StoreKit 2)

46. Configure products in App Store Connect (2 auto-renewable subscriptions + 1 non-consumable)
47. `SubscriptionTier` enum
48. `SubscriptionService` — product loading, `isPremium`, purchase, restore, transaction listener
49. `SubscriptionCard` — price display, highlighted state, terms
50. `FeatureComparisonSection` — free vs premium bullet list
51. `PaywallScreen` — full layout as designed above
52. Feature gates in `QuizSetupScreen` — lock non-free quiz types
53. Feature gates in `CountryDetailScreen` — blur/lock advanced stat tiles
54. Subscription row in `SettingsScreen`
55. `RestorePurchasesButton` in `PaywallScreen` and `SettingsScreen`

**Prerequisite:** StoreKit 2 requires Xcode StoreKit Configuration file for local testing (no sandbox account needed in development).

### Phase H — Google Sign In

56. Create Google Cloud project, enable Google Sign In API, create iOS OAuth client ID
57. Add client ID to `Info.plist` as `GIDClientID`
58. Add custom URL scheme `com.googleusercontent.apps.<client-id>` to `Info.plist`
59. `GoogleSignInResult` struct
60. `GoogleSignInHandler` — `ASWebAuthenticationSession` PKCE flow, token exchange, user info fetch
61. Wire Google sign-in into `SignInOptionsSheet` (replace placeholder button)
62. Wire `GoogleSignInResult` into `AuthService.signInWithGoogle()`

### Phase I — Polish & Remaining

63. Quiz history screen (filtered, sortable list of `QuizHistoryRecord`)
64. Stats / analytics screen (charts by quiz type, region, accuracy over time)
65. Country explore tracking — persist explored set per user (UserDefaults `Set<String>`, keyed by userID; migrate to SwiftData if complexity warrants)
66. Onboarding flow — 3-step first-launch walkthrough (map, quiz, track)
67. Streak grace day — allow one missed day without breaking streak (store "grace used" flag on `UserProfile`)
68. Push notifications for streak reminders (optional, requires `UserNotifications` permission)

---

## Key Architectural Decisions

**Guest-first, no forced onboarding.** Geography apps with forced sign-in see highest early drop-off. Users get full free value immediately. Nudges appear at moments when users have something to lose (first quiz result, Level 3 milestone). Conversion rate is higher when the user is already invested.

**Append-only XP log (`XPRecord`) instead of a single `totalXP` counter.** Enables per-source analytics ("which actions drive engagement"), undo capability, and audit trails. Avoids SwiftData write conflicts if multiple XP awards could theoretically race. Summing the log is O(n) but fast in practice — a highly active user for 5 years accumulates ~1,800 records (one per day) plus quiz records, well within SwiftData's performance envelope.

**`ASWebAuthenticationSession` for Google, no Google SDK.** Satisfies zero external dependencies. Google's OAuth2 PKCE flow works natively. Requires ~50 lines of implementation code, zero SPM packages, zero pod dependencies, full App Store compliance.

**UserDefaults for favorites and travel tracker stays unchanged.** Device-local preferences. No user-visible benefit to migrating now. When CloudKit sync is implemented in a future phase, `TravelService` and `FavoritesService` can be ported to SwiftData at that time with a one-time migration.

**`gameCenterReported` flag on `UnlockedAchievement`.** Game Center submissions fail silently offline. This persistent flag creates a free retry queue that works across app restarts without any network-level infrastructure or job queue system.

**SwiftData schema CloudKit-ready from day one.** String-typed enums, no non-optional optional relationships, String IDs instead of UUID. Future CloudKit adoption = one `ModelConfiguration` parameter change. Zero schema migration required.

**`isPremium` always derived live from `Transaction.currentEntitlements`.** Never cached as a separate stored property. StoreKit 2's `currentEntitlements` is fast and handles family sharing, subscription lapses, and refunds automatically without any manual state synchronization.
