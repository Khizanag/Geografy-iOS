import Foundation

struct CountryNickname: Identifiable {
    let id: String
    let countryCode: String
    let nickname: String
    let reason: String
    let category: NicknameCategory
}

enum NicknameCategory: String, CaseIterable {
    case nature = "Nature"
    case history = "History"
    case culture = "Culture"
    case geography = "Geography"

    var icon: String {
        switch self {
        case .nature: "leaf.fill"
        case .history: "book.fill"
        case .culture: "music.note"
        case .geography: "mountain.2.fill"
        }
    }
}
