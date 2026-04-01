# Modularization Plan

Full extraction of Geografy-iOS into Swift packages. Goal: app target contains only the composition root (Home, More, ContentView, GeografyApp, coordinators, Destination content, WidgetDataBridge). Everything else lives in packages.

## Current State

### Extracted Packages (8)

| Package | Location | Contents |
|---------|----------|----------|
| Geografy-Core-Common | `Package/Geografy-Core-Common/` | Country, Organization, UserLevel, UserProfile, QuizConfiguration, QuizRegion, QuizType, QuizDifficulty, TravelStatus, FlashcardDeck, SpacedRepetitionData, all data models and static data |
| Geografy-Core-DesignSystem | `Package/Geografy-Core-DesignSystem/` | DesignSystem namespace (Color, Font, Spacing, Size, CornerRadius, IconSize, Shadow), FlagView, AmbientBlobsView, HapticsService, SectionHeaderView, CardView, PressButtonStyle, CircleCloseButton |
| Geografy-Core-Navigation | `Package/Geografy-Core-Navigation/` | Navigator, Destination enum (cases only), CoordinatedNavigationStack, closeButtonPlacementLeading, destinationContentProvider |
| Geografy-Core-Service | `Package/Geografy-Core-Service/` | CountryDataService, TravelService, GeoJSONParser, CountryBasicInfo, MapColorPalette |
| Geografy-Feature-Map | `Geografy/Feature/Geografy-Feature-Map/` | MapCanvasView, MapLoadingView, MapState, CountryBannerView, MapControlsView |
| Geografy-Feature-Quotes | `Geografy/Feature/Geografy-Feature-Quotes/` | QuotesScreen, QuotesService, quotes.json |
| Geografy-Feature-TimeZone | `Geografy/Feature/Geografy-Feature-TimeZone/` | TimeZoneScreen |
| Geografy-Feature-SizeVisualization | `Geografy/Feature/Geografy-Feature-SizeVisualization/` | SizeVisualizationScreen, SizeCompareView |

### Dependency Graph

```
Core-Common
    ^
    |
Core-DesignSystem  (includes HapticsService)
    ^           ^
    |           |
Core-Navigation    Core-Service
    ^               ^
    |               |
    +-------+-------+
            ^
     Feature Packages  (no feature imports another feature)
            ^
        App Target  (composition root)
```

**Rule: No feature package depends on another feature package.** The app target's `Destination.content` extension wires everything together.

---

## Phase 0: Expand Core Packages

### 0A. Move Design Components to Core-DesignSystem

Pure UI components with zero service dependencies. Each must get `public` access control.

| # | Component | File | Notes |
|---|-----------|------|-------|
| 1 | GlassButton | `Design/Component/GlassButton.swift` | |
| 2 | GeoButton | `Design/Component/GeoButton.swift` | |
| 3 | IconButton | `Design/Component/IconButton.swift` | |
| 4 | QuizTimerBadge | `Design/Component/QuizTimerBadge.swift` | Used by Quiz, DailyChallenge, SpeedRun, Multiplayer |
| 5 | QuestionCounterPill | `Design/Component/QuestionCounterPill.swift` | |
| 6 | SessionProgressBar | `Design/Component/SessionProgressBar.swift` | |
| 7 | SessionProgressView | `Design/Component/SessionProgressView.swift` | |
| 8 | ResultStatItem | `Design/Component/ResultStatItem.swift` | |
| 9 | TypeSelectionGrid | `Design/Component/TypeSelectionGrid.swift` | |
| 10 | RegionSelectionBar | `Design/Component/RegionSelectionBar.swift` | |
| 11 | AlphabetJumpIndex | `Design/Component/AlphabetJumpIndex.swift` | |
| 12 | ComingSoonView | `Design/Component/ComingSoonView.swift` | |
| 13 | EmptyStateView | `Design/Component/EmptyStateView.swift` | |
| 14 | FavoriteToggleButton | `Design/Component/FavoriteToggleButton.swift` | |
| 15 | GuideSheet | `Design/Component/GuideSheet.swift` | |
| 16 | InfoTile | `Design/Component/InfoTile.swift` | |
| 17 | LanguageBarChart | `Design/Component/LanguageBarChart.swift` | |
| 18 | PercentageBarChart | `Design/Component/PercentageBarChart.swift` | |
| 19 | LetterGridView | `Design/Component/LetterGridView.swift` | |
| 20 | LevelBadgeView | `Design/Component/LevelBadgeView.swift` | |
| 21 | NewBadge | `Design/Component/NewBadge.swift` | |
| 22 | PremiumBadge | `Design/Component/PremiumBadge.swift` | |
| 23 | PremiumLockedOverlay | `Design/Component/PremiumLockedOverlay.swift` | |
| 24 | ProfileAvatarView | `Design/Component/ProfileAvatarView.swift` | |
| 25 | PulsingCirclesView | `Design/Component/PulsingCirclesView.swift` | |
| 26 | XPProgressBar | `Design/Component/XPProgressBar.swift` | |
| 27 | ZoomableFlagView | `Design/Component/ZoomableFlagView.swift` | |
| 28 | ZoomableOrgLogoView | `Design/Component/ZoomableOrgLogoView.swift` | |

