# Geografy iOS — TODO

## Map
- [x] Continent filter from All Maps page
- [x] Label placement algorithm
- [x] High-res 10m GeoJSON borders
- [x] Endless horizontal scrolling
- [x] Disputed territories handling with per-territory settings
- [ ] Physical map type (terrain/elevation)
- [ ] Country-on-map quiz type (highlight country, guess name)
- [ ] Standardize all map instances into single configurable MapScreen

## Auth
- [x] Google Sign In (PKCE OAuth2)
- [x] Apple Sign In
- [x] Guest mode
- [ ] Real Google Cloud Console Client ID needed

## Quiz
- [x] 6 quiz types (flag, capital, reverse flag, reverse capital, population order, area order)
- [x] 3 difficulties (easy, medium with timer, hard)
- [x] Region filter
- [x] Results with score ring and answer review
- [x] XP rewards
- [ ] Country-on-map quiz
- [ ] Reorder quiz (drag countries by population/area)
- [ ] Hard mode (type answer) UI

## Gamification
- [x] XP system with 10 levels
- [x] Achievements system with categories
- [x] Daily streak tracking
- [x] Game Center integration
- [ ] Leaderboard improvements

## Travel
- [x] Travel tracker with visited/want-to-visit
- [x] Travel map with highlighted countries
- [ ] Travel statistics (% of world visited)

## UI/UX
- [x] 3D carousel with rotation effects
- [x] Glass effects (iOS 26)
- [x] PDF flag assets (255 countries)
- [x] Zoomable flag preview with blur
- [ ] Orientation locking (needs AppDelegate)
- [ ] Language/Localization support
- [ ] iPad layout optimization

## Monetization
- [x] Subscription service structure
- [x] Paywall screen
- [x] Premium badge on locked sections
- [x] Debug premium override for testing
- [ ] Real App Store Connect product IDs
- [ ] Decide pricing model

## Technical
- [x] SwiftLint configuration
- [ ] Remove CountryBasicInfo (redundant with full countries.json)
- [ ] Performance — optimize Canvas for 10m GeoJSON on older devices
- [ ] Add unit tests
- [ ] CI/CD pipeline
