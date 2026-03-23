# Home Page Redesign Plan

Detailed redesign plan for the Geografy home screen feed — cards, sections, hierarchy, and interaction model.

---

## Current State

From `Feature/Home/View/`, the home screen already has:
- `HomeScreen.swift` — main scroll view
- `HomeScreen+NewSections.swift` — extended sections
- `HomeSectionEditorSheet.swift` — user can reorder/hide sections
- `HomeStreakCard.swift` — daily streak display
- `HomeProgressCard.swift` — XP progress
- `HomeCountrySpotlightCard.swift` — country of the day
- `HomeDailyChallengeCard.swift` — daily challenge entry
- `HomeQuizCard.swift` — quiz entry point
- `HomeWorldRecordsCard.swift` — world records
- 20+ more feature-specific cards

And from `HomeSection.swift` — section definitions for the feed.

---

## Design Philosophy

The home screen should feel like a **curated learning feed** — not a menu of features. Think Duolingo meets Apple News: each card has a clear purpose, reward signal, and tap action. The user should feel pulled forward, not overwhelmed.

---

## Visual Hierarchy & Layout

### Structure (top to bottom)

```
┌─────────────────────────────────────┐
│ [TOP BAR]                           │
│  Left: "Geografy" wordmark          │
│  Right: [Streak flame] [XP coin]    │
│         [Profile avatar]            │
└─────────────────────────────────────┘
│                                     │
│ [HERO SECTION] — dynamic            │
│  Country of the Day card (full-w)   │
│                                     │
│ [DAILY SECTION]                     │
│  "Today" header                     │
│  Daily Challenge card (full-w)      │
│  Streak card                        │
│                                     │
│ [QUICK PLAY SECTION]                │
│  "Play" header                      │
│  2-column grid: Quiz, Flag Game,    │
│  Capital Quiz, Daily Trivia         │
│                                     │
│ [EXPLORE SECTION]                   │
│  "Explore" header                   │
│  Horizontal scroll: Maps, Country   │
│  List, Organizations, Compare       │
│                                     │
│ [PROGRESS SECTION]                  │
│  XP/Level progress bar card         │
│  Achievements card                  │
│                                     │
│ [DEEP DIVES SECTION]                │
│  Language Explorer, Economy         │
│  Explorer, Independence Timeline,   │
│  Ocean Explorer (horizontal scroll) │
│                                     │
│ [CHALLENGE SECTION]                 │
│  Border Challenge, Explore Game,    │
│  Spelling Bee, Word Search          │
│                                     │
│ [COMING SOON SECTION]               │
│  Teaser cards for unreleased        │
│  features (dimmed, lock icon)       │
│                                     │
└─────────────────────────────────────┘
```

---

## Section-by-Section Breakdown

### 1. Top Navigation Bar

- **Left**: "Geografy" logotype or map-pin icon + wordmark
- **Right icons** (left to right):
  - 🔥 Streak count (tap → streak detail)
  - ⭐ XP/coin count (tap → XP history or coin store)
  - Avatar circle (tap → Profile)
- **Behavior**: Sticky at top; background blurs on scroll (iOS 26 glass effect)
- **Color**: Uses `DesignSystem.Color.background` with `.glassEffect()`

---

### 2. Hero: Country of the Day (Full Width)

**Card design**:
```
╔══════════════════════════════╗
║  [Large flag — FlagView]     ║
║                              ║
║  🗺️ Country of the Day       ║
║  France                      ║
║  Western Europe · 67M people ║
║  "Known as the City of       ║
║   Light..."                  ║
╚══════════════════════════════╝
```

- Full-width `CardView`
- Tap → Country Detail sheet
- Rotates daily (seed from `Date.now.dayOfYear`)
- Subtle ambient background with the flag's dominant colors (can use a gradient approximation)
- Should NOT use `.ultraThinMaterial` — use glass effect for any overlaid elements

---

### 3. Daily Section ("Today")

**3a. Daily Challenge Card** (full width)
```
╔══════════════════════════════╗
║  ✅ / 🎯  Daily Challenge    ║
║  "Mystery Country"           ║
║  Completed: 3/3 clues ─────▶ ║
║  or: "Tap to play" if not    ║
║  done                        ║
╚══════════════════════════════╝
```
- Shows completion status
- Shows reward: "+50 XP" if completed