**Stay in app target (service dependencies):**
- CountryRowView (depends on PronunciationService via @Environment)
- SpeakerButton (depends on PronunciationService via @Environment)

### 0B. Move Services to Core-Service

Extract in dependency order: standalone first, then SwiftData services.

**Standalone services (no SwiftData):**

| # | Service | Dependencies | Storage |
|---|---------|-------------|---------|
| 1 | FeatureFlagService | Foundation | UserDefaults |
| 2 | TestingModeService | Common | UserDefaults |
| 3 | CoinService | Common | UserDefaults |
| 4 | CurrencyService | Common | File cache + network |
| 5 | PronunciationService | AVFoundation, Common | None |
| 6 | GameCenterService | GameKit, Common | None |
| 7 | SubscriptionService | StoreKit, Common | None |
| 8 | WorldBankService | Common | Network |
| 9 | NotificationService | UserNotifications | None |
| 10 | SpotlightIndexer | CoreSpotlight, Common | None |
| 11 | BackgroundTaskService | BackgroundTasks | None |
| 12 | LearningPathService | Common | UserDefaults |

**SwiftData services (extract after standalone):**

| # | Service | Depends On |
|---|---------|-----------|
| 13 | DatabaseManager | SwiftData, Common |
| 14 | FavoritesService | SwiftData, Common, DatabaseManager |
| 15 | XPService | SwiftData, Common, DatabaseManager |
| 16 | AchievementService | SwiftData, Common, DatabaseManager, XPService |
| 17 | StreakService | SwiftData, Common, DatabaseManager, XPService, AchievementService |
| 18 | AuthService | AuthenticationServices, SwiftData, DatabaseManager |

**Stay in app target:**
- HomeSectionOrderService (tied to HomeSection enum)
- WidgetDataBridge (WidgetKit, depends on app services)

**Risk:** Core-Service may grow large (40+ files). If so, split into `Core-Service-Data` (SwiftData) and `Core-Service` (pure). Defer this split unless package becomes unwieldy.

---

## Phase 1: Tier A Features — Self-Contained

Zero environment service dependencies. Each feature has its own local service/model. Simplest extractions.

| # | Package | Files | Depends On |
|---|---------|-------|------------|
| 1 | Feature-Theme | 1 | DesignSystem |
| 2 | Feature-GeographyFeatures | 1 + service | DesignSystem |
| 3 | Feature-LanguageExplorer | 2 + service | DesignSystem |
| 4 | Feature-CultureExplorer | 2 + service | DesignSystem |
| 5 | Feature-LandmarkGallery | 2 + service | DesignSystem |
| 6 | Feature-OceanExplorer | 1 + service | Common, DesignSystem |
| 7 | Feature-WorldRecords | 1 + service | Navigation, Common, Service, DesignSystem |
| 8 | Feature-Trivia | 1 + service | Service, DesignSystem |
| 9 | Feature-IndependenceTimeline | 1 + service | Navigation, Common, Service, DesignSystem |
| 10 | Feature-EconomyExplorer | 1 | Navigation, Common, Service, DesignSystem |
| 11 | Feature-MapPuzzle | 2 | Navigation, Common, DesignSystem |

