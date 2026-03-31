import Foundation

public struct GeoJSONFeatureCollection: Codable, Sendable {
    public let type: String
    public let features: [GeoJSONFeature]

    public init(type: String, features: [GeoJSONFeature]) {
        self.type = type
        self.features = features
    }
}

public struct GeoJSONFeature: Codable, Sendable {
    public let type: String
    public let id: String?
    public let properties: [String: AnyCodableValue]
    public let geometry: GeoJSONGeometry

    public init(type: String, id: String?, properties: [String: AnyCodableValue], geometry: GeoJSONGeometry) {
        self.type = type
        self.id = id
        self.properties = properties
        self.geometry = geometry
    }
}

public struct GeoJSONGeometry: Codable, Sendable {
    public let type: String
    public let coordinates: GeoJSONCoordinates

    public init(type: String, coordinates: GeoJSONCoordinates) {
        self.type = type
        self.coordinates = coordinates
    }
}

// MARK: - GeoJSONCoordinates
public enum GeoJSONCoordinates: Codable, Sendable {
    case polygon([[[Double]]])
    case multiPolygon([[[[Double]]]])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let multi = try? container.decode([[[[Double]]]].self) {
            self = .multiPolygon(multi)
        } else {
            let polygon = try container.decode([[[Double]]].self)
            self = .polygon(polygon)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .polygon(let rings):
            try container.encode(rings)
        case .multiPolygon(let polygons):
            try container.encode(polygons)
        }
    }
}

// MARK: - AnyCodableValue
public enum AnyCodableValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    public var stringValue: String? {
        switch self {
        case .string(let value): value
        case .int(let value): String(value)
        case .double(let value): String(value)
        default: nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}
