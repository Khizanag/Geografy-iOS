import Geografy_Core_Common

/// Screens of the Country feature that other features open.
public enum CountryRoute: Route {
    case countries
    case countryDetail(Country)
    case compare(preselectedCountry: Country? = nil)
    case saved(SavedTab)
    case search
}
