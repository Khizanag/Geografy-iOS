import Foundation
import GeografyCore

struct FlashcardItem: Identifiable {
    let id: String
    let type: FlashcardType
    let countryCode: String
    let countryName: String
    let capital: String

    var frontText: String {
        switch type {
        case .countryToCapital: countryName
        case .flagToCountry: ""
        case .capitalToCountry: capital
        case .countryToFlag: countryName
        }
    }

    var backText: String {
        switch type {
        case .countryToCapital: capital
        case .flagToCountry: countryName
        case .capitalToCountry: countryName
        case .countryToFlag: ""
        }
    }

    var showsFlagOnFront: Bool {
        type == .flagToCountry
    }

    var showsFlagOnBack: Bool {
        type == .countryToFlag
    }
}

// MARK: - Factory
extension FlashcardItem {
    static func make(from country: Country, type: FlashcardType) -> FlashcardItem {
        FlashcardItem(
            id: "\(country.code)_\(type.rawValue)",
            type: type,
            countryCode: country.code,
            countryName: country.name,
            capital: country.capital,
        )
    }
}
