# Apple Human Interface Guidelines — Comprehensive Audit Report

**App:** Geografy (Geography Learning)
**Platforms:** iOS, iPadOS, macOS (Catalyst), tvOS
**Date:** March 31, 2026

---

## Executive Summary

| Platform | Score | Status |
|----------|-------|--------|
| iOS | 7.5/10 | Good — strong design system, accessibility gaps |
| tvOS | 7/10 | Good foundation — accessibility critical gaps |
| iPadOS | 5.5/10 | Partial — missing pointer, keyboard, split view |
| macOS Catalyst | 4.5/10 | Minimal — missing menus, windows, hover |
| Widgets | 9/10 | Excellent — all sizes, Lock Screen, dynamic |
| System Integration | 4/10 | Critical gaps — no deep links, no Spotlight, no notifications |

**Overall: 6.3/10**

---

## CRITICAL Issues (Must Fix)

### 1. No Privacy Manifest (PrivacyInfo.xcprivacy)
- **Impact:** App Store rejection (required since iOS 17.1)
- **Fix:** Create PrivacyInfo.xcprivacy declaring API usage and data practices

### 2. No Deep Link Handling
- **Impact:** Widget taps (`geografy://home`) do nothing
- **Fix:** Add `.onOpenURL()` handler + register URL scheme in Info.plist

### 3. No App Store Review Prompt
- **Impact:** Missing user engagement opportunity
- **Fix:** Add `SKStoreReviewController.requestReview()` after milestones

### 4. tvOS: No Reduce Motion Support
- **Impact:** Accessibility violation — mandatory for App Store
- **Fix:** Add `@Environment(\.accessibilityReduceMotion)` to all 37 tvOS view files

### 5. tvOS: No Menu Button Handling on 20+ Screens
- **Impact:** Users stuck on screens with no back navigation
- **Fix:** Add `.onExitCommand` to all tvOS screens

### 6. Game Dismiss Without Confirmation
- **Impact:** `.interactiveDismissDisabled(true)` prevents escape without dialog
- **Fix:** Add confirmation alert before dismissing game sessions

---

## HIGH Priority Issues

### iOS

| # | Issue | Files | Fix |
|---|-------|-------|-----|
| 1 | Missing VoiceOver labels on some buttons | HomeScreen (friendsButton, editSectionsButton, carousel) | Add `.accessibilityLabel()` |
| 2 | No ShareLink implementation | None found | Add ShareLink to achievements, results, country cards |
| 3 | No Spotlight indexing | None found | Add CSSearchableItem for 197 countries |
| 4 | Hardcoded frame heights fail on rotation | OrganizationDetailScreen:343 | Use flexible layout |
| 5 | No high contrast mode support | Global | Check `accessibilityHighContrast` environment |
| 6 | Opacity-based colors may fail WCAG AA | CountryRowView:276, HomeScreen:327 | Verify contrast ratios |
| 7 | No App Intents / Siri Shortcuts | None found | Create OpenGeografyIntent, StartQuizIntent |
| 8 | No push notifications | None found | Add daily streak reminders, challenge alerts |

### tvOS

| # | Issue | Files | Fix |
|---|-------|-------|-----|
| 1 | Text below 29pt minimum (18pt found) | OceanScreen:46, LanguageScreen:32, ToolsScreen | Increase to 29pt+ |
| 2 | No haptic feedback on most interactions | 20+ screens | Extend ControllerHaptics to all screens |
| 3 | Missing focus visual feedback (scale/glow) | CountryBrowserScreen, all List screens | Add focus ring, scaleEffect on focus |
| 4 | No parallax on focusable cards | All card grids | Add `.hoverEffect()` or custom parallax |
| 5 | Incomplete VoiceOver labels | TravelScreen:84, LanguageScreen:26, OceanScreen:27 | Add labels to all rows |
| 6 | No idle timeout handling | MultiplayerQuizScreen | Add inactivity detection |
| 7 | No Top Shelf extension | App level | Create Top Shelf with featured countries |

### iPadOS

| # | Issue | Files | Fix |
|---|-------|-------|-----|
| 1 | No pointer hover effects | Global (0 `.onHover` found) | Add hover to all buttons/cards |
| 2 | No keyboard navigation | Global (no `.focusable()` in iOS) | Add Tab/arrow key support |
| 3 | No NavigationSplitView | CountryList, Organizations | Add master-detail on iPad landscape |
| 4 | No popover support | All sheets | Use `.presentationCompactAdaptation(.popover)` |
| 5 | No drag & drop | Global | Add `.onDrag()` to country cards |
| 6 | Static grid columns | AdaptiveLayout:35 | Calculate based on available width |

### macOS Catalyst

| # | Issue | Files | Fix |
|---|-------|-------|-----|
| 1 | No standard menus (File, Edit, Help) | GeografyApp.swift | Add CommandGroup replacements |
| 2 | No Preferences (Cmd+,) | GeografyApp.swift | Add Settings command |
| 3 | No window size constraints | GeografyApp.swift | Add `.windowMinimumSize()` |
| 4 | No tooltips on buttons | Global (0 `.help()` found) | Add tooltips to toolbar items |
| 5 | Only 6 keyboard shortcuts | GeografyApp.swift | Add Cmd+F, Cmd+S, Escape |
| 6 | No keyboard focus rings | Global | Add visible focus indicators |

---

## MEDIUM Priority (Polish)

