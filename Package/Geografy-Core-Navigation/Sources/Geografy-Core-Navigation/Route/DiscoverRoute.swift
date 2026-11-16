import Geografy_Core_Common

/// Screens of the Discover feature that other features open.
public enum DiscoverRoute: Route {
    case currencyConverter(preselectedCode: String? = nil)
    case distanceCalculator
    case organizationDetail(Organization)
    case organizations
    case timeline
    case timeZones
    case worldFacts(WorldFactsTopic)
}
