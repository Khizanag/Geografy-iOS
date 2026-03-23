# Profile Gamification Plan

Full plan for the profile page — XP system, levels, badges, streaks, statistics, and social features.

---

## Current Gamification State

From the existing models:
- `UserLevel.swift` — 10 levels (Explorer → Master Geographer) with XP thresholds
- `XPRecord.swift`, `XPSource.swift` — XP tracking
- `UnlockedAchievement.swift` — local achievement records
- `StreakRecord.swift` — streak tracking
- `Achievement/` — AchievementCatalog, AchievementDefinition, AchievementCard, LevelUpSheet
- `Badge/` — BadgeDefinition, BadgeRarity, BadgeService, BadgeCard, BadgeShowcase

---

## XP System (Current Levels)

| Level | Title | XP Range | Color Theme |
|-------|-------|----------|-------------|
| 1 | Explorer | 0–99 | Gray |
| 2 | Traveler | 100–299 | Green |
| 3 | Adventurer | 300–699 | Teal |
| 4 | Geographer | 700–1,499 | Blue |
| 5 | Cartographer | 1,500–2,999 | Indigo |
| 6 | Navigator | 3,000–5,499 | Purple |
| 7 | Ambassador | 5,500–8,999 | Orange |
| 8 | World Citizen | 9,000–13,999 | Rose |
| 9 | Global Expert | 14,000–20,999 | Gold |
| 10 | Master Geographer | 21,000+ | Rainbow/Platinum |

### XP Sources (Recommendations)

```swift
enum XPSource {
    // Quiz
    case quizCorrectAnswer        // +5 XP per correct answer
    case quizPerfectScore         // +25 XP bonus
    case quizStreak               // +2 XP per answer in a streak (multiplier)
    case quizHardDifficulty       // +50% XP multiplier
    case quizMediumDifficulty     // +25% XP multiplier

    // Daily Challenge
    case dailyChallengeComplete   // +50 XP
    case dailyChallengeBonus      // +25 XP for first-try

    // Exploration
    case countryViewed            // +1 XP per unique country viewed (caps at 197)
    case countryDetailFull        // +5 XP for reading all sections of a country

    // Travel
    case travelVisitedCountry     // +10 XP per visited country marked
    case travelWantToVisit        // +2 XP

    // Streaks
    case streakDay                // +10 XP per day in streak
    case streakWeek               // +50 XP for 7-day milestone
    case streakMonth              // +200 XP for 30-day milestone

    // Achievements
    case achievementUnlocked      // varies by achievement rarity
}
```

---

## Profile Screen Layout

### Header Section
```
╔══════════════════════════════════════╗
║  [Profile Avatar — ProfileAvatarView]║
║  [Name]                [Edit button] ║
║  [Level badge: "Level 4 · Geographer"]║
║  [XP bar: ████████░░ 1200/1500 XP]  ║
║  [Game Center handle if connected]   ║
╚══════════════════════════════════════╝
```

### Stats Row (horizontal, 4 key stats)
```
╔═════════╦═════════╦═════════╦═════════╗
║ 🔥 12   ║ ⭐ 1.2K ║ 🌍 47  ║ 🏆 23  ║
║ Streak  ║ XP      ║ Countries║ Badges ║
╚═════════╩═════════╩═════════╩═════════╝
```

Each stat is tappable → navigates to detail:
- Streak tap → StreakRecord history view
- XP tap → XP history log
- Countries tap → Explored countries list
- Badges tap → BadgeCollectionScreen

### Badge Showcase Row
```
━━━ My Badges ━━━━━━━━━━━━━━━━━━━━━━━━
[BadgeShowcase — horizontal scroll, 5 featured]
                         [See All →]
```

- Uses existing `BadgeShowcase.swift`
- User can pin up to 5 badges (drag to reorder in edit mode)

### Activity / Statistics Section
```
━━━ Statistics ━━━━━━━━━━━━━━━━━━━━━━━
  Quizzes completed:     124
  Correct answers:       1,047
  Accuracy rate:         84%
  Countries explored:    47 / 197
  Countries visited:     8
  Perfect scores:        12
  Longest streak:        23 days
  Total XP earned:       1,247
```

### Recent Achievements Row
Horizontal scroll of recently unlocked achievements (last 5).

### Quiz Performance Section
A mini chart or bar showing performance over time (last 7 sessions accuracy).

### Level Progress Section
```
━━━ Level Progress ━━━━━━━━━━━━━━━━━━━
  You're Level 4 · Geographer
  ████████████░░░░░░░░ 1,200 / 1,500 XP
  Next: Level 5 · Cartographer (300 XP away)

  [Explore → what XP sources give the most]
```

---

## Badge System

### Rarity Tiers (already in BadgeRarity.swift)
- Common (bronze color)
- Uncommon (silver)
- Rare (gold)
- Epic (purple)
- Legendary (rainbow/holographic)

