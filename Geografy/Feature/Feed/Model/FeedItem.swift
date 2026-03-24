import SwiftUI

struct FeedItem: Identifiable {
    let id: String
    let type: ItemType
    let title: String
    let body: String
    let countryCode: String?
    let icon: String
    let color: Color

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
