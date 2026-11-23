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
    /// A country the Map tab flies to once, such as home after the first run.
    var mapFocusCode: String?

    /// `mapFocusCode`, handed over only while the Map tab shows, since a hidden map can't zoom.
    var mapTabFocusCode: String? {
        selectedTab == .map ? mapFocusCode : nil
    }

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
        case .country(let code):
            guard let country = countries.first(where: { $0.code == code }) else { return }
            selectedTab = .explore
            exploreNavigator.push(CountryRoute.countryDetail(country))
        case .profile:
            selectedTab = .profile
            profileNavigator.push(ProfileRoute.profile)
        case .leaderboards:
            selectedTab = .profile
            profileNavigator.push(ProfileRoute.leaderboards)
        case .firstRunFinished(let homeCountryCode):
            mapFocusCode = homeCountryCode
            handle(.dailyChallenge, countries: countries)
        }
    }

    #if DEBUG
    /// Launching with `-openHub <testKey>` opens that hub screen, so UI checks don't need to tap through tabs;
    /// `-showOnMap <code>` opens a map with that country selected.
    func openHubItemFromLaunchArguments() {
        if let code = UserDefaults.standard.string(forKey: "showOnMap") {
            selectedTab = .explore
            exploreNavigator.push(MapRoute.map(continentFilter: nil, focusCountryCode: code))
            return
        }
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
}