### Badge Categories (from BadgeCategory.swift)
Likely includes: Quiz, Exploration, Streak, Travel, Special

### Recommended Badge Catalog

#### Exploration Badges
| Badge | Rarity | Earn By |
|-------|--------|---------|
| 🗺️ First Steps | Common | View your first country |
| 🌍 Africa Expert | Uncommon | Learn all 54 African countries |
| 🌎 Americas Ace | Uncommon | Learn all 35 American countries |
| 🌏 Asian Scholar | Uncommon | Learn all Asian countries |
| 🏆 World Master | Legendary | Learn all 197 countries |
| 🗼 Capital Expert | Rare | Answer 50 capital questions correctly |

#### Streak Badges
| Badge | Rarity | Earn By |
|-------|--------|---------|
| 🔥 Hot Streak | Common | 3-day streak |
| 🔥🔥 On Fire | Uncommon | 7-day streak |
| ⚡ Unstoppable | Rare | 30-day streak |
| 💎 Legend | Legendary | 100-day streak |

#### Quiz Badges
| Badge | Rarity | Earn By |
|-------|--------|---------|
| 🎯 Sharpshooter | Common | First perfect score |
| 🏅 10x Perfect | Uncommon | 10 perfect scores |
| ⚡ Speed Demon | Rare | Quiz under 60 seconds |
| 🧠 Genius | Epic | 50 perfect scores |

#### Travel Badges
| Badge | Rarity | Earn By |
|-------|--------|---------|
| ✈️ Wanderer | Common | Mark 1 visited country |
| 🌐 Globetrotter | Uncommon | Mark 25 visited countries |
| 🏆 World Traveler | Rare | Mark 75 countries |

#### Special / Event Badges
| Badge | Rarity | Earn By |
|-------|--------|---------|
| 🌟 Early Adopter | Epic | First 1,000 users |
| 🎄 Holiday Explorer | Special | Play during December |

---

## Streak System

### Streak Rules
- A streak increments if the user completes at least 1 quiz OR 1 daily challenge on a given calendar day
- A streak breaks at midnight if no qualifying activity
- **Streak Shield**: Premium feature — one "break" per week that doesn't end the streak

### Streak Display
```swift
struct StreakRecord {
    let currentStreak: Int
    let longestStreak: Int
    let lastActivityDate: Date
    let history: [Date]  // dates of activity
}
```

Weekly calendar heatmap showing active days (like GitHub contribution graph):
```
Mon Tue Wed Thu Fri Sat Sun
 ✅   ✅   ✅   ✅   ✅   ✅   🔥  ← today
```

---

## Statistics to Track

Add to `UserProfile` or a separate `UserStatistics` model:

```swift
struct UserStatistics {
    // Quiz
    var totalQuizzes: Int
    var totalCorrectAnswers: Int
    var totalQuestions: Int
    var accuracyRate: Double  // computed
    var perfectScores: Int
    var fastestQuizSeconds: Int?

    // Exploration
    var uniqueCountriesViewed: Set<String>  // country codes
    var countriesVisited: Int
    var countriesWantToVisit: Int

    // Streaks
    var currentStreak: Int
    var longestStreak: Int

    // Time
    var totalTimePlayedSeconds: Int
    var firstLaunchDate: Date
    var lastActiveDate: Date

    // Social
    var quizzesShared: Int
    var friendsChallenged: Int  // future
}
```

---

## Guest Progress Transfer

When a guest upgrades to an account, all statistics come with them because they're stored in SwiftData linked to the local `UserProfile`. The XP, streak, achievements, travel data — everything persists.

The only concern: if they sign in on a new device (no local data), the profile starts fresh. This is acceptable for v1 (no backend sync). When backend is added, statistics should be synced remotely.

---

## Social Features (Future)

For a future release:
- **Friend list**: Connect via Game Center friends
- **Compare stats**: Side-by-side with a friend
- **Challenge a friend**: Send a specific quiz to a friend, compare scores
- **Global leaderboard**: See where you rank against all users (via Game Center)
- **Country clubs**: Groups of users exploring the same region

These are not immediate priorities but the profile data model should not preclude them.

---

## Profile Edit Sheet

The `Profile/View/` presumably has an edit profile screen. It should allow:
- Display name
- Avatar selection (emoji-based or photo from camera roll)
- "Featured Badges" selection (pick 5 to show on profile)
- Notification preferences shortcut

---

## Animations

Key moments that deserve animation:
- **Level up**: `LevelUpSheet.swift` already exists — full-screen celebration
- **Achievement unlock**: `AchievementUnlockedBanner.swift` and `BadgeUnlockAnimation.swift` exist
- **Streak milestone** (7, 30, 100 days): special banner
- **XP gain**: number counter animates on quiz result
- **Profile view transition**: stats animate in with stagger

---

## Implementation Notes

The existing `LevelBadgeView`, `ScoreRingView`, and `ProfileAvatarView` components must be used throughout — never create alternatives. The profile screen is where these components shine the most.
