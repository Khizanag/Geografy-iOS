import SwiftUI

@Observable
final class Navigator {
    var path = NavigationPath()
    var activeSheet: Sheet?
    var activeCover: Cover?

    func push(_ screen: Screen) {
        path.append(screen)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func present(_ sheet: Sheet) {
        activeSheet = sheet
    }

    func presentFullScreen(_ cover: Cover) {
        activeCover = cover
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func dismissCover() {
        activeCover = nil
    }
}
