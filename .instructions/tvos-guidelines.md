# tvOS Development Guidelines — Geografy

## 1. Core Principles (10-Foot UI)
- [x] Text legible at 10 feet — minimum body 29pt, titles 57pt+
- [x] Navigation hierarchy 3 levels or fewer
- [x] Content-first with minimal chrome
- [x] No small tap targets — focusable elements large and well-spaced
- [x] App feels cinematic — ambient blobs, dark theme, rich cards

## 2. Focus Engine
- [x] Every interactive element is focusable
- [x] Focus movement is predictable — grid-aligned elements
- [x] `.focusSection()` groups related elements (home feed sections)
- [x] Clear visual distinction for focused state (card lift + shadow)
- [x] Never hijack focus movement
- [x] `.focusable()` on custom views needing focus
- [x] Non-interactive elements NOT focusable (`.focusable(false)`, `.accessibilityHidden(true)`)
- [ ] Use `.defaultFocus()` for initial focus on key screens (needs testing per screen)
- [ ] Minimum 40pt spacing audit (visual check needed on device)

## 3. Typography (10-Foot)
| Role | Size | Weight |
|------|------|--------|
| Large Title | 76pt | Bold |
| Title 1 | 56pt | Bold |
| Title 2 | 43pt | Bold |
| Title 3 | 36pt | Semibold |
| Headline/Body | 26-29pt | Semibold/Regular |
| Subheadline | 22pt | Regular |
| Caption | 18-20pt | Regular |

- [x] Body text minimum 20pt+ throughout
- [x] High contrast text/background
- [x] SF Pro system font

## 4. Spacing
- [x] Content margins: 60-80pt from screen edges
- [x] Section spacing: 32-60pt between sections
- [x] Card padding: 20-28pt internal
- [x] Focus-friendly spacing between interactive elements

## 5. Siri Remote Handling
- [x] Swipe moves focus naturally
- [x] Click selects focused element
- [x] Menu button goes back at every level
- [x] `.onExitCommand` for custom dismiss (quiz, map, flag focus)
- [x] `.onMoveCommand` for directional input (map D-pad pan)
- [x] `.onPlayPauseCommand` for quiz select (map country select)
- [x] Game controller supported but never required

## 6. Visual Design
- [x] Dark theme by default
- [x] Ambient blob backgrounds (`.tv`, `.tvQuiz` presets)
- [x] `.buttonStyle(.card)` for content cards
- [x] `.buttonStyle(.bordered)` for action buttons (neutral, no cyan tint)
- [x] Full-bleed backgrounds
- [x] Colored quiz type cards (orange/blue/purple/indigo/green/gold)
- [x] Color-coded difficulty (green/amber/red)

## 7. Accessibility
- [x] `.accessibilityLabel()` on quiz type cards, difficulty cards, answer options
- [x] `.accessibilityAddTraits(.isSelected)` on selected quiz/difficulty cards
- [x] `.accessibilityHidden(true)` on decorative blobs
- [x] `.accessibilityElement(children: .combine)` on compound rows
- [x] `.accessibilityLabel()` on country detail rows ("Population: 1,400,000")
- [x] Respect `accessibilityReduceMotion` — blob animations disabled
- [ ] Full VoiceOver testing pass on device
- [ ] Respect Increase Contrast (needs audit)

## 8. App Icon
- [ ] Layered icon: 1280x768px, 2-3 layers
- [ ] Background layer fully opaque
- [ ] Foreground ~30px bleed for parallax
- [ ] Flat fallback image

## 9. Top Shelf
- [ ] Implement TVTopShelfProvider
- [ ] Show Country of the Day
- [ ] Deep link into app on tap

## 10. App Review Readiness
- [x] Works with Siri Remote only
- [x] Menu button navigates back everywhere
- [x] No alerts that trap focus
- [x] Loading states on map, quiz
- [x] No typing quiz mode on tvOS (hard mode forced to 4 options)
- [ ] Privacy manifest (PrivacyInfo.xcprivacy)

## 11. Controller Haptics
- [x] Cached CHHapticEngine per controller (no per-play allocation)
- [x] `.handles` locality for DualSense main motors
- [x] Reset handler for engine recovery
- [x] Individual haptics per player in multiplayer
- [x] Five patterns: tap, correct, wrong, timer warning, celebration

## 12. Platform-Specific Code
- [x] `#if !os(tvOS)` for iOS-only APIs (WidgetKit, haptics, gestures, Google Sign-In)
- [x] `#if os(tvOS)` for hard difficulty option count override
- [x] Shared models, services, data layer — UI layer separate
- [x] GeoJSONParser fully cross-platform (no conditional)

## 13. Screens Implemented (36 total)
| Tab | Screen | Status |
|-----|--------|--------|
| Home | TVHomeFeedView | ✅ |
| Map | TVMapScreen | ✅ |
| Countries | TVCountryBrowserScreen (grid + list toggle) | ✅ |
| | TVCountryDetailScreen | ✅ |
| | TVFlagFocusView | ✅ |
| Quiz | TVQuizSetupScreen | ✅ |
| | TVQuizSessionScreen (solo + controller) | ✅ |
| | TVMultiplayerQuizScreen (up to 4 players) | ✅ |
| Explore | TVExploreGameScreen | ✅ |
| Search | TVSearchScreen | ✅ |
| More | TVMoreScreen (hub) | ✅ |
| | TVTriviaScreen | ✅ |
| | TVCompareScreen | ✅ |
| | TVNicknamesScreen | ✅ |
| | TVLearningPathScreen | ✅ |
| | TVCultureScreen | ✅ |
| | TVLanguageScreen | ✅ |
| | TVEconomyScreen | ✅ |
| | TVNeighborScreen | ✅ |
| | TVWorldRecordsScreen | ✅ |
| | TVGeographyFeaturesScreen | ✅ |
| | TVOceanScreen | ✅ |
| | TVLandmarkScreen | ✅ |
| | TVContinentStatsScreen | ✅ |
| | TVOrganizationsScreen | ✅ |
| | TVTimelineScreen | ✅ |
| | TVIndependenceScreen | ✅ |
| | TVFeedScreen | ✅ |
| | TVQuotesScreen | ✅ |
| | TVTravelScreen | ✅ |
| | TVFavoritesScreen | ✅ |
| | TVProfileScreen | ✅ |
| | TVAchievementsScreen | ✅ |
| | TVLeaderboardScreen | ✅ |
| | TVToolsScreen | ✅ |
| | TVSettingsScreen | ✅ |

## 14. Not Ported (Gesture-Dependent)
| Feature | Reason |
|---------|--------|
| Flashcard | Swipe gestures for card flip/rating |
| Word Search | Drag to highlight words |
| Map Coloring | Touch painting on canvas |
| Map Puzzle | Drag-and-drop country shapes |
| Size Visualization | Drag map overlays |
| Spelling Bee | Heavy keyboard input |
