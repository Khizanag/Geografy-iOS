# Geografy-iOS

Geography learning app — interactive maps, country facts, flags, capitals, quizzes, travel tracker, gamification.

## App Identity
- **Name**: Geografy
- **Bundle ID**: `com.khizanag.geografy`
- **Minimum iOS**: 26.0
- **GitHub**: Khizanag/Geografy-iOS (SSH host: github-khizanag)
- **Git author**: khizanag@gmail.com

## Shared Guidelines
Follow all rules in `~/.claude/rules/personal-apps.md` (shared across all personal apps).

## Architecture
- **UI**: SwiftUI only (UIKit only when SwiftUI can't achieve the goal)
- **Design pattern**: Views with extracted subviews. MVVM only when views become large
- **Design system**: `DesignSystem.Color`, `DesignSystem.Font`, `DesignSystem.Spacing`, `DesignSystem.Size`, `DesignSystem.CornerRadius`, `DesignSystem.IconSize`
- **Components**: `CardView`, `GeoButton`, `GeoInfoTile`, `GeoIconButton`, `GeoCircleCloseButton`, `GeoGlassButton`, `FlagView`, `PulsingCirclesView`, `ZoomableFlagView`, `PremiumBadge`, `LevelBadgeView`, `ScoreRingView`, `ProfileAvatarView`, `CountryRowView`, `SectionHeaderView`
- **Data**: 197 countries in `countries.json`, 10m GeoJSON for map borders, 255 PDF flag assets
- **Offline-first**: All data bundled, no network required

## Folder Structure
```
Geografy/
  App/                    — Entry point, ContentView, NavigationRoute
  Design/
    Theme/                — Colors, Font, Spacing, Size, CornerRadius, IconSize, Shadow
    Component/            — Reusable UI components
  Feature/
    Home/View/            — Home screen, carousel cards, quiz card, streak, world records
    Map/View/             — MapScreen, MapCanvasView, MapLoadingView, CountryBannerView
    Map/Model/            — MapState, CountryShape, MapProjection, MapColorPalette
    CountryDetail/View/   — Country detail, info popup, flag full screen
    CountryList/View/     — Searchable country list with grouping/sorting/filtering
    Quiz/Model/           — QuizType, QuizDifficulty, QuizRegion, QuizConfiguration, QuizQuestion, QuizResult
    Quiz/Engine/          — QuizEngine, QuestionGenerator
    Quiz/View/            — Setup, session, question, option button, results, score ring
    Travel/View/          — Travel tracker, travel map, travel status picker
    Auth/View/            — Sign in options
    Profile/View/         — Profile screen, edit profile
    Achievement/View/     — Achievements screen, cards, banners
    Setting/View/         — Settings, territorial disputes
    Organization/View/    — Organizations list and detail
    Favorite/View/        — Favorites screen
    Subscription/View/    — Paywall, subscription cards
    AllMap/View/          — All maps grid
    GameCenter/           — Game Center integration
  Data/
    Model/                — Country, GeoJSONModels, UserLevel, Organization, etc.
    Service/              — CountryDataService, GeoJSONParser, CountryBasicInfo, ISOCountryCodes, SubscriptionService, etc.
  Resource/
    Assets.xcassets/      — Colors, AppIcon, Flags (255 PDF imagesets)
    countries.json        — 197 countries with full data
    countries.geojson     — 10m Natural Earth borders (13MB)
  Utility/                — NumberFormatting, CGPath+Contains
```

## Component Reuse Rules (CRITICAL)
These components MUST be reused — NEVER create alternatives:
- **Close button**: Always `GeoCircleCloseButton()` — every sheet MUST have a close button in toolbar. NEVER create a custom X button
- **Flags**: Always `FlagView(countryCode:height:)` — NEVER use emoji or custom flag views
- **Cards**: Always `CardView { content }` — NEVER create custom card backgrounds
- **Press style**: Always `GeoPressButtonStyle()` for tappable cards — NEVER use plain with custom opacity
- **Glass buttons**: Use `.buttonStyle(.glass)` or `.glassEffect(.regular.interactive(), in: .circle)` — NEVER use `.ultraThinMaterial` as a substitute
- **Section headers**: Always `SectionHeaderView(title:icon:)` — accent bar (no icon) or icon style. NEVER create custom section headers
- **Menu items**: ALWAYS use `Label("Title", systemImage: "icon")` — NEVER text-only menu items
- **Profile avatar**: Always `ProfileAvatarView(name:size:)` — NEVER create custom initials/gradient circles
- **Country rows**: Always `CountryRowView(country:isFavorite:...)` — NEVER create custom country list items

## Key Conventions
- **VStack spacing over padding**: Use `VStack(spacing:)` for consistent spacing between sections — NEVER repeat `.padding(.top, X)` on every item. Prefer default spacing (omit parameter) when Apple's automatic value is appropriate — `spacing: 0` is not always correct
- **Full variable names**: Always use full names (e.g., `geometryReader` not `geo`, `index` not `idx`, `button` not `btn`)
- **Decompose for readability**: Split code into well-named functions and computed properties — keep `body` and helper views concise
- **Never disable SwiftLint**: Do NOT use `swiftlint:disable` comments. Fix the underlying issue instead — break long lines, extract methods, refactor code
- **Screen size compatibility**: Every page must work on both smallest (iPhone 12 Mini, 375pt) and largest iPhones. Use `.adaptive(minimum:)` with safe values, `Spacer(minLength: 0)`, `.lineLimit(1)`, `.minimumScaleFactor()`. Move blobs to `.background {}` — NEVER put them in a ZStack with content (they expand layout width)
- **Folder names**: Always singular (Feature, Model, View, Service — NOT plural)
- **No hardcoded values**: Colors → `DesignSystem.Color.*`, fonts → `DesignSystem.Font.*`, spacing → `DesignSystem.Spacing.*`, sizes → `DesignSystem.Size.*`
- **No SwiftUI colors directly**: No `.white`, `.black`, `.blue` — use `DesignSystem.Color.onAccent`, `.textPrimary`, `.blue` etc.
- **Asset catalog colors**: Named without prefix (e.g., "Accent", "Background" — NOT "GeoAccent")
- **Glass effects**: Use iOS 26 `.glassEffect()` and `.buttonStyle(.glass)` for interactive elements
- **Flags**: PDF vector assets in `Assets.xcassets/Flags/`, loaded via `FlagView(countryCode:height:)`
- **Map data**: Natural Earth 10m GeoJSON, parsed via `GeoJSONParser`, rendered via `MapCanvasView` Canvas
- **Disputed territories**: Configurable per-territory merge/separate in Settings
- **Trunk-based development**: Commit + push every valid increment immediately
- **Build on iPhone before commit**: Always deploy to iPhone before committing
- **Subagent auditing**: After any agent creates/modifies files, verify they use the components listed above before committing

## Current State
- Interactive world map with 258 countries, zoom/pan, country selection, capital pins
- Continent-filtered maps (Europe, Asia, Africa, etc.)
- Country detail with hero flag, quick facts, people, economy, government, currency, organizations
- Quiz mode with 6 types, 3 difficulties, region filter, timer, results with XP
- Travel tracker with visited/want-to-visit status, travel map with highlighted countries
- Countries list with search, grouping, sorting, filtering, favorites
- Authentication (Google Sign In, Apple Sign In, guest mode)
- Gamification: XP system, 10 levels, achievements, streaks
- Subscription/premium system (debug override enabled for testing)
- Settings: theme, orientation, territorial disputes, notifications, sound
- Game Center integration