---

## Phase 2: Tier B Features — Environment Service Dependencies

These read services via `@Environment` (HapticsService, CountryDataService, etc.) but don't use SwiftData directly.

| # | Package | Files | Key Env Services |
|---|---------|-------|-----------------|
| 12 | Feature-BorderChallenge | 2 + service | CountryDataService, HapticsService, XPService |
| 13 | Feature-FlagGame | 2 | CountryDataService, HapticsService |
| 14 | Feature-MapColoring | 1 | CountryDataService, HapticsService |
| 15 | Feature-Compare | 5 | CountryDataService, HapticsService |
| 16 | Feature-WordSearch | 3 + service | Navigator |
| 17 | Feature-NeighborExplorer | 2 | CountryDataService |
| 18 | Feature-CountryNicknames | 2 + service | CountryDataService, HapticsService, Navigator |
| 19 | Feature-ContinentStats | 2 | CountryDataService, HapticsService, Navigator |
| 20 | Feature-LandmarkQuiz | 1 + service | CountryDataService, HapticsService |
| 21 | Feature-Feed | 2 + service | CountryDataService, Navigator |
| 22 | Feature-Organization | 2 | CountryDataService, HapticsService, Navigator |
| 23 | Feature-LearningPath | 3 | Common, DesignSystem, LearningPathService |
| 24 | Feature-DistanceCalculator | 1 | CountryDataService, HapticsService, Navigator |
| 25 | Feature-CurrencyConverter | 1 | CountryDataService, CurrencyService, HapticsService |
| 26 | Feature-NationalSymbols | model + service | Minimal |
| 27 | Feature-AllMap | 2 | Navigator |
| 28 | Feature-Timeline | 5 | Navigator, Common |

---

## Phase 3: Tier C Features — Heavy Dependencies

SwiftData services, StoreKit, auth, cross-feature navigation.

| # | Package | Files | Heavy Deps |
|---|---------|-------|------------|
| 29 | Feature-Quiz | 8 + SpeedRun + SpellingBeeGuide | SubscriptionService, Navigator, CountryDataService |
| 30 | Feature-Flashcard | 7 + service | FlashcardService, Navigator, CountryDataService |
| 31 | Feature-DailyChallenge | 7 + service | DailyChallengeService, XPService |
| 32 | Feature-ExploreGame | 6 + service | ExploreGameService, CountryDataService |
| 33 | Feature-Multiplayer | 6 + 4 models + 2 services | Navigator, CountryDataService |
| 34 | Feature-Achievement | 5 + model | AchievementService, HapticsService |
| 35 | Feature-Coin | 5 | CoinService |
| 36 | Feature-Travel | 7 | TravelService, CountryDataService, Navigator |
| 37 | Feature-TravelJournal | 6 + model + service | CountryDataService, HapticsService |
| 38 | Feature-QuizPack | 5 + 4 models + service | SubscriptionService, CountryDataService, Navigator |
| 39 | Feature-CountryProfile | 5 + models + service | Common |
| 40 | Feature-CustomQuiz | multiple | Navigator, CountryDataService |
| 41 | Feature-CountryDetail | 14 | Nearly ALL services |
| 42 | Feature-CountryList | 1 | FavoritesService, CountryDataService, Navigator |
| 43 | Feature-Subscription | 3 | SubscriptionService, StoreKit |
| 44 | Feature-Auth | 2 | AuthService |
| 45 | Feature-GameCenter | 2 | GameCenterService, Navigator |
| 46 | Feature-Search | 1 + service | Navigator, CountryDataService |
| 47 | Feature-Favorite | 1 | FavoritesService, CountryDataService, Navigator |
| 48 | Feature-Setting | 3 | AuthService, SubscriptionService, Navigator |
| 49 | Feature-Profile | 2 | Nearly ALL services + SwiftData |

---

