import SwiftUI

@Observable
public final class Navigator {
    public var path = NavigationPath()
    public var activeSheet: Destination?
    public var activeCover: Destination?

    public init() {}

    public func push(_ route: some Route) {
        push(Destination(route))
    }

    public func push(_ destination: Destination) {
        path.append(destination)
    }

    public func sheet(_ route: some Route) {
        activeSheet = Destination(route)
    }

    public func cover(_ route: some Route) {
        cover(Destination(route))
    }

    public func cover(_ destination: Destination) {
        activeCover = destination
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func dismiss() {
        if activeCover != nil {
            activeCover = nil
        } else {
            activeSheet = nil
        }
    }
}
