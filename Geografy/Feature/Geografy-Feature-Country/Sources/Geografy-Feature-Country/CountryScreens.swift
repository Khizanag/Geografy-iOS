import Geografy_Core_Common
import Geografy_Core_Navigation
import SwiftUI

/// Screens only the Country feature opens.
enum CountryLocalRoute: Route {
    case collectionDetail(String)
    case neighborExplorer(Country)
    case saveToCollection(countryCode: String, countryName: String)
}

public extension RouteRegistry {
    /// Registers the screens of the Country feature's routes.
    mutating func registerCountryScreens() {
        register(CountryRoute.self) { route in
            switch route {
            case .countries:
                CountryListScreen()
                    .navigationTitle("Countries")
                    .navigationBarTitleDisplayMode(.inline)
            case .countryDetail(let country): CountryDetailScreen(country: country)
            case .compare(let country): CompareScreen(preselectedCountry: country)
            case .saved(let tab): SavedScreen(tab: tab)
            case .search: SearchScreen()
            }
        }
        register(CountryLocalRoute.self) { route in
            switch route {
            case .collectionDetail(let name): CollectionDetailScreen(collectionName: name)
            case .neighborExplorer(let country): NeighborExplorerScreen(country: country)
            case let .saveToCollection(code, name): CountrySaveToCollectionSheet(countryCode: code, countryName: name)
            }
        }
    }
}
