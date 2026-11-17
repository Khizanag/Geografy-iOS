import Geografy_Core_Common
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

enum AppTab: Int, Hashable {
    case map
    case explore
    case play
    case profile
}

@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .map

    let exploreNavigator = Navigator()
    let mapNavigator = Navigator()
    let playNavigator = Navigator()
    let profileNavigator = Navigator()

    func navigator(for tab: AppTab) -> Navigator {
        switch tab {
        case .explore: exploreNavigator
        case .map: mapNavigator
        case .play: playNavigator
        case .profile: profileNavigator
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "geografy" else { return }
        switch url.host {
        case "home", "countries": selectedTab = .explore
        case "map", "maps": selectedTab = .map
        case "quiz", "play": selectedTab = .play
        case "more": selectedTab = .profile
        case "streak", "profile":
            selectedTab = .profile
            profileNavigator.push(ProfileRoute.profile)
        case "progress":
            selectedTab = .profile
            profileNavigator.push(ProfileRoute.leaderboards)
        default: break
        }
    }

    func handle(_ request: AppRequest, countries: [Country]) {
        switch request {
        case .tab(let tab):
            selectedTab = tab
        case .quiz:
            selectedTab = .play
            playNavigator.push(PlayRoute.quizSetup)
        case .dailyChallenge:
            selectedTab = .play
            playNavigator.push(PlayRoute.dailyChallenge)
        case .settings:
            selectedTab = .profile
            profileNavigator.push(ProfileRoute.settings)
        case .search:
            selectedTab = .explore
            exploreNavigator.push(CountryRoute.search)
        case .randomCountry:
            guard let country = countries.randomElement() else { return }
            selectedTab = .explore
            exploreNavigator.push(CountryRoute.countryDetail(country))
        }
    }

    #if DEBUG
    /// Launching with `-openHub <testKey>` opens that hub screen, so UI checks don't need to tap through tabs.
    func openHubItemFromLaunchArguments() {
        guard let key = UserDefaults.standard.string(forKey: "openHub"),
              let item = HubItem.allCases.first(where: { $0.testKey == key }) else { return }
        open(item)
    }

    /// Opens a hub screen on the Explore tab, on top of whatever that tab shows.
    func open(_ item: HubItem) {
        selectedTab = .explore
        exploreNavigator.push(item.destination)
    }
    #endif

    @MainActor
    func handleSpotlightActivity(_ identifier: String, countryDataService: CountryDataService) {
        guard identifier.hasPrefix("country-") else { return }
        let code = String(identifier.dropFirst("country-".count))
        guard let country = countryDataService.country(for: code) else { return }
        selectedTab = .explore
        exploreNavigator.push(CountryRoute.countryDetail(country))
    }
}
