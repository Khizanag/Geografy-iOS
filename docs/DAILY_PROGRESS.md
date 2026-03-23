# Daily Progress

## 2026-03-23

1. Haptics service — centralized haptic feedback gating via settings toggle
2. Religion & ethnicity data — percentage bar charts on country detail
3. World Bank statistics — GDP/population charts with live API integration
4. Typing quiz mode — fuzzy matching, hint system, 1.5× XP bonus
5. Audio pronunciation — text-to-speech for country and capital names
6. Global search — search across countries, capitals, and organizations
7. Fun facts & daily spotlight — enriched country of the day card
8. Speed Run mode — name all countries against the clock, regional variants
9. Distance Calculator — great circle distance between country capitals
10. SRS review home card — spaced repetition flashcard reminders on home
11. iOS widgets — Country of the Day, Daily Streak, World Progress widgets
12. Currency Converter — live exchange rates, 160+ currencies
13. Time Zone learning — world clock, UTC offsets, timezone quiz
14. Flag Symbolism — meaning behind flag colors and symbols
15. UNESCO Heritage Sites — world heritage sites per country
16. Country Deep Dive — full profile page with timeline and phrasebook
17. Language Phrasebook — common phrases by country
18. Continent Overview — stats dashboard per continent
19. Daily Challenge home card — quick access from home feed
20. Neighbor Explorer — discover bordering countries
21. Capital Quiz — dedicated capital city quiz mode
22. Flag Matching Game — match flags to countries
23. Geo Trivia — geography trivia questions
24. World Records Explorer — tallest, largest, deepest geography facts
25. Learning Path — guided geography curriculum
26. Map Puzzle — drag countries into correct positions
27. Landmark Quiz — identify famous landmarks
28. Geo Feed — curated geography news and facts
29. Continent Stats Dashboard — population, area, GDP by continent
30. Ocean Explorer — world's oceans and seas
31. Language Explorer — languages by region
32. Challenge Room — multiplayer-style challenge flow
33. Independence Timeline — country independence history
34. Economy Explorer — GDP, trade, development data
35. Geography Features — mountains, rivers, deserts
36. National Symbols Quiz — animals, plants, emblems
37. Map Coloring Book — interactive map coloring
38. Country Nicknames — informal country names + quiz
39. Word Search — geography word search puzzle
40. Border Challenge — guess countries by outline shape
41. Home feed polish — curated section order, personalized greeting
42. Flag ratios data — correct aspect ratios for ~190 country flags
43. Multiple capitals data — Benin and Israel supplementary capitals
44. Organizations data — 12 new orgs, membership fixes for existing
45. Country Spotlight glow — ambient gradient behind flag by continent
46. Streak-at-risk animation — pulsing flame when streak endangered
47. XP progress bar — animated fill with glow on home card
48. "NEW" badges — indicator on recently added feature cards
49. UserStatistics model — aggregated profile stats with accuracy ring
50. Weekly activity heatmap — 7-day streak visualization on profile
51. Game Center enhancements — leaderboard IDs, achievement enum
52. StoreKit 2 subscription — full purchase flow with entitlement tracking
53. Sign In with Apple — capability setup with TBC Bank team
54. Widget fix — NSExtension plist for Xcode 26 compatibility
55. Sign In page layout — responsive for iPhone 12 Mini + landscape
56. Game Center leaderboards — streak, daily challenge, flashcard wired
57. Game Center Friends — avatar list, XP rankings, rank badges
58. Distance Calculator crash fix — local CountryDataService

---

## 2026-03-22

1. Remove Geo prefix from design components
2. Unified TypeSelectionGrid component for all type selections
3. Mystery Country rules sheet — multiple fix attempts for auto-dismiss
4. GlassButton fullWidth + role — replace duplicated button patterns
5. ExploreGameRules model/view extraction
6. Coordinator pattern — AppCoordinator, TabCoordinator, Screen/Sheet/Cover enums
7. CoordinatedNavigationStack — reusable wrapper for all 5 tabs
8. Migrate all tabs to coordinator (Home, Quiz, Flashcard, AllMaps, More)
9. Remove redundant NavigationStacks from sheet-presented screens
10. Close buttons moved into individual screens
11. Tab bar background hidden for landscape
12. Countries filter menu — white icons, nested submenus, Picker style
13. Country name wrapping — 2 lines in CountryRowView
14. Country Detail flag-to-toolbar transition on scroll
15. Flashcard guide — 5-page interactive tutorial with animations
16. Flashcard swipe feedback — fly-off transitions, swipe hints
17. Flashcard thinking time tracking + selectable card count
18. Rating labels — Wrong/Struggled/Correct/Knew It
19. Pre-flip swipe right — mark as known without revealing
20. Progress bar animation — bouncy spring with glow
21. RegionSelectionBar — separate component for geographic selection
22. QuizOptionButton unification — Quiz, DailyChallenge, Multiplayer
23. Compare page — remove post-appear animation
24. Multiplayer — TypeSelectionGrid + RegionSelectionBar + footer button
25. Favorites empty state centered
