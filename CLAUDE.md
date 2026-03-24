# Geografy-iOS

Geography learning app — interactive maps, country facts, flags, capitals, quizzes, travel tracker, gamification.

## App Identity
- **Name**: Geografy
- **Bundle ID**: `com.khizanag.geografy` (dev: `com.khizanag.geografy.dev`)
- **Minimum iOS**: 26.0
- **GitHub**: Khizanag/Geografy-iOS (SSH host: github-khizanag)
- **Git author**: khizanag@gmail.com
- **Signing team**: JSCB TBC Bank (SpaceInt) for development

## Shared Guidelines
Follow all rules in `~/.claude/rules/personal-apps.md` (shared across all personal apps).

## Architecture
- **UI**: SwiftUI only (UIKit only when SwiftUI can't achieve the goal)
- **Design pattern**: Views with extracted subviews. MVVM only when views become large
- **Design system**: `DesignSystem.Color`, `DesignSystem.Font`, `DesignSystem.Spacing`, `DesignSystem.Size`, `DesignSystem.CornerRadius`, `DesignSystem.IconSize`
- **Navigation**: Coordinator pattern — `AppCoordinator` owns per-tab `TabCoordinator`s. `Screen` (push), `Sheet` (modal), `Cover` (fullScreenCover) enums with factory views. `CoordinatedNavigationStack` wraps each tab.
- **Data**: 197 countries in `countries.json`, 10m GeoJSON for map borders, 255 PDF flag assets, 29 international organizations
- **Offline-first**: All data bundled, no network required (World Bank API for live stats)
- **StoreKit 2**: Full subscription flow (monthly/annual/lifetime), debug override for development
- **Game Center**: Authentication, 13 leaderboards, 22 achievements, friends list, offline queue

## Folder Structure
```
Geografy/
  App/                    — Entry point, ContentView
    Navigation/           — AppCoordinator, TabCoordinator, Screen/Sheet/Cover enums, Factories
  Design/
    Theme/                — Colors, Font, Spacing, Size, CornerRadius, IconSize, Shadow
    Component/            — Reusable UI components (see Component Catalog below)
  Feature/
    Home/                 — Home feed with 38 configurable sections, curated order
    Map/                  — Interactive world map, continent maps, canvas rendering
    CountryDetail/        — Country detail with flag symbolism, UNESCO, phrasebook, deep dive
    CountryList/          — Searchable, sortable, filterable country list
    Quiz/                 — 6 quiz types, 3 difficulties, typing mode, speed run
    Flashcard/            — Spaced repetition flashcards with swipe gestures
    Travel/               — Travel tracker, travel map, bucket list
    DailyChallenge/       — Daily mystery country, flag sequence, capital chain
    ExploreGame/          — Mystery country with progressive clues
    Multiplayer/          — PvP quiz matches
    Auth/                 — Apple Sign In, Google Sign In, guest mode
    Profile/              — Profile with stats, badges, weekly heatmap
    Achievement/          — 21 achievements with unlock animations
    Badge/                — 42 badges across 10 categories
    GameCenter/           — Leaderboards, friends list
    Setting/              — Theme, territorial disputes, notifications, sound
    Organization/         — 29 international organizations
    Compare/              — Side-by-side country comparison
    Timeline/             — Historical events timeline
    Tools/                — Distance calculator, currency converter, time zones
    Search/               — Global search across countries and organizations
    SpellingBee/          — Spell country names from flag clues
    FlagGame/             — Match flags to countries
    Trivia/               — Geography trivia questions
    BorderChallenge/      — Guess countries by outline shape
    WordSearch/           — Geography word search puzzle
    MapColoring/          — Interactive map coloring
    ChallengeRoom/        — Multiplayer-style challenge flow
    LearningPath/         — Guided geography curriculum
    CountryNicknames/     — Informal country names + quiz
    NationalSymbols/      — Animals, plants, emblems quiz
    WorldRecords/         — Tallest, largest, deepest geography facts
    OceanExplorer/        — World's oceans and seas
    LanguageExplorer/     — Languages by region
    EconomyExplorer/      — GDP, trade, development data
    GeographyFeatures/    — Mountains, rivers, deserts
    IndependenceTimeline/ — Country independence history
    ContinentStats/       — Stats dashboard per continent
    LandmarkQuiz/         — Identify famous landmarks
    GeoFeed/              — Curated geography news and facts
    Subscription/         — Paywall, subscription cards (StoreKit 2)
    Favorite/             — Saved countries
    AllMap/               — All maps grid, continent overview
    TravelJournal/        — Travel notes and photos
    SpeedRun/             — Name all countries against the clock
    CapitalQuiz/          — Dedicated capital city quiz mode
    CultureExplorer/      — Cultural facts by country
    CountryProfile/       — Deep dive profile pages
    Coin/                 — Coin system (planned)
    Favorite/             — Favorites screen
  Data/
    Model/                — Country, Organization, UserLevel, XPRecord, FlagAspectRatio, etc.
    Service/              — CountryDataService, XPService, StreakService, SubscriptionService, GameCenterService, etc.
  Resource/
    Assets.xcassets/      — Colors, AppIcon, Flags (255 PDF imagesets)
    countries.json        — 197 countries with full data
    countries.geojson     — 10m Natural Earth borders (13MB)
  Utility/                — NumberFormatting, CGPath+Contains
```

## Component Catalog (CRITICAL — always reuse)
These components MUST be reused — NEVER create alternatives:

### Navigation & Chrome
- **Close button**: `CircleCloseButton()` — every sheet MUST have one in `.topBarTrailing` toolbar
- **Section headers**: `SectionHeaderView(title:icon:isNew:)` — accent bar or icon style
- **Glass buttons**: `GlassButton("Title", systemImage:, role:, fullWidth:)` for primary/secondary actions
- **Press style**: `PressButtonStyle()` for tappable cards
- **Toolbar buttons**: Always `.buttonStyle(.plain)` — no tinted toolbar buttons

### Content Display
- **Flags**: `FlagView(countryCode:height:)` — PDF vectors with correct aspect ratios
- **Cards**: `CardView { content }` — standard card background
- **Country rows**: `CountryRowView(country:isFavorite:...)` — standard country list item
- **Profile avatar**: `ProfileAvatarView(name:size:)`
- **Premium badge**: `PremiumBadge()`
- **Level badge**: `LevelBadgeView`
- **Score ring**: `ScoreRingView`
- **New badge**: `NewBadge()` — "NEW" capsule for recent features

### Selection Components (one solution per problem)
- **Game type selection**: `TypeSelectionGrid` (horizontal card scroll) — for quiz types, flashcard types
- **Region selection**: `RegionSelectionBar` (horizontal capsule chips) — for continent/region filtering
- **Quiz answer options**: `QuizOptionButton` — for ALL quiz-like answer buttons (Quiz, DailyChallenge, Multiplayer, TimeZone, Trivia)
- **Difficulty**: Segmented `Picker` — for Easy/Medium/Hard
- **Compact values**: Menu `Picker` — for question count, theme, etc.

### Session Components
- **Ambient backgrounds**: `AmbientBlobsView(.preset)` — animated blob backgrounds
- **Progress bars**: `SessionProgressBar(progress:)` — animated fill with glow
- **Counter pills**: `QuestionCounterPill(current:total:)` — "X/Y" session counter
- **Empty states**: `EmptyStateView(icon:title:subtitle:)` — centered empty content
- **Result stats**: `ResultStatItem(icon:value:label:color:)` — stat grid items

## Key Conventions
- **VStack spacing over padding**: Use `VStack(spacing:)` — NEVER repeat `.padding(.top, X)` on every item
- **Full variable names**: `geometryReader` not `geo`, `index` not `idx`, `button` not `btn`
- **Decompose for readability**: Split into well-named functions and computed properties
- **Never disable SwiftLint**: Fix the underlying issue instead
- **Screen size compatibility**: Every page must work on iPhone 12 Mini (375pt) and largest iPhones
- **No hardcoded colors**: Colors → `DesignSystem.Color.*`, shadows → `.geoShadow(.subtle/.card/.elevated)`
- **No SwiftUI colors directly**: No `.white`, `.black`, `.blue` — use DesignSystem tokens
- **Glass effects**: Use iOS 26 `.glassEffect()` and `.buttonStyle(.glass)`
- **Action buttons in footer**: Primary actions (Start, Submit, Find) go in `.safeAreaInset(edge: .bottom)`, not in scroll content
- **Blobs in background**: Always `.background { AmbientBlobsView(.preset) }` — NEVER in a ZStack with content
- **Trunk-based development**: Commit + push every valid increment immediately
- **Sub-feature folders**: Features with sub-pages use nested folders (e.g., `ExploreGame/ExploreGameRules/View/`)

## Current State (55+ features)
- Interactive world map with 258 countries, zoom/pan, country selection, capital pins
- Country detail with flag symbolism, UNESCO heritage, phrasebook, fun facts, neighbors, deep dive
- 6 quiz types with typing mode, 3 difficulties, region filter, timer, XP rewards
- Flashcard spaced repetition with swipe gestures, thinking time tracking
- 15+ game modes: Speed Run, Flag Game, Spelling Bee, Trivia, Border Challenge, Word Search, etc.
- Daily Challenge with mystery country, flag sequence, capital chain
- Travel tracker with visited/want-to-visit, travel map, bucket list, journal
- Coordinator pattern navigation with 5 tabs
- Game Center: 13 leaderboards, 22 achievements, friends list with XP rankings
- StoreKit 2 subscriptions (monthly/annual/lifetime)
- Sign In with Apple + Google Sign In + Guest mode
- XP system with 10 levels, 42 badges, 21 achievements, streaks with heatmap
- Distance calculator, currency converter, time zone learning
- 29 international organizations with member data
- iOS widgets: Country of the Day, Daily Streak, World Progress
