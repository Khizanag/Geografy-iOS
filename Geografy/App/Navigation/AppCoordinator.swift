import SwiftUI

@Observable
final class AppCoordinator {
    var selectedTab = 0

    let homeCoordinator = Navigator()
    let quizCoordinator = Navigator()
    let countriesCoordinator = Navigator()
    let allMapsCoordinator = Navigator()
    let moreCoordinator = Navigator()

    func coordinator(for tab: Int) -> Navigator {
        switch tab {
        case 0: homeCoordinator
        case 1: quizCoordinator
        case 2: countriesCoordinator
        case 3: allMapsCoordinator
        case 4: moreCoordinator
        default: homeCoordinator
        }
    }

    func switchTab(to tab: Int) {
        selectedTab = tab
    }
}
