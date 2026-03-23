# App Feature Status

Status of all features as of 2026-03-23. Derived from the `Feature/` directory structure and existing view/model/service files.

> **Legend**:
> - ✅ **Implemented** — View, model, service exist; navigable from app
> - 🔧 **Partial** — Some files exist; not fully wired or incomplete
> - 🏗️ **Scaffold** — Files created but mostly placeholder/stub
> - ❌ **Planned** — In CLAUDE.md or planned but no files yet

---

## Core Features

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 1 | **World Map** | ✅ | `Map/` | Interactive canvas map, zoom/pan, 258 shapes, capital pins, continent filter |
| 2 | **Country Detail** | ✅ | `CountryDetail/` | Hero flag, quick facts, economy, people, organizations, flag symbolism, neighbors, UNESCO, fun facts, phrasebook, deep dive |
| 3 | **Country List** | ✅ | `CountryList/` | Searchable, sortable, filterable, grouped by continent |
| 4 | **Favorites** | ✅ | `Favorite/` | FavoritesScreen — saved country list |
| 5 | **Quiz (main)** | ✅ | `Quiz/` | 6 types, 3 difficulties, region filter, timer, XP rewards, results |
| 6 | **Travel Tracker** | ✅ | `Travel/` | Mark visited / want-to-visit, travel map |
| 7 | **Authentication** | ✅ | `Auth/` | Apple Sign In, Google Sign In, Guest mode, GuestModePromptBanner |
| 8 | **Profile** | ✅ | `Profile/` | Profile screen, edit profile |
| 9 | **Settings** | ✅ | `Setting/` | Theme, orientation, territorial disputes, notifications, sound |
| 10 | **Achievements** | ✅ | `Achievement/` | AchievementsScreen, AchievementCard, LevelUpSheet, AchievementUnlockedBanner |

---

## Gamification

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 11 | **Badges** | ✅ | `Badge/` | BadgeDefinition, BadgeRarity, BadgeCard, BadgeCollectionScreen, BadgeDetailSheet, BadgeShowcase, BadgeUnlockAnimation, BadgeService |
| 12 | **XP & Levels** | ✅ | `Data/Model/` | UserLevel (10 levels), XPRecord, XPSource |
| 13 | **Streaks** | ✅ | `Data/Model/` | StreakRecord model; HomeStreakCard; logic TBD |
| 14 | **Game Center** | 🔧 | `GameCenter/` | LeaderboardScreen + GKViewController wrapper exist; achievement reporting integration TBD |
| 15 | **Coin System** | 🔧 | `Coin/` | CoinBalanceView, CoinPackCard, CoinPackPreviewSheet, CoinStoreScreen, CoinTransactionRow exist; purchase integration TBD |

---

## Quiz Variants

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 16 | **Flag Game** | ✅ | `FlagGame/` | FlagGameScreen, FlagGameResultScreen |
| 17 | **Capital Quiz** | ✅ | `CapitalQuiz/` | CapitalQuizSetupScreen (leads into main Quiz engine) |
| 18 | **Daily Challenge** | ✅ | `DailyChallenge/` | DailyChallengeScreen, DailyChallengeSessionScreen, DailyChallengeResultView, DailyChallengeShareCard; mystery country, flag sequence, capital chain challenge types |
| 19 | **Custom Quiz** | ✅ | `CustomQuiz/` | CustomQuizBuilderScreen, CustomQuizLibraryScreen, CustomQuizPreviewScreen, CustomQuizCountryPicker, CustomQuizCard |
| 20 | **Quiz Pack** | 🔧 | `QuizPack/` | Folder exists; contents TBD |
| 21 | **Geo Trivia** | ✅ | `GeoTrivia/` | GeoTriviaScreen |
| 22 | **Country Nicknames Quiz** | ✅ | `CountryNicknames/` | CountryNicknamesScreen, NicknameQuizScreen, CountryNicknamesService, CountryNickname model |
| 23 | **Landmark Quiz** | 🏗️ | `LandmarkQuiz/` | HomeLandmarkQuizCard exists; screen TBD |

---

## Learning & Exploration Features

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 24 | **Flashcards / SRS** | ✅ | `Flashcard/` | FlashcardScreen, FlashcardSessionScreen, FlashcardCardView, FlashcardDeckCard, FlashcardStatsView, SRSStudyScreen |
| 25 | **Learning Paths** | 🏗️ | `LearningPath/` | HomeLearningPathCard exists; screen TBD |
| 26 | **Language Explorer** | ✅ | `LanguageExplorer/` | HomeLanguageExplorerCard + screen exists |
| 27 | **Economy Explorer** | ✅ | `EconomyExplorer/` | EconomyExplorerScreen |
| 28 | **Independence Timeline** | ✅ | `IndependenceTimeline/` | HomeIndependenceTimelineCard + screen |
| 29 | **Ocean Explorer** | ✅ | `OceanExplorer/` | HomeOceanExplorerCard + screen |
| 30 | **Geography Features** | ✅ | `GeographyFeatures/` | GeographyFeaturesScreen |
| 31 | **National Symbols** | ✅ | `NationalSymbols/` | HomeNationalSymbolsCard + screen |
| 32 | **Country Profile (Deep)** | ✅ | `CountryProfile/` | CountryProfileScreen, CountryProfileSection, CountryTimelineView, FunFactCard, PhraseCard |
| 33 | **Culture Explorer** | 🏗️ | `CultureExplorer/` | CultureFact model, CultureService; view TBD |
| 34 | **Organizations** | ✅ | `Organization/` | 17 orgs; OrganizationList + OrganizationDetail screens |
| 35 | **Neighbor Explorer** | 🏗️ | `NeighborExplorer/` | HomeNeighborExplorer TBD; CountryNeighborsSection in CountryDetail |
| 36 | **Continent Stats** | ✅ | `ContinentStats/` | ContinentStatsScreen, ContinentPickerScreen |
| 37 | **Country Comparison** | ✅ | `Compare/` | CompareScreen, CompareBarChart, CompareCountryPicker, CompareCountrySlot, CompareMetricRow |
| 38 | **Travel Bucket List** | ✅ | `Travel/` | HomeTravelBucketListCard; part of travel tracker |
| 39 | **World Records** | ✅ | `WorldRecords/` | HomeWorldRecordsCard + screen |
| 40 | **Continent Maps (All)** | ✅ | `AllMap/` | AllMapsScreen, ContinentOverviewScreen |

