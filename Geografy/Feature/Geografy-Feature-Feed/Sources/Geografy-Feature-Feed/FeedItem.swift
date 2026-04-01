import SwiftUI

public struct FeedItem: Identifiable {
    public let id: String
    public let type: ItemType
    public let title: String
    public let body: String
    public let countryCode: String?
    public let icon: String
    public let color: Color

    enum ItemType: String {
        case fact
        case record
        case didYouKnow
        case funFact

        var label: String {
            switch self {
            case .fact: "Fact"
            case .record: "Record"
            case .didYouKnow: "Did You Know?"
            case .funFact: "Fun Fact"
            }
        }
    }
}
