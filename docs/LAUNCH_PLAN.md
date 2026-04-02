# Geografy iOS — App Store Launch Plan

Production readiness plan for a polished, HIG-compliant, zero-bug App Store release.

---

## Current State

- 55+ features, 57 Swift packages, iOS + tvOS targets
- Full modularization complete
- Zero SwiftLint violations, pre-commit hook active
- Interactive maps, 15+ game modes, flashcards, travel tracker, gamification
- StoreKit 2 subscriptions, Game Center, Sign In with Apple
- HIG audit score: 6.3/10

---

## Phase 1: App Store Blockers

Must fix before submission. Rejection guaranteed without these.

### 1.1 Subscription Debug Override
- **File**: `Package/Geografy-Core-Service/.../SubscriptionService.swift`
- `debugPremiumOverride = true` — all premium gating bypassed in DEBUG
- **Fix**: Set to `false`, use TestingModeService runtime toggle instead
- **Verify**: Premium features locked in Release build

### 1.2 StoreKit Configuration
- No `.storekit` file exists — sandbox testing impossible
- Product IDs (`com.khizanag.geografy.premium.monthly/annual/lifetime`) not in App Store Connect
- **Fix**: Create `Geografy.storekit` config file, register products in App Store Connect
- **Verify**: Full purchase flow works in Xcode sandbox

### 1.3 Google Sign In Placeholder
- **File**: `Package/Geografy-Core-Service/.../GoogleSignInHandler.swift`
- `clientID = "PLACEHOLDER_GOOGLE_CLIENT_ID..."` — will crash
- **Fix**: Either configure real Google Cloud Console Client ID, or hide behind feature flag for V1 (Apple Sign In + Guest is sufficient)

### 1.4 Paywall Legal Links
- **File**: `Geografy-Feature-Subscription/.../PaywallScreen.swift`
- "Terms of Service" and "Privacy Policy" are plain text — no tap action, no URL
- **Risk**: App Store Review Guidelines 3.1.1/3.1.2 require functional links — guaranteed rejection
- **Fix**: Create ToS and Privacy Policy pages (GitHub Pages), add `Link` views with URLs
- Also add links in Settings screen

### 1.5 Coin Store IAP
- **File**: `Geografy-Feature-Coin/.../CoinStoreScreen.swift`
- Coin packs displayed with purchase UI but no StoreKit consumable integration
- **Risk**: Showing purchasable items without working IAP = rejection
- **Fix**: Hide "Get More Coins" section behind `FeatureFlagService` (`.coinPurchase`, default disabled). Keep earn-only coin system for V1

### 1.6 Privacy Manifest
- `PrivacyInfo.xcprivacy` exists with UserDefaults and DiskSpace declarations
- **Status**: OK — verify no additional API categories needed before submission

---

## Phase 2: Core Quality

Polish that differentiates a good app from a great one.

### 2.1 Unit Tests
- Zero tests exist across all 57 packages
- **Priority targets**:
  - `Core-CommonTests` — Country model parsing, data validation, quiz configuration
  - `Core-ServiceTests` — CoinService (earn/spend/balance), StreakService (streak logic), XPService (level calculation), FavoritesService (toggle/persistence)
- **Goal**: 30+ tests covering core business logic

### 2.2 Localization Infrastructure
- No `Localizable.xcstrings` — all strings hardcoded English
- **Fix**: Create String Catalog with Xcode auto-extraction
- Cover: navigation titles, button labels, error messages, empty states
- English-only for V1, but infrastructure ready for translations

### 2.3 LaunchScreen Accessibility
- **File**: `Geografy/App/LaunchScreen.swift`
- Animation runs unconditionally — no `reduceMotion` check
- **Fix**: Add `@Environment(\.accessibilityReduceMotion)`, skip animation when enabled

### 2.4 PaywallScreen Design Tokens
- Hardcoded `Color(hex: "0B1320")` — violates design system rules
- Missing `reduceTransparency` check on `.ultraThinMaterial`
- **Fix**: Add color to `DesignSystem.Color`, add transparency fallback

### 2.5 Error Handling in AuthService
- 10+ instances of `try? db.mainContext.save()` — silent data loss
- **Fix**: Centralize save calls with error logging

### 2.6 CoinService Transaction Cap
- Transaction history grows unbounded in UserDefaults
- **Fix**: Cap to last 100 transactions

---

## Phase 3: Architecture Cleanup

Resolve technical debt from rapid modularization.

### 3.1 Cross-Feature Package Dependencies
The modularization plan states: "No feature depends on another feature." Violations:

| Package | Depends On | Fix |
|---------|-----------|-----|
| Feature-Quiz | Feature-NationalSymbols | Move shared types to Core |
| Feature-Multiplayer | Feature-Quiz | Extract quiz engine to Core-QuizComponents |
| Feature-DailyChallenge | Feature-Quiz, Feature-ExploreGame | Same extraction |
| Feature-Travel | Feature-Map | Extract shared map views to Core |
| Feature-CountryDetail | Feature-CountryProfile, Feature-Travel | Extract shared components |
| Feature-CustomQuiz | Feature-CountryList | Extract country picker to Core |

