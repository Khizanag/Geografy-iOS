import SwiftUI

@Observable
final class Navigator {
    var path = NavigationPath()
    var activeSheet: Destination?
    var activeCover: Destination?

    func push(_ destination: Destination) {
        path.append(destination)
    }

    func present(_ destination: Destination) {
        switch destination.presentationStyle {
        case .push:
            push(destination)
        case .sheet:
            activeSheet = destination
        case .fullScreenCover:
            activeCover = destination
        }
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

    func dismissSheet() {
        activeSheet = nil
    }

    func dismissCover() {
        activeCover = nil
    }
}
