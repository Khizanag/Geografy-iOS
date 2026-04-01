# Geografy iOS — TODO

Open tasks only. Completed work is tracked in git history.

## Map
- [ ] Physical map type (terrain/elevation)
- [ ] Country-on-map quiz type (highlight country, guess name)
- [ ] Standardize all map instances into single configurable MapScreen

## Auth
- [ ] Real Google Cloud Console Client ID

## Quiz
- [ ] Country-on-map quiz
- [ ] Reorder quiz (drag countries by population/area)

## Gamification
- [ ] Game Center Friends list integration
- [ ] Leaderboard improvements

## Travel
- [ ] Travel statistics (% of world visited)

## UI/UX
- [ ] Fix flag aspect ratios across all FlagView usages
- [ ] Smooth flag transition (Map banner to full-screen preview)
- [ ] Orientation locking (needs AppDelegate)
- [ ] Language/Localization support (String Catalogs)
- [ ] iPad layout optimization

## Monetization
- [ ] Real App Store Connect product IDs
- [ ] Decide pricing model

## Technical
- [ ] Remove CountryBasicInfo (redundant with countries.json)
- [ ] Optimize Canvas rendering for 10m GeoJSON on older devices
- [ ] Add unit tests
- [ ] CI/CD pipeline

## Known Gaps
- **SubscriptionService** — StoreKit 2 products not configured; debug override active
- **Coin System** — Purchase integration not wired
- **QuizPack** — Content and differentiation from CustomQuiz unclear
