import Geografy_Core_Navigation
import SwiftUI

public extension RouteRegistry {
    /// Registers the screens of the Map feature's routes.
    mutating func registerMapScreens() {
        register(MapRoute.self) { route in
            switch route {
            case .continents: ContinentsScreen()
            case .continentOverview(let continent): ContinentOverviewScreen(continent: continent)
            case .map(let continent): MapScreen(continentFilter: continent?.displayName)
            case .mapColors: MapColorsScreen()
            case .organizationMap(let organization): OrganizationMapScreen(organization: organization)
            }
        }
    }
}
