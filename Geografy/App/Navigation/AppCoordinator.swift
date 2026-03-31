import SwiftUI

@Observable
final class AppCoordinator {
    var selectedTab = 0

    let homeNavigator = Navigator()
    let quizNavigator = Navigator()
    let countriesNavigator = Navigator()
    let allMapsNavigator = Navigator()
    let moreNavigator = Navigator()

    func navigator(for tab: Int) -> Navigator {
        switch tab {
        case 0: homeNavigator
        case 1: quizNavigator
        case 2: countriesNavigator
        case 3: allMapsNavigator
        case 4: moreNavigator
        default: homeNavigator
        }
    }

    func switchTab(to tab: Int) {
        selectedTab = tab
    }
}
