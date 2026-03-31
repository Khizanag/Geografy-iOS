import SwiftUI

@Observable
final class Navigator {
    var path = NavigationPath()
    var activeSheet: Destination?
    var activeCover: Destination?

    func push(_ destination: Destination) {
        path.append(destination)
    }

    func sheet(_ destination: Destination) {
        activeSheet = destination
    }

    func cover(_ destination: Destination) {
        activeCover = destination
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func dismiss() {
        if activeCover != nil {
            activeCover = nil
        } else {
            activeSheet = nil
        }
    }
}
