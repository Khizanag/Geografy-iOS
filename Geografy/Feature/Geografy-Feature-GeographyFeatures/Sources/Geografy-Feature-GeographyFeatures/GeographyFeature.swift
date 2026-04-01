import Foundation

public enum GeographyFeatureType: String, Sendable, CaseIterable {
    case mountain
    case river
    case desert
    case lake
    case island

    public var displayName: String {
        switch self {
        case .mountain: "Mountains"
        case .river: "Rivers"
        case .desert: "Deserts"
        case .lake: "Lakes"
        case .island: "Islands"
        }
    }

    public var icon: String {
        switch self {
        case .mountain: "mountain.2.fill"
        case .river: "water.waves"
        case .desert: "sun.max.fill"
        case .lake: "drop.fill"
        case .island: "globe"
        }
    }
}

public struct GeographyFeature: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let type: GeographyFeatureType
    public let countryCode: String
    public let countryCodes: [String]
    public let measurement: Double
    public let measurementLabel: String
    public let measurementUnit: String
    public let continent: String
    public let description: String
    public let funFact: String

    public var formattedMeasurement: String {
        let number = NumberFormatter()
        number.numberStyle = .decimal
        number.maximumFractionDigits = 0
        let formatted = number.string(from: NSNumber(value: measurement)) ?? "\(Int(measurement))"
        return "\(formatted) \(measurementUnit)"
    }
}
