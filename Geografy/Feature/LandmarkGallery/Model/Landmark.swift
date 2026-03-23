import Foundation

struct Landmark: Identifiable {
    let id: String
    let name: String
    let countryCode: String
    let city: String
    let category: LandmarkCategory
    let description: String
    let yearBuilt: Int?
    let isUNESCO: Bool
    let funFact: String
    let symbolName: String
    let accentColor: String
}

enum LandmarkCategory: String, CaseIterable {
    case monument
    case nature
    case cultural
    case religious
    case modern

    var icon: String {
        switch self {
        case .monument: "building.columns.fill"
        case .nature: "leaf.fill"
        case .cultural: "theatermasks.fill"
        case .religious: "staroflife.fill"
        case .modern: "building.2.crop.circle.fill"
        }
    }

    var displayName: String {
        switch self {
        case .monument: "Monument"
        case .nature: "Nature"
        case .cultural: "Cultural"
        case .religious: "Religious"
        case .modern: "Modern"
        }
    }
}