## Never Extract (Stay in App Target)

| Component | Reason |
|-----------|--------|
| **Home** (28+ files) | Depends on nearly every service and feature |
| **More** | Navigation hub to all features |
| **ContentView** | Tab bar container |
| **GeografyApp** | Composition root, service initialization |
| **Destination content extension** | Maps Destination enum cases to feature Views |
| **AppCoordinator** | Tab selection |
| **WidgetDataBridge** | WidgetKit-specific |
| **HomeSectionOrderService** | HomeSection-specific |
| **CountryRowView** | PronunciationService @Environment dependency |
| **SpeakerButton** | PronunciationService @Environment dependency |

---

## Extraction Workflow (Per Feature)

Repeat for every feature extraction:

1. **Create Package.swift** at `Geografy/Feature/Geografy-Feature-X/`
   ```swift
   // swift-tools-version: 6.0
   import PackageDescription
   let package = Package(
       name: "Geografy-Feature-X",
       platforms: [.iOS("26.0"), .tvOS("26.0")],
       products: [
           .library(name: "Geografy-Feature-X", targets: ["Geografy-Feature-X"]),
       ],
       dependencies: [
           .package(path: "../../../Package/Geografy-Core-Common"),
           .package(path: "../../../Package/Geografy-Core-DesignSystem"),
           // add only what's needed
       ],
       targets: [
           .target(
               name: "Geografy-Feature-X",
               dependencies: [
                   .product(name: "Geografy-Core-Common", package: "Geografy-Core-Common"),
                   .product(name: "Geografy-Core-DesignSystem", package: "Geografy-Core-DesignSystem"),
               ]
           ),
           .testTarget(
               name: "Geografy-Feature-XTests",
               dependencies: ["Geografy-Feature-X"]
           ),
       ],
       swiftLanguageModes: [.v6]
   )
   ```
2. **Create directory structure**: `Sources/Geografy-Feature-X/`, `Tests/Geografy-Feature-XTests/`
3. **Move Swift files** from `Geografy/Feature/X/` to `Sources/Geografy-Feature-X/`
4. **Add `public` access** to all types, properties, inits, methods used externally
5. **Remove self-imports** (if the file imported itself)
6. **Sort imports** alphabetically
7. **Update Destination.swift** (app target): add `import Geografy_Feature_X`
8. **Add package to pbxproj** using Python `str.replace()` for both iOS and tvOS targets
9. **Remove stale file references** from pbxproj exception lists
10. **Build both iOS and tvOS** targets
11. **Run `swiftlint lint --strict`** on changed files
12. **Commit and push**

---

## Circular Dependency Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Core-Service grows too large | Medium | Monitor file count. Split into Core-Service-Data + Core-Service if >40 files |
| CountryRowView needs PronunciationService | Low | Keep in app, or refactor to accept `onSpeak: (String) -> Void` closure |
| Feature A navigates to Feature B | None | Navigation through Destination enum in Core-Navigation; app wires views |
| Core-Service depends on Core-Navigation | Low | Already the case. Keep Navigation free of service dependencies |
| DesignSystem components need services | Low | Only move pure UI components. Service-dependent components stay in app |

---

## Success Criteria

- [ ] All ~18 shared services moved to Core-Service
- [ ] All ~22 pure design components moved to Core-DesignSystem
- [ ] All ~42 extractable features in individual packages
- [ ] Zero circular dependencies
- [ ] iOS and tvOS targets build with zero errors and zero warnings after each extraction
- [ ] App target contains only: GeografyApp, ContentView, Home, More, Destination content, coordinators, WidgetDataBridge, CountryRowView, SpeakerButton
- [ ] Each package has a test target

---

## Statistics

| Category | Total | Already Done | To Extract | Stays in App |
|----------|-------|-------------|------------|-------------|
| Core Packages | 4 | 4 | 0 (expand existing) | -- |
| Design Components | ~30 | ~8 | ~22 to DesignSystem | ~2 |
| Services | ~28 | 3 | ~18 to Core-Service | ~2 |
| Feature Packages | ~50 | 4 | ~42 | ~6 |
