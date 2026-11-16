import SwiftUI

/// Draws every route: each feature registers the screens for its own route types, and the app hands the filled
/// registry to every navigation stack through the environment.
public struct RouteRegistry: Sendable {
    // MARK: - Properties
    private var screens: [ObjectIdentifier: @MainActor @Sendable (AnyHashable) -> AnyView] = [:]

    // MARK: - Init
    public init() {}

    // MARK: - Registration
    public mutating func register<R: Route, Screen: View>(
        _ type: R.Type,
        @ViewBuilder screen: @escaping @MainActor @Sendable (R) -> Screen
    ) {
        screens[ObjectIdentifier(type)] = { value in
            guard let route = value.base as? R else { return AnyView(EmptyView()) }
            return AnyView(screen(route))
        }
    }

    // MARK: - Lookup
    public func isRegistered(_ destination: Destination) -> Bool {
        screens[Self.key(for: destination)] != nil
    }

    @MainActor
    public func screen(for destination: Destination) -> AnyView {
        guard let screen = screens[Self.key(for: destination)] else {
            assertionFailure("No screen is registered for \(destination.route.base)")
            return AnyView(EmptyView())
        }
        return screen(destination.route)
    }
}

// MARK: - Helpers
private extension RouteRegistry {
    static func key(for destination: Destination) -> ObjectIdentifier {
        ObjectIdentifier(type(of: destination.route.base))
    }
}

// MARK: - Environment
public extension EnvironmentValues {
    @Entry var routes = RouteRegistry()
}
