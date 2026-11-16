import Geografy_Core_Common

/// Screens of the Map feature that other features open.
public enum MapRoute: Route {
    case continents
    case continentOverview(Country.Continent)
    case map(continentFilter: Country.Continent? = nil)
    case mapColors
    case organizationMap(Organization)
}
