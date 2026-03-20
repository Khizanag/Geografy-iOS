import Foundation

enum NavigationRoute: Hashable {
    case map
    case countryDetail(Country)
    case allMaps
    case achievements
    case themes
    case settings
    case quiz
}
