import Foundation

enum Screen: Hashable {
    case map(continentFilter: Country.Continent? = nil)
    case countryDetail(Country)
    case organizationDetail(Organization)
    case allMaps
    case achievements
    case themes
    case settings
    case quizSetup
}
