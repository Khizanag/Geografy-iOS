import Foundation

public struct LandmarkQuestion: Identifiable {
    public let id: String
    public let hint: String
    public let answerCountryCode: String
    public let category: Category

    public enum Category: String, CaseIterable {
        case monument
        case nature
        case culture
        case sport

        var icon: String {
            switch self {
            case .monument: "building.columns.fill"
            case .nature: "mountain.2.fill"
            case .culture: "theatermasks.fill"
            case .sport: "sportscourt.fill"
            }
        }

        var displayName: String {
            switch self {
            case .monument: "Monument"
            case .nature: "Nature"
            case .culture: "Culture"
            case .sport: "Sport"
            }
        }
    }
}