**Action**: Create `Core-QuizComponents` package for shared quiz types/views used across Quiz, Multiplayer, DailyChallenge.

### 3.2 Package.swift Modernization
- All 57 packages use `swift-tools-version: 6.0` — should be `6.3`
- All have `platforms:` field — should be removed per guidelines
- **Fix**: Batch update all Package.swift files

### 3.3 CountryBasicInfo Redundancy
- `CountryBasicInfo` duplicates data from `countries.json`
- **Fix**: Remove and use Country model directly

---

## Phase 4: Deep Links & System Integration

### 4.1 Expand Deep Link Routes
- **File**: `Geografy/Navigation/AppCoordinator.swift`
- Current: Only 7 basic paths (tab switching)
- **Add**: `geografy://country/{code}`, `geografy://daily-challenge`, `geografy://quiz/start/{type}`, `geografy://achievement/{id}`
- Connect to Spotlight search results and widget taps

### 4.2 tvOS App Icons
- Only iOS universal icon present
- **Add**: tvOS icon variants (400x240 top shelf, 1280x768 home screen)

### 4.3 GameCenter Configuration Feedback
- **File**: `Package/Geografy-Core-Service/.../GameCenterService.swift`
- Silently ignores bundle ID configuration errors
- **Fix**: Log warnings, surface connection status in Settings/Profile

### 4.4 Spotlight Indexing
- `SpotlightIndexer` exists but verify it runs on app launch
- Should index all 197 countries for system search

---

## Phase 5: HIG & Design Polish

### 5.1 Accessibility Audit
- VoiceOver: Verify all interactive elements have labels
- Reduce Motion: Guard ALL `.repeatForever()` animations
- Reduce Transparency: Provide opaque fallbacks for all materials
- Hit targets: Minimum 44x44pt for all buttons
- **Goal**: Full VoiceOver navigation of Home → Quiz → Result flow

### 5.2 Empty States
- Verify all list/grid screens use `ContentUnavailableView` for empty state
- Verify all search screens use `ContentUnavailableView.search(text:)` for no results

### 5.3 Consistent Feature Patterns
Every game/quiz feature should have:
- [ ] Setup/landing screen with settings
- [ ] Guide/rules sheet (info button in toolbar)
- [ ] Active session screen
- [ ] Result screen with stats and play-again
- [ ] XP reward display
- [ ] Ambient blob background
- **Audit each**: BorderChallenge (done), FlagGame, WordSearch, Trivia, ExploreGame, MapPuzzle, SpeedRun, DailyChallenge, LandmarkQuiz, Flashcard

### 5.4 iPad Optimization
- Use `NavigationSplitView` for list → detail on iPad landscape
- Add `.onHover()` to cards and buttons
- Add keyboard shortcuts (Cmd+F search, Escape dismiss)
- Ensure grid columns adapt to screen width

---

## Phase 6: Pre-Submission

### 6.1 App Store Connect Setup
- Create app record with bundle ID `com.khizanag.geografy`
- Configure subscription group with 3 products
- Set up Game Center leaderboards (13) and achievements (22)
- Prepare app metadata: description, keywords, categories, age rating

### 6.2 Screenshots
- iPhone 6.7" (iPhone 15 Pro Max) — 5-10 screenshots
- iPhone 6.1" (iPhone 15 Pro) — 5-10 screenshots
- iPad 12.9" — if shipping iPad optimization
- tvOS — if shipping tvOS target
- Key screens: Map, Quiz, Country Detail, Travel Map, Home Feed

### 6.3 TestFlight Verification
- Archive with Release configuration
- Verify debug override is OFF
- Test subscription purchase in sandbox
- Test Apple Sign In (fresh + returning)
- Test deep links from widgets
- Test VoiceOver on key flows
- Test on oldest supported device

### 6.4 App Review Notes
- Provide demo account credentials if needed
- Explain subscription model
- Note Game Center features
- Explain offline-first approach

---

## Timeline Estimate

| Phase | Effort | Priority |
|-------|--------|----------|
| Phase 1: Blockers | 2-3 days | CRITICAL |
| Phase 2: Quality | 3-4 days | HIGH |
| Phase 3: Architecture | 4-5 days | MEDIUM |
| Phase 4: Integration | 2-3 days | MEDIUM |
| Phase 5: Polish | 3-4 days | HIGH |
| Phase 6: Submission | 1-2 days | CRITICAL |
| **Total** | **15-21 days** | |

**Launch-critical path**: Phase 1 + Phase 2 + Phase 6 = **6-9 days**

---

## Success Criteria

- [ ] Subscription purchase works in sandbox (monthly, annual, lifetime)
- [ ] Premium gating active in Release builds
- [ ] Terms of Service and Privacy Policy links functional
- [ ] Google Sign In works or is hidden
- [ ] Coin store purchases hidden until IAP wired
- [ ] 30+ unit tests passing
- [ ] String Catalog created
- [ ] Reduce Motion respected everywhere
- [ ] All features accessible — no stubs visible to users
- [ ] Deep links from widgets navigate correctly
- [ ] TestFlight build verified
- [ ] App Store Connect record with metadata
- [ ] Zero build warnings, zero SwiftLint violations
- [ ] App Store submission accepted
