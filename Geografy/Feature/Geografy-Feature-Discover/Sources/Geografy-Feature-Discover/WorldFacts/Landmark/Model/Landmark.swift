import Foundation

public struct Landmark: Decodable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let countryCode: String
    public let city: String
    public let category: LandmarkCategory
    public let description: String
    public let yearBuilt: Int?
    public let isUNESCO: Bool
    public let funFact: String
    public let symbolName: String
    public let accentColor: String
}

public enum LandmarkCategory: String, CaseIterable, Decodable, Sendable {
    case monument
    case nature
    case cultural
    case religious
    case modern

    public var icon: String {
        switch self {
        case .monument: "building.columns.fill"
        case .nature: "leaf.fill"
        case .cultural: "theatermasks.fill"
        case .religious: "staroflife.fill"
        case .modern: "building.2.crop.circle.fill"
        }
    }

    public var displayName: String {
        switch self {
        case .monument: "Monument"
        case .nature: "Nature"
        case .cultural: "Cultural"
        case .religious: "Religious"
        case .modern: "Modern"
        }
    }
}
