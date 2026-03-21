# Geografy iOS — TODO

## Map
- [x] Continent filter from All Maps page (open only filtered countries)
- [x] Label placement algorithm — clamp centroid to bounding box so labels stay within country bounds
- [ ] Small countries missing on map (Bahrain visible but very tiny)
- [ ] Physical map type (terrain/elevation)

## Auth
- [x] Google Sign In — ASWebAuthenticationSession + PKCE OAuth2 flow (zero external dependencies)
  - Needs real Google Cloud Console Client ID (see GoogleSignInHandler.swift setup comments)

## Data
- [ ] Orientation locking — picker works visually but needs AppDelegate integration
- [ ] Language/Localization support
- [ ] Game Center integration

## UI/UX
- [ ] Flag preview on map toast — improve blur overlay
- [ ] Country Detail page — needs full redesign with charts (population, GDP trends)
- [x] Home screen carousel — gradient card design with continent colors (replaces SF Symbols)

## Quizzes
- [ ] Quiz feature — flag quiz, capital quiz, map quiz
- [ ] Gamification — XP system, levels, achievements

## Monetization
- [ ] Decide on model (freemium + ads, subscription, one-time purchase)
- [ ] Implement in-app purchases

## Technical
- [ ] Remove CountryBasicInfo once all countries have full data in countries.json
- [ ] Performance — optimize Canvas rendering for 10m GeoJSON on older devices
- [ ] Add unit tests
- [x] SwiftLint configuration (.swiftlint.yml)
