# Geografy-iOS

Geography learning app — interactive maps, country facts, flags, capitals, quizzes.

## App Identity
- **Name**: Geografy
- **Bundle ID**: `com.khizanag.geografy`
- **Minimum iOS**: 26.0
- **Reference app**: StudyGe (App Store)

## Shared Guidelines
Follow all rules in `~/.claude/rules/personal-apps.md` (shared across all personal apps).

## Core Features (MVP)

### 1. Interactive World Map (PRIMARY FEATURE)
- Full-screen political map with all countries rendered in distinct colors
- Dark background (dark gray/charcoal, NOT pure black)
- Smooth pinch-to-zoom and pan with high-quality rendering at all zoom levels
- **T button** (top-right): toggles country name labels on/off
- **Back button** (top-left): returns to home
- Tap country to select → shows top banner with:
  - Country flag (small)
  - Country name
  - Capital city (with star icon)
  - "More info" button → navigates to Country Detail

### 2. Country Detail Screen
- Country name in navigation title
- 2-column grid of info cards (dark cards with icon + title + value):
  - Capital
  - Form of government
  - Area (km²)
  - Currency
  - International organizations (UN, NATO, EU, etc.)
  - Language(s) — with pie chart visualization
  - Population — with historical line chart
  - Population density
  - GDP, GDP per capita, GDP PPP — with trend charts
- Tapping an info card shows a popup/modal with:
  - The detail info
  - "Show on the map" button (where applicable — e.g., area, currency zones)
- Tapping the flag shows full-screen flag view

### 3. Home Screen
- User profile section (level, XP progress bar)
- Map carousel (swipeable cards: World map, continent maps, etc.)
  - Each card: illustration + map name + "Open map" button
- "Statistics" button
- "Play" (quiz) button — large, prominent
- Bottom tab bar: All Maps, Achievements, Themes, Settings

### 4. Settings Screen
- Account settings (profile, login)
- General settings: Notifications, Language, Theme (Auto/Light/Dark), Orientation
- Game settings: Show correct answer toggle, Hide dependent territories toggle
- Sound and vibration settings

### 5. Authentication
- Sign in with Apple
- Email/password registration and login
- Guest mode (use app without account, sync when they sign up)

## Map Implementation Notes
- Consider GeoJSON data for country boundaries
- Each country needs: unique color, boundary path, label position, tap target
- Colors should be distinct enough that neighboring countries are easily distinguishable
- Ocean/sea areas: very dark (near-black) to contrast with colorful countries
- Antarctica: dark gray, non-interactive
- Zoom levels should maintain crisp borders (vector-based, not raster)

## Data Model (Per Country)
```
Country:
  - code (ISO 3166-1 alpha-2)
  - name (localized)
  - capital
  - flag (emoji or asset)
  - area (km²)
  - population
  - populationDensity
  - currency (name + code)
  - languages ([Language])
  - formOfGovernment
  - gdp, gdpPerCapita, gdpPPP
  - organizations ([Organization])
  - continent
  - geoJSON (boundary data)
  - color (for map rendering)
```

## Design System Prefix
- All design system components use `Geo` prefix: `GeoButton`, `GeoCard`, `GeoInfoTile`, etc.

## Color Palette Direction
- Dark theme primary (matches StudyGe aesthetic)
- Primary accent: Green (similar to StudyGe's teal/green buttons)
- Background: Dark charcoal (#1C1C1E or similar)
- Cards: Slightly lighter dark (#2C2C2E)
- Map countries: Vibrant, saturated colors (purple, orange, blue, red, green, yellow, cyan, magenta)
- Text: White primary, gray secondary

## Phase Plan
1. **Phase 1 (MVP)**: Project setup, design system, interactive map with country selection, country detail screen
2. **Phase 2**: Home screen, map types carousel, settings
3. **Phase 3**: Authentication (Sign in with Apple + email)
4. **Phase 4**: Quizzes and gamification
5. **Phase 5**: Statistics, achievements, themes
6. **Phase 6**: Monetization (TBD)
