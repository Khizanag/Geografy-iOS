import SwiftUI

@Observable
final class AppCoordinator {
    var selectedTab = 0

    let homeCoordinator = TabCoordinator()
    let quizCoordinator = TabCoordinator()
    let flashcardCoordinator = TabCoordinator()
    let allMapsCoordinator = TabCoordinator()
    let moreCoordinator = TabCoordinator()

    func coordinator(for tab: Int) -> TabCoordinator {
        switch tab {
        case 0: homeCoordinator
        case 1: quizCoordinator
        case 2: flashcardCoordinator
        case 3: allMapsCoordinator
        case 4: moreCoordinator
        default: homeCoordinator
        }
    }

    func switchTab(to tab: Int) {
        selectedTab = tab
    }
}