---

## Challenge Games

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 41 | **Border Challenge** | ✅ | `BorderChallenge/` | BorderChallengeScreen, BorderChallengeService |
| 42 | **Explore Game** | ✅ | `ExploreGame/` | ExploreGameScreen, ExploreGameSessionScreen, ExploreClueCard, ExploreGuessField, ExploreGameResultView, ClueGenerator, ExploreGameRulesSheet |
| 43 | **Spelling Bee** | 🏗️ | `SpellingBee/` | HomeSpellingBeeCard exists; full game screen TBD |
| 44 | **Word Search** | ✅ | `WordSearch/` | HomeWordSearchCard + screen exists |
| 45 | **Map Puzzle** | 🏗️ | `MapPuzzle/` | HomeMapPuzzleCard exists; drag-and-drop puzzle screen TBD |
| 46 | **Map Coloring** | ✅ | `MapColoring/` | HomeMapColoringCard + MapColoringScreen |
| 47 | **Challenge Room** | ✅ | `ChallengeRoom/` | ChallengeSetupScreen, ChallengeGameScreen, ChallengeResultScreen, ChallengeRoomService, ChallengeRoom model |

---

## Social & Multiplayer

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 48 | **Multiplayer** | 🏗️ | `Multiplayer/` | Folder exists; no view files yet — planned feature |
| 49 | **Geo Feed** | ✅ | `GeoFeed/` | GeoFeedScreen, GeoFeedCard — curated geography news/facts feed |

---

## Utility & System

| # | Feature | Status | Folder | Notes |
|---|---------|--------|--------|-------|
| 50 | **Subscription / Paywall** | 🔧 | `Subscription/` | PaywallScreen, SubscriptionCard, FeatureComparisonSection; StoreKit 2 integration TBD; debug override on |
| 51 | **Search** | 🏗️ | `Search/` | Folder exists; global search across countries/org/etc. TBD |
| 52 | **Theme** | 🏗️ | `Theme/` | Folder exists; runtime theme switching beyond dark/light TBD |
| 53 | **More / Tools** | 🏗️ | `More/`, `Tools/` | Navigation hubs; contents TBD |
| 54 | **Timeline** | 🏗️ | `Timeline/` | Historical events timeline; distinct from IndependenceTimeline |
| 55 | **Travel Journal** | 🏗️ | `TravelJournal/` | Notes/photos per visited country; premium feature planned |

---

## Overnight Implementation Summary (Features 10–33+)

Based on commit history messages, the following features were built in recent sessions:

### Committed: "Add Continent Stats Dashboard, Country Comparison, and Travel Bucket List"
- ✅ ContinentStats (ContinentStatsScreen, ContinentPickerScreen)
- ✅ Compare (full CompareScreen with charts)
- ✅ Travel Bucket List card on home

### Committed: "Add Ocean Explorer, Language Explorer, and Challenge Room"
- ✅ OceanExplorer
- ✅ LanguageExplorer
- ✅ ChallengeRoom (full game flow: setup → game → result)

### Committed: "Add Independence Timeline, Economy Explorer, and Geography Features"
- ✅ IndependenceTimeline
- ✅ EconomyExplorer
- ✅ GeographyFeatures

### Committed: "Add National Symbols Quiz, Map Coloring Book, and Country Nicknames"
- ✅ NationalSymbols
- ✅ MapColoring
- ✅ CountryNicknames (with NicknameQuiz)

### Committed: "Add Geography Word Search, Country Culture data, and Border Challenge"
- ✅ WordSearch
- 🏗️ CultureExplorer (data + service; view TBD)
- ✅ BorderChallenge

---

## Feature Count Summary

| Status | Count |
|--------|-------|
| ✅ Fully Implemented | ~35 |
| 🔧 Partial (files exist, integration incomplete) | ~5 |
| 🏗️ Scaffold (card/stub only, main screen TBD) | ~10 |
| ❌ Planned (not started) | ~5 |
| **Total** | **~55** |

---

## Known Gaps / Technical Debt

1. **SubscriptionService** — StoreKit 2 products not configured; debug override means nothing is actually gated
2. **GameCenter** — Auth and achievement reporting not wired to XP/quiz events
3. **QuizPack** — Folder exists but unclear what it contains or how it differs from CustomQuiz
4. **Multiplayer** — Folder only; no networking layer yet
5. **CultureExplorer** — Service and model exist but no screen; the data needs to be surfaced
6. **Search** — Global cross-feature search would be high value; not built
7. **LearningPath** — Home card exists but no actual path/curriculum logic
8. **SpellingBee** — Home card suggests it's planned; the game logic (country name spelling) would be unique
9. **MapPuzzle** — High complexity (drag-and-drop country shapes into correct positions); significant effort
10. **TravelJournal** — Photos/notes per country requires camera access + local storage design
