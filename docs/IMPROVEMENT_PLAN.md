# Improvement Plan

Analyzed April 2026. Organized by priority.

## P0 — Performance (High Impact)

| # | Issue | Where | Fix |
|---|-------|-------|-----|
| 1 | **GeoJSON parsed redundantly in 5+ screens** | MapScreen, OrganizationMapScreen, TravelMapScreen, HistoricalMapScreen, tvOS MapScreen | Create a shared `GeoJSONCache` service — parse once, share `[CountryShape]` across all consumers |
| 2 | **Synchronous JSON load on main actor** | `CountryDataService.swift` | Move `Data(contentsOf:)` + decode to a detached task, publish results back to `@MainActor` |
| 3 | **Pronunciation locale dict rebuilt every call** | `PronunciationService.swift` (computed property ~L66) | Change computed property to `static let` — dictionary is pure data, allocate once |
| 4 | **Widget timeline reloaded on every state change** | `GeografyApp.swift` calls `syncWidgetData` from 4+ handlers | Debounce/throttle: collect changes for ~2s before calling `reloadAllTimelines` once |
| 5 | **Spotlight indexing on startup path** | `GeografyApp.swift` ~L137 | Defer to background after first frame — only re-index when country data actually changes |

## P1 — Correctness (Bugs)

| # | Issue | Where | Fix |
|---|-------|-------|-----|
| 6 | **tvOS NotificationCenter observer leak** | `MultiplayerQuizScreen.swift` ~L636, `QuizSessionScreen.swift` ~L299 | Store the returned observer token from `addObserver(forName:...)` and use `removeObserver(token)` — current `removeObserver(self, ...)` doesn't match closure-based observers |

## P2 — Design System Compliance

| # | Issue | Where | Fix |
|---|-------|-------|-----|
| 7 | **Hardcoded colors** | SubscriptionCard, FeatureComparisonSection, PaywallScreen, TravelTrackerScreen, LevelUpSheet | Replace with `DesignSystem.Color.*` tokens |
| 8 | **Hardcoded spacing** | CountryListScreen, MultiplayerMatchScreen, QuizSessionScreen | Replace numeric literals with `DesignSystem.Spacing.*` tokens |
| 9 | **Duplicated ambient blob backgrounds** | ProfileScreen, TravelTrackerScreen, PaywallScreen, DistanceCalculatorScreen | Replace custom blob implementations with shared `AmbientBlobsView(.preset)` |

## P3 — Accessibility

| # | Issue | Where | Fix |
|---|-------|-------|-----|
| 10 | **Missing `reduceMotion` guard** | `ProfileScreen.swift` ~L100 | Wrap `.repeatForever` with `guard !reduceMotion` |
| 11 | **Icon-only buttons without labels** | QuizSessionScreen (pause button ~L92), HistoricalMapScreen (info button ~L141) | Add `.accessibilityLabel` to icon-only toolbar buttons |

## P4 — Layout Patterns

| # | Issue | Where | Fix |
|---|-------|-------|-----|
| 12 | **`onTapGesture` for interactive selection** | IndependenceTimelineScreen, GeographyFeaturesScreen, OceanExplorerScreen | Replace with `Button` for proper VoiceOver/keyboard support |
| 13 | **Multiplayer service created inline per navigation** | `Destination.swift` ~L108 | Lift service creation to a shared/cached scope |

## P5 — File Size / Structure

| # | File | Lines | Suggestion |
|---|------|-------|------------|
| 14 | CountryDetailScreen.swift | 615 | Split sections into separate files |
| 15 | DistanceCalculatorScreen.swift | 614 | Extract comparison/formatting helpers |
| 16 | QuizSessionScreen.swift | 578 | Extract answer display and timer sections |
| 17 | TravelTrackerScreen.swift | 535 | Extract country picker, stats, blob sections |
| 18 | TravelJournalEditorSheet.swift | 527 | Extract form sections into sub-views |

## Recommended Execution Order

1. **Phase 1** (biggest win): Items 1–2 — GeoJSON cache + async country loading
2. **Phase 2** (correctness): Item 6 — tvOS observer fix
3. **Phase 3** (quick wins): Items 3, 10, 11 — static dict, reduceMotion, a11y labels
4. **Phase 4** (polish): Items 7–9, 12 — design system compliance, onTapGesture → Button
5. **Phase 5** (maintenance): Items 14–18 — file splits
