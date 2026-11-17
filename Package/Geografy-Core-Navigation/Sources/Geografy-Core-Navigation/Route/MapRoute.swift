import Geografy_Core_Common

/// Screens of the Map feature that other features open.
public enum MapRoute: Route {
    case continents
    case continentOverview(Country.Continent)
    /// - Parameter focusCountryCode: A country the map zooms to and selects once it's laid out.
    case map(continentFilter: Country.Continent? = nil, focusCountryCode: String? = nil)
    case mapColors
    case organizationMap(Organization)
}
