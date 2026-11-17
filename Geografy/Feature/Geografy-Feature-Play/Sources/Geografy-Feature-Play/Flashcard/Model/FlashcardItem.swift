import Foundation
import Geografy_Core_Common

public struct FlashcardItem: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let type: FlashcardType
    public let countryCode: String
    public let countryName: String
    public let capital: String

    public init(
        id: String,
        type: FlashcardType,
        countryCode: String,
        countryName: String,
        capital: String
    ) {
        self.id = id
        self.type = type
        self.countryCode = countryCode
        self.countryName = countryName
        self.capital = capital
    }

    public var frontText: String {
        switch type {
        case .countryToCapital: countryName
        case .flagToCountry: ""
        case .capitalToCountry: capital
        case .countryToFlag: countryName
        }
    }

    public var backText: String {
        switch type {
        case .countryToCapital: capital
        case .flagToCountry: countryName
        case .capitalToCountry: countryName
        case .countryToFlag: ""
        }
    }

    public var showsFlagOnFront: Bool {
        type == .flagToCountry
    }

    public var showsFlagOnBack: Bool {
        type == .countryToFlag
    }
}

// MARK: - Factory
public extension FlashcardItem {
    /// The card for one country and question kind, shared by flashcards and every game that asks it.
    static func id(countryCode: String, type: FlashcardType) -> String {
        "\(countryCode)_\(type.rawValue)"
    }

    static func make(from country: Country, type: FlashcardType) -> FlashcardItem {
        FlashcardItem(
            id: id(countryCode: country.code, type: type),
            type: type,
            countryCode: country.code,
            countryName: country.name,
            capital: country.capital,
        )
    }
}
