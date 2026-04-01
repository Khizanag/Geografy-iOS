import Foundation

public struct CountryNickname: Identifiable {
    public let id: String
    public let countryCode: String
    public let nickname: String
    public let reason: String
    public let category: NicknameCategory
}

public enum NicknameCategory: String, CaseIterable {
    case nature = "Nature"
    case history = "History"
    case culture = "Culture"
    case geography = "Geography"

    public var icon: String {
        switch self {
        case .nature: "leaf.fill"
        case .history: "book.fill"
        case .culture: "music.note"
        case .geography: "mountain.2.fill"
        }
    }
}
