import Geografy_Core_Common
import Geografy_Core_Navigation
import SwiftUI

/// Screens only the Travel feature opens.
enum TravelLocalRoute: Route {
    case travelMap(TravelMapFilter)
}

public extension RouteRegistry {
    /// Registers the screens of the Travel feature's routes.
    mutating func registerTravelScreens() {
        register(TravelRoute.self) { route in
            switch route {
            case .travelTracker: TravelScreen()
            }
        }
        register(TravelLocalRoute.self) { route in
            switch route {
            case .travelMap(let filter): TravelMapScreen(filter: filter)
            }
        }
    }
}
