import GeografyCore
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

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "geografy" else { return }
        switch url.host {
        case "home": selectedTab = 0
        case "quiz": selectedTab = 1
        case "countries": selectedTab = 2
        case "maps": selectedTab = 3
        case "more": selectedTab = 4
        case "streak", "profile": selectedTab = 0; homeNavigator.sheet(.profile)
        case "progress": selectedTab = 0; homeNavigator.sheet(.leaderboards)
        default: break
        }
    }

    func handleSpotlightActivity(_ identifier: String) {
        guard identifier.hasPrefix("country-") else { return }
        let code = String(identifier.dropFirst("country-".count))
        let service = CountryDataService()
        service.loadCountries()
        guard let country = service.country(for: code) else { return }
        selectedTab = 0
        homeNavigator.sheet(.countryDetail(country))
    }
}
