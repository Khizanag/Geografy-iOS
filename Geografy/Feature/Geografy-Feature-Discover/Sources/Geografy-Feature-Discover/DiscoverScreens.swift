import Geografy_Core_Navigation
import SwiftUI

/// Screens only the Discover feature opens.
enum DiscoverLocalRoute: Route {
    case historicalMap(initialYear: Int)
}

public extension RouteRegistry {
    /// Registers the screens of the Discover feature's routes.
    mutating func registerDiscoverScreens() {
        register(DiscoverRoute.self) { route in
            switch route {
            case .currencyConverter(let code): CurrencyConverterScreen(preselectedCurrencyCode: code)
            case .distanceCalculator: DistanceCalculatorScreen()
            case .organizationDetail(let organization): OrganizationDetailScreen(organization: organization)
            case .organizations: OrganizationsScreen()
            case .timeline: TimelineScreen()
            case .timeZones: TimeZoneScreen()
            case .worldFacts(let topic): WorldFactsScreen(topic: topic)
            }
        }
        register(DiscoverLocalRoute.self) { route in
            switch route {
            case .historicalMap(let year): HistoricalMapScreen(initialYear: year)
            }
        }
    }
}
