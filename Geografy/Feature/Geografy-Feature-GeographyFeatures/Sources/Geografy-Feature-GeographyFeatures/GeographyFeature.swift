import Foundation

enum GeographyFeatureType: String, CaseIterable {
    case mountain
    case river
    case desert
    case lake
    case island

    var displayName: String {
        switch self {
        case .mountain: "Mountains"
        case .river: "Rivers"
        case .desert: "Deserts"
        case .lake: "Lakes"
        case .island: "Islands"
        }
    }

    var icon: String {
        switch self {
        case .mountain: "mountain.2.fill"
        case .river: "water.waves"
        case .desert: "sun.max.fill"
        case .lake: "drop.fill"
        case .island: "globe"
        }
    }
}

struct GeographyFeature: Identifiable {
    let id: String
    let name: String
    let type: GeographyFeatureType
    let countryCode: String
    let countryCodes: [String]
    let measurement: Double
    let measurementLabel: String
    let measurementUnit: String
    let continent: String
    let description: String
    let funFact: String

    var formattedMeasurement: String {
        let number = NumberFormatter()
        number.numberStyle = .decimal
        number.maximumFractionDigits = 0
        let formatted = number.string(from: NSNumber(value: measurement)) ?? "\(Int(measurement))"
        return "\(formatted) \(measurementUnit)"
    }
}