**3b. Streak Card** (full width or half)
```
╔══════════════════════════════╗
║  🔥 12 Day Streak            ║
║  ████████████░░░░ 14 days   ║
║  Play today to keep it alive ║
╚══════════════════════════════╝
```
- Pulsing flame animation if streak is at risk (hasn't played today)
- Progress bar toward next streak milestone

---

### 4. Quick Play Section ("Play")

**2-column grid of feature cards**:
```
╔═══════════════╦═══════════════╗
║  🏳️ Flag Quiz  ║  🏙️ Capital   ║
║  "Match flags  ║  "Name every  ║
║   to nations"  ║   capital"    ║
╠═══════════════╬═══════════════╣
║  ❓ Trivia     ║  🗺️ Map Quiz  ║
╚═══════════════╩═══════════════╝
```

- Each card: icon, title, 1-line description, difficulty indicator
- Compact cards (~120pt height)
- Tap → respective quiz setup or jump straight to play

---

### 5. Explore Section (Horizontal Scroll)

Title: "Explore"
Horizontally scrollable cards:

```
[← World Map →][← Country List →][← Organizations →][← Compare →][← Continent Stats →]
```

- Fixed height (~100pt)
- Icon + title layout
- Each card navigates to its feature
- "New" badge on recently added features

---

### 6. Progress Section

**6a. XP Progress Card** (full width)
```
╔══════════════════════════════╗
║  Level 4 · Geographer        ║
║  ████████████░░░░ 1,200 XP  ║
║  300 XP to Level 5 →         ║
╚══════════════════════════════╝
```

**6b. Badges Showcase** (horizontal scroll)
- Recently unlocked badges
- Progress rings on in-progress badges
- Tap → Achievements screen

---

### 7. Deep Dives Section ("Learn More")

Horizontally scrollable larger cards:

| Card | Icon | Description |
|------|------|-------------|
| Language Explorer | 🗣️ | Languages by region |
| Economy Explorer | 📊 | GDP, trade, development |
| Independence Timeline | 📅 | History of independence |
| Ocean Explorer | 🌊 | World's oceans and seas |
| National Symbols | 🦅 | Animals, plants, emblems |
| Country Nicknames | 🏷️ | Informal country names |
| Geography Features | ⛰️ | Mountains, rivers, deserts |

Cards are wider (~200pt) with a preview image/illustration.

---

### 8. Challenge Section ("Challenge Yourself")

Full-width cards with a more intense visual:

```
╔══════════════════════════════╗
║  🧩 Border Challenge         ║
║  Guess countries by their    ║
║  outline shape               ║
║  [Hard] [Play →]             ║
╚══════════════════════════════╝
```

Also includes: Spelling Bee, Word Search, Explore Game, Challenge Room.

---

### 9. Coming Soon Section

Dimmed cards with a lock badge for unreleased features:
```
╔══════════════════╗  ╔══════════════════╗
║ 🔒 Multiplayer   ║  ║ 🔒 AR World Map  ║
║  Coming soon     ║  ║  Coming soon     ║
╚══════════════════╝  ╚══════════════════╝
```

- Use `HomeComingSoonSection.swift` (already exists)
- Cards are tappable (show "Stay tuned" toast or a teaser sheet)
- Semi-transparent with grayscale treatment

---

## Page Switcher (Tab Bar Alternative)

The main tab bar should have:
- **Home** (house icon)
- **Map** (map icon)
- **Quiz** (question mark or star icon)
- **Travel** (plane icon)
- **Profile** (person icon)

The home tab is the only "feed" — other tabs go directly to their feature.

---

## Background Vibe

- Use `AmbientBlobs` / `AnimatedGrid` as described in personal-apps.md
- Blobs go in `.background {}` — NOT in a ZStack with content
- Subtle, slow animation — geography theme (blue/green)
- Dark mode: deep navy/slate; Light mode: soft white/cream

---

## Section Customization (Already Partially Built)

`HomeSectionEditorSheet.swift` allows users to reorder/hide sections.

**Recommended section IDs and defaults**:

```swift
enum HomeSection: String, CaseIterable {
    case countrySpotlight = "country_spotlight"  // Always visible, cannot hide
    case dailyChallenge   = "daily_challenge"    // Always visible
    case streak           = "streak"
    case quickPlay        = "quick_play"
    case explore          = "explore"
    case progress         = "progress"
    case deepDives        = "deep_dives"
    case challenges       = "challenges"
    case comingSoon       = "coming_soon"

    var isAlwaysVisible: Bool {
        self == .countrySpotlight || self == .dailyChallenge
    }
}
```

---

## Section Dividers

All section headers should use `SectionHeaderView(title:icon:)` (already in Design/Component). Never create custom section headers. The accent bar variant (no icon) provides consistent visual rhythm.

---

## Card Tap Actions

Every card must have a defined tap action. Cards that are "in progress" (today's challenge 2/3 complete) should show continuation state, not a fresh start prompt.

---

## Scroll Performance

- Use `LazyVStack` inside a `ScrollView` for the main feed
- Horizontal scroll sections use `ScrollView(.horizontal)` with `LazyHStack`
- `CardView` backgrounds should not trigger unnecessary redraws
- Limit animations to `onAppear` with `.once` semantics

---

## Accessibility

- VoiceOver labels on all cards: describe purpose + state ("Daily Challenge, 2 of 3 complete, tap to continue")
- Dynamic Type: all text uses `DesignSystem.Font.*` which inherits system scaling
- Minimum touch targets: 44×44pt per HIG

---

## What's Missing / Needs Building

| Item | Status |
|------|--------|
| Ambient background behind flag in Country Spotlight | Not built |
| Streak-at-risk pulsing animation | Not built |
| Context-aware XP bar animation on home screen | Not built |
| "New" badge for recently added feature cards | Not built |
| Horizontal deep-dive cards with preview illustrations | Not built |
| Section reorder persistence | Partially built |
