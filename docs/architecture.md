# Geografy architecture

How the iOS app is put together after the 2026-11 restructure: which package owns what, how screens open each other, and where data comes from. Read this before adding a package, a screen, or a data file.

## Packages

Eleven local Swift packages. Core packages hold what more than one feature needs; each feature package owns one tab's or one domain's screens.

| Package | Owns |
|---|---|
| `Core-Common` | Models (`Country`, `Organization`, quiz and achievement models), static data tables, `MapProjection`, `UserScope` |
| `Core-DesignSystem` | Tokens and generic components; no services |
| `Core-Navigation` | `Navigator`, `CoordinatedNavigationStack`, `Route`, `RouteRegistry`, and each feature's public route enum |
| `Core-Service` | App services (`CountryDataService`, `TravelService`, `XPService`, …) and the few views several features show: `CountryRowView`, the country context menu, `SpeakerButton`, `TravelStatusPickerSheet` |
| `Core-Map` | The map engine: `MapCanvasView`, `MapState`, `MapViewport`, graticule, labels, continent outlines and tiles, `WorldMapThumbnail` |
| `Feature-Map` | Map tab: world and continent maps, continents grid, map colors, organization maps |
| `Feature-Country` | Explore's country list, Country detail, Compare, neighbors, Search, Saved (favorites, want to visit, collections) |
| `Feature-Play` | Quizzes, Quiz Library, Daily Challenge, flashcards, Learning Path, Map Puzzle and Pin Drop, Word Search, local multiplayer |
| `Feature-Discover` | World Facts, Timeline and the historical map, Organizations, Time Zones, Currency Converter, Distance Calculator |
| `Feature-Profile` | Profile, Achievements, Leaderboards, Game Center, sign-in, Settings |
| `Feature-Travel` | Travel tracker, travel journal, travel map |

Rules:

- A feature package depends only on core packages, never on another feature.
- A view that two features need goes to `Core-Service` when it reads services, and to `Core-DesignSystem` when it doesn't.
- New package folders go into both `membershipExceptions` lists in `project.pbxproj`. Without them the app target copies the whole folder, `.build` included, into the bundle.

## Navigation

Every screen another screen can open is a `Route`.

- Each feature declares a public route enum in `Core-Navigation/Route/` for the screens other features open: `MapRoute`, `CountryRoute`, `PlayRoute`, `DiscoverRoute`, `ProfileRoute`, and `TravelRoute`.
- Screens only the feature itself opens use an internal `<Feature>LocalRoute` in that package.
- Each feature registers the screens for both enums in its `<Feature>Screens.swift` (`registerCountryScreens()`, …). The app calls all six once, in `GeografyApp.routes`.
- Open a screen with `coordinator.push(CountryRoute.countryDetail(country))`, `.sheet(_:)`, or `.cover(_:)`. Sheets and covers get their own navigation stack and close button.

Adding a screen: add a case to the feature's route enum, public or local, and a line to its registration. Nothing else changes.

### Push or present

- Push a route for a screen that's part of the flow you're in.
- Present a route as a sheet for a self-contained task that returns to where it started, and as a cover for a game session.
- A local `.sheet` with a binding is fine for an editor or picker that belongs to one screen and edits that screen's state. Anything another screen might open is a route.

## Services

`AppDependencies` creates every service once, in dependency order, and `.environment(_:)` with an `AppDependencies` puts all of them into the environment. Screens read services with `@Environment(Service.self)`. Don't create a service inside a view or another service. Pass the shared instance in.

## Data

Each fact has one source:

| Data | Source |
|---|---|
| Countries: names, capitals, capital coordinates, area, population, economy | `Geografy/Resource/countries.json`, read by `CountryDataService` |
| Places on the map that aren't countries (Greenland, Western Sahara) | `MapTerritory` in `Core-Common` |
| Country shapes | `Geografy/Resource/countries.geojson`, read by `GeoJSONCache` |
| Fun facts | `CountryFunFacts` in `Feature-Country` |
| Deep-dive sections for 20 countries | `Geografy/Resource/country_profiles.json` |
| Historical events | `Geografy/Resource/historical_events.json` |

Tables only one feature reads live in that feature's package, not in `Core-Common`.
