# Navigation Architecture Refactor

> Status: **Proposed** — pending review before implementation

## Problem

The current navigation uses a monolithic `Destination` enum (85+ cases) in `Geografy-Core-Navigation`. Every new screen requires modifying this core module. The app-level `Destination.swift` imports all ~40 feature modules to map cases to views.

## Proposed Architecture

### Core Principle

`NavigationPath` already supports heterogeneous `Hashable` types. Each feature defines its own route enum and registers its own `.navigationDestination(for:)`. Core Navigation becomes feature-agnostic.

### Layer 1: Core Navigation (feature-agnostic)

**`AnyIdentifiableView`** — type-erased view wrapper for sheets/covers:

```swift
@MainActor
public struct AnyIdentifiableView: View, Identifiable, Sendable {
    public let id: AnyHashable
    private let content: @MainActor () -> AnyView

    public init<V: View>(id: some Hashable, @ViewBuilder content: @escaping () -> V) {
        self.id = AnyHashable(id)
        self.content = { AnyView(content()) }
    }

    public var body: some View { content() }
}
```

**`Navigator`** — fully generic, no model-type dependencies:

```swift
@Observable
public final class Navigator {
    public var path = NavigationPath()
    public internal(set) var activeSheet: AnyIdentifiableView?
    public internal(set) var activeCover: AnyIdentifiableView?

    public func push(_ value: some Hashable) { path.append(value) }

    public func sheet(id: some Hashable, @ViewBuilder content: @escaping () -> some View) {
        activeSheet = AnyIdentifiableView(id: id) { content() }
    }

    public func cover(id: some Hashable, @ViewBuilder content: @escaping () -> some View) {
        activeCover = AnyIdentifiableView(id: id) { content() }
    }

    public func pop() { guard !path.isEmpty else { return }; path.removeLast() }
    public func popToRoot() { path = NavigationPath() }
    public func dismiss() {
        if activeCover != nil { activeCover = nil }
        else { activeSheet = nil }
    }
}
```

**`CoordinatedNavigationStack`** — simplified, no hardcoded destination type:

```swift
public struct CoordinatedNavigationStack<Root: View>: View {
    @Bindable public var navigator: Navigator
    public var showCloseButton: Bool
    @ViewBuilder public var root: () -> Root

    public var body: some View {
        NavigationStack(path: $navigator.path) {
            root()
        }
        .sheet(item: $navigator.activeSheet) { sheetView in
            CoordinatedNavigationStack(navigator: Navigator(), showCloseButton: true) {
                sheetView
            }
        }
        .fullScreenCover(item: $navigator.activeCover) { coverView in
            CoordinatedNavigationStack(navigator: Navigator(), showCloseButton: true) {
                coverView
            }
        }
        .environment(navigator)
    }
}
```

**Key change**: `Core-Navigation` drops its dependency on `Core-Common` entirely.

### Layer 2: Feature Self-Registration

Each feature module declares its own route type AND provides a `ViewModifier` that registers the destination resolution:

```swift
// In Geografy-Feature-Quiz
public enum QuizRoute: Hashable {
    case quizSetup
    case quizSession(QuizConfiguration)
    case speedRunSetup
    case speedRunSession(region: QuizRegion)
}

public struct QuizRouteRegistrar: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: QuizRoute.self) { route in
                switch route {
                case .quizSetup: QuizSetupScreen()
                case .quizSession(let config): QuizSessionScreen(configuration: config)
                case .speedRunSetup: SpeedRunSetupScreen()
                case .speedRunSession(let region): SpeedRunSessionScreen(region: region)
                }
            }
    }
}
```

Features push their own routes:
```swift
coordinator.push(QuizRoute.quizSetup)
```

Features present sheets directly (no registration needed):
```swift
coordinator.sheet(id: "editProfile") { EditProfileSheet() }
```

### Layer 3: Shared Routes for Cross-Feature Navigation

When Feature A needs to push a screen owned by Feature B without importing it, use lightweight shared route structs in `Core-Common`:

```swift
// In Geografy-Core-Common/Navigation/
public struct CountryRoute: Hashable {
    public let country: Country
    public init(country: Country) { self.country = country }
}

public struct PaywallRoute: Hashable { public init() {} }
public struct SignInRoute: Hashable { public init() {} }
public struct SearchRoute: Hashable { public init() {} }
```

