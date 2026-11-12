import Geografy_Core_Common
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

enum AppTab: Int, Hashable {
    case explore
    case play
    case learn
    case profile
}

@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .explore

    let exploreNavigator = Navigator()
    let playNavigator = Navigator()
    let learnNavigator = Navigator()
    let profileNavigator = Navigator()

    func navigator(for tab: AppTab) -> Navigator {
        switch tab {
        case .explore: exploreNavigator
        case .play: playNavigator
        case .learn: learnNavigator
        case .profile: profileNavigator
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "geografy" else { return }
        switch url.host {
        case "home", "countries", "maps": selectedTab = .explore
        case "quiz": selectedTab = .play
        case "more": selectedTab = .profile
        case "streak", "profile":
            selectedTab = .profile
            profileNavigator.push(.profile)
        case "progress":
            selectedTab = .profile
            profileNavigator.push(.leaderboards)
        default: break
        }
    }

    @MainActor
    func handleSpotlightActivity(_ identifier: String, countryDataService: CountryDataService) {
        guard identifier.hasPrefix("country-") else { return }
        let code = String(identifier.dropFirst("country-".count))
        guard let country = countryDataService.country(for: code) else { return }
        selectedTab = .explore
        exploreNavigator.push(.countryDetail(country))
    }
}
