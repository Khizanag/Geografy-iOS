# Geografy iOS — TODO

## In Progress
- [ ] Continent filter from All Maps page (open only filtered countries)

## Map
- [ ] Label placement algorithm — labels overlap or appear outside country bounds (e.g., UAE)
- [ ] Small countries missing on map (Bahrain visible but very tiny)
- [ ] Physical map type (terrain/elevation)

## Data
- [ ] Orientation locking — picker works visually but needs AppDelegate integration
- [ ] Language/Localization support
- [ ] Game Center integration

## UI/UX
- [ ] Flag preview on map toast — improve blur overlay
- [ ] Country Detail page — needs full redesign with charts (population, GDP trends)
- [ ] Home screen carousel — replace SF Symbols with actual map preview images

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
- [ ] Add SwiftLint configuration