Any feature can push these without knowing which module handles them:
```swift
coordinator.push(CountryRoute(country: neighbor))
coordinator.push(PaywallRoute())
```

The app target registers the handler:
```swift
.navigationDestination(for: CountryRoute.self) { route in
    CountryDetailScreen(country: route.country)
}
```

### Layer 4: App-Level Composition

The app chains all feature registrars:

```swift
CoordinatedNavigationStack(navigator: navigator) {
    HomeScreen()
        .modifier(QuizRouteRegistrar())
        .modifier(CountryDetailRouteRegistrar())
        .modifier(TimelineRouteRegistrar())
        .modifier(TravelRouteRegistrar())
        // shared routes
        .navigationDestination(for: CountryRoute.self) { route in
            CountryDetailScreen(country: route.country)
        }
        .navigationDestination(for: PaywallRoute.self) { _ in
            PaywallScreen()
        }
}
```

## Dependency Graph (After)

```
Core-Common  (models + shared route structs)

Core-Navigation  (Navigator, CoordinatedNavigationStack, AnyIdentifiableView)
  - NO dependency on Core-Common
  - Pure SwiftUI navigation utility

Feature-*  (each feature)
  - depends on: Core-Common, Core-Navigation, Core-DesignSystem, Core-Service
  - declares: FeatureRoute enum + FeatureRouteRegistrar modifier
  - uses: coordinator.push(FeatureRoute.xxx) for own routes
  - uses: coordinator.push(SharedRoute) for cross-feature push
  - uses: coordinator.sheet(id:content:) for sheets

App Target
  - imports all features
  - chains .modifier(FeatureRouteRegistrar()) for each feature
  - registers .navigationDestination(for: SharedRoute.self) for common routes
```

## Migration Plan

### Phase 1: Make Core-Navigation generic (non-breaking)

1. Add `AnyIdentifiableView` to Core-Navigation
2. Add generic `push(_ value: some Hashable)`, `sheet(id:content:)`, `cover(id:content:)` to Navigator alongside existing methods
3. Old `Destination`-typed methods remain temporarily

### Phase 2: Add shared routes to Core-Common

1. Create `Navigation/` folder in Core-Common
2. Add shared route structs for destinations used by 3+ features

### Phase 3: Migrate features (one at a time)

For each feature (start with leaf features that don't navigate to other features):

1. Create `FeatureRoute` enum in the feature module
2. Create `FeatureRouteRegistrar` view modifier
3. Replace `coordinator.push(.oldCase)` with `coordinator.push(FeatureRoute.newCase)`
4. Replace `coordinator.sheet(.oldCase)` with `coordinator.sheet(id:) { View() }`
5. Add `.modifier(FeatureRouteRegistrar())` to app composition
6. Remove corresponding cases from old `Destination` enum

**Suggested order** (leaf features first):
- Settings, Themes, FeatureFlags
- Quotes, WorldRecords, OceanExplorer
- Quiz, Flashcard, DailyChallenge
- CountryDetail, CountryList (last — heaviest cross-feature)

### Phase 4: Remove old Destination enum

1. Delete `Destination.swift` from Core-Navigation
2. Delete `Destination.swift` from app target
3. Remove `Core-Common` dependency from Core-Navigation's Package.swift

## Trade-offs

| Aspect | Current (monolithic enum) | Proposed (per-feature routes) |
|--------|--------------------------|-------------------------------|
| Adding a screen | Modify Core-Navigation + app Destination | Only modify the feature module |
| Compile-time safety | Exhaustive switch | Must remember to register at app level |
| Cross-feature nav | Any feature can push any case | Shared routes or closures needed |
| Core-Navigation deps | Depends on Core-Common | Zero feature dependencies |
| Sheet presentation | Centralized in Destination switch | Inline at call site |

## Risks

1. **Missing registration**: Forgetting `.modifier(FeatureRouteRegistrar())` causes silent runtime failure (push goes nowhere). Mitigate with a test that verifies all route types are registered.
2. **Cross-feature sheets**: Features cannot construct views they don't import. Use closures injected from app level or shared routes.
3. **NavigationPath + Codable**: If state restoration is needed, all route types must be `Codable` and registered with the coding system.