| Platform | Issue | Fix |
|----------|-------|-----|
| iOS | Drag indicator missing on some sheets | Add `.presentationCornerRadius()` |
| iOS | GlassButton doesn't use accent for primary | Use `.accentColor` for primary actions |
| iOS | No background tasks (BGTask) | Schedule widget refresh |
| tvOS | Inconsistent body text sizes (18-22pt mix) | Standardize to 22pt minimum |
| tvOS | No content skeleton while loading | Add placeholder cards |
| tvOS | No focus restoration through navigation | Preserve focus state on back |
| iPadOS | Carousel width fixed on wide screens | Adapt to available width |
| iPadOS | No Slide Over support declared | Add window resizability |
| macOS | No multi-window support | Enable `.supportsMultipleWindows` |
| macOS | Notification-based tab switching fragile | Use state management instead |
| All | No Handoff support | Add NSUserActivity for country browsing |

---

## LOW Priority (Nice to Have)

| Platform | Issue |
|----------|-------|
| iOS | Missing `.sceneStorage` for multi-window state |
| tvOS | No content rating system |
| tvOS | No result sharing capability |
| iPadOS | No custom sidebar sections/disclosures |
| macOS | No Touch Bar support |
| macOS | No native macOS scaling verification |
| Widgets | Missing `systemExtraLarge` widget size |
| All | No custom notification sounds |

---

## What's Done WELL

### iOS (Excellent)
- Design system with centralized tokens (DesignSystem enum)
- Dark mode fully supported via asset catalog
- 242 VoiceOver accessibility labels
- Reduce Motion respected in 10+ components
- Reduce Transparency fallbacks for materials
- Native `.searchable()` on all search screens
- `ContentUnavailableView` for empty states
- `.symbolEffect()` on interactive elements
- Haptic feedback (133 instances)
- Rich context menus on country rows
- `.readableContentWidth()` used 78 times
- Glass effects (`.glassEffect`, `.buttonStyle(.glass)`)
- Dynamic Type via native text styles

### tvOS (Strong)
- Excellent game controller support (L1/R1/L2/R2 mapping)
- Comprehensive haptic engine (tap, correct, wrong, celebration)
- Per-controller light color support
- Dark backgrounds (tvOS standard)
- Focus sections on HomeScreen
- `.focusable()` and `@FocusState` on key screens

### Widgets (Excellent)
- 3 widgets covering all major sizes + Lock Screen
- Proper TimelineProvider with midnight refresh
- Glanceable content (emoji flags, large numbers)
- Deep link URLs on all widgets
- `AccessoryWidgetBackground()` on Lock Screen
- `containerBackground(for: .widget)` correctly used
- Dynamic data via App Group UserDefaults

### StoreKit 2 (Excellent)
- Modern async/await purchase flow
- Transaction verification
- Auto-renewable + lifetime subscriptions
- Restore purchases via `AppStore.sync()`

### Game Center (Good)
- Leaderboards and achievements
- Offline submission queue
- Friends list with authorization check

---

## Implementation Roadmap

### Phase 1: App Store Blockers (1-2 days)
1. Create PrivacyInfo.xcprivacy
2. Implement `.onOpenURL()` deep link handler
3. Register URL scheme in Info.plist
4. Add `SKStoreReviewController.requestReview()`
5. Add game dismiss confirmation dialogs

### Phase 2: tvOS Accessibility (2-3 days)
1. Add `reduceMotion` to all 37 tvOS files
2. Add `.onExitCommand` to all tvOS screens
3. Increase minimum text to 29pt
4. Add VoiceOver labels to all interactive rows
5. Add haptic feedback to non-quiz screens

### Phase 3: iPad Keyboard & Pointer (3-4 days)
1. Add `.onHover()` to all buttons and cards
2. Add keyboard navigation (Tab, arrows, Enter, Escape)
3. Add standard keyboard shortcuts (Cmd+F, Cmd+,)
4. Add `.focusable()` to all interactive elements
5. Add visible focus indicators

### Phase 4: macOS Polish (2-3 days)
1. Add standard menus (File, Edit, Help, Preferences)
2. Add window size constraints
3. Add tooltips on toolbar items
4. Add pointer cursor changes

### Phase 5: System Integration (3-4 days)
1. Implement Spotlight indexing for countries
2. Create basic App Intents (Open, Start Quiz)
3. Add local notifications (streak, challenge)
4. Implement background task for widget refresh

### Phase 6: iPad Layout (3-5 days)
1. Add NavigationSplitView for list→detail screens
2. Add popover support for iPad sheets
3. Implement responsive grid columns
4. Add drag & drop for country cards

### Phase 7: tvOS Polish (2-3 days)
1. Add focus visual feedback (scale, glow)
2. Add idle timeout detection
3. Create Top Shelf extension
4. Add focus restoration

**Total estimated effort: 16-24 development days**

---

## Compliance Checklist

### Mandatory (App Store Requirements)
- [ ] Privacy Manifest
- [ ] Deep link handling
- [ ] Accessibility: Reduce Motion (all platforms)
- [ ] VoiceOver labels on all interactive elements
- [ ] Minimum tap targets (44pt)

### Strongly Recommended
- [ ] App Store review prompt
- [ ] Keyboard shortcuts (macOS)
- [ ] Pointer hover effects (iPadOS/macOS)
- [ ] Standard menus (macOS)
- [ ] tvOS Menu button handling
- [ ] Window size constraints (macOS)

### Recommended
- [ ] Spotlight indexing
- [ ] App Intents / Siri Shortcuts
- [ ] Notifications
- [ ] NavigationSplitView (iPad)
- [ ] Drag & drop (iPad)
- [ ] Top Shelf (tvOS)
- [ ] Handoff support
