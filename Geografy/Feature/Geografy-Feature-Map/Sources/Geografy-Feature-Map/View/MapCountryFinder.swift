import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// The shared country picker over every place on the map, territories included; picking one shows it on the map.
/// Present it inside `CoordinatedNavigationStack`.
struct MapCountryFinder: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService

    let shapes: [CountryShape]
    let onSelect: (CountryShape) -> Void

    // MARK: - Body
    var body: some View {
        CountryPicker("Find a Country", countries: places) { place in
            if let shape = shapes.first(where: { $0.id == place.code }) {
                onSelect(shape)
            }
        }
    }
}

// MARK: - Places
private extension MapCountryFinder {
    /// One place per shape: a country as the country list has it, or a territory as the map draws it.
    var places: [MapPlace] {
        var seen: Set<String> = []
        return shapes.compactMap { shape in
            guard seen.insert(shape.id).inserted else { return nil }
            if let country = countryDataService.country(for: shape.id) {
                return MapPlace(
                    code: country.code,
                    name: country.name,
                    capital: country.capital,
                    continent: country.continent
                )
            }
            return MapPlace(
                code: shape.id,
                name: shape.name,
                capital: MapTerritory.info(for: shape.id)?.capital ?? "",
                continent: MapPlace.continent(for: shape)
            )
        }
    }
}

// MARK: - Place
private struct MapPlace: CountryPickerPlace {
    let code: String
    let name: String
    let capital: String
    let continent: Country.Continent

    var id: String { code }

    /// The map's continent for a territory; ocean islands go to the continent they're governed or reached from.
    static func continent(for shape: CountryShape) -> Country.Continent {
        switch shape.continent {
        case "Africa": .africa
        case "Asia": .asia
        case "Europe": .europe
        case "North America": .northAmerica
        case "South America": .southAmerica
        case "Antarctica": .antarctica
        default: oceanIslands[shape.id] ?? .oceania
        }
    }

    static let oceanIslands: [String: Country.Continent] = [
        "TF": .antarctica,
        "HM": .antarctica,
        "GS": .antarctica,
        "SH": .africa,
        "IO": .asia,
    ]
}
