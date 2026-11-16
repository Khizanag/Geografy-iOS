import SwiftUI

/// A screen any feature can open. Each feature package declares its routes and registers the screens that draw them,
/// so adding a screen touches only the feature that owns it.
public protocol Route: Hashable {}

/// Any feature's route, so one navigation path, sheet, or cover can hold them all.
public struct Destination: Hashable, Identifiable {
    let route: AnyHashable

    public init(_ route: some Route) {
        self.route = AnyHashable(route)
    }

    public var id: AnyHashable { route }
}
