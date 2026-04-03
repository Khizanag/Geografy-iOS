import SwiftUI

public struct FlashcardDeck: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let icon: String
    public let continentFilter: Country.Continent?
    public let cardType: FlashcardType
    public let gradientColors: (Color, Color)

    public init(
        id: String,
        name: String,
        icon: String,
        continentFilter: Country.Continent?,
        cardType: FlashcardType,
        gradientColors: (Color, Color)
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.continentFilter = continentFilter
        self.cardType = cardType
        self.gradientColors = gradientColors
    }

    public static func == (lhs: FlashcardDeck, rhs: FlashcardDeck) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Predefined Decks
public extension FlashcardDeck {
    static func makeContinentDecks(cardType: FlashcardType) -> [FlashcardDeck] {
        [
            makeAllCountriesDeck(cardType: cardType),
            FlashcardDeck(
                id: "europe_\(cardType.rawValue)",
                name: "Europe",
                icon: Country.Continent.europe.icon,
                continentFilter: .europe,
                cardType: cardType,
                gradientColors: (Color(hex: "1B5E20"), Color(hex: "388E3C")),
            ),
            FlashcardDeck(
                id: "asia_\(cardType.rawValue)",
                name: "Asia",
                icon: Country.Continent.asia.icon,
                continentFilter: .asia,
                cardType: cardType,
                gradientColors: (Color(hex: "B71C1C"), Color(hex: "D32F2F")),
            ),
            FlashcardDeck(
                id: "africa_\(cardType.rawValue)",
                name: "Africa",
                icon: Country.Continent.africa.icon,
                continentFilter: .africa,
                cardType: cardType,
                gradientColors: (Color(hex: "E65100"), Color(hex: "FF8F00")),
            ),
            FlashcardDeck(
                id: "northAmerica_\(cardType.rawValue)",
                name: "N. America",
                icon: Country.Continent.northAmerica.icon,
                continentFilter: .northAmerica,
                cardType: cardType,
                gradientColors: (Color(hex: "004D40"), Color(hex: "00695C")),
            ),
            FlashcardDeck(
                id: "southAmerica_\(cardType.rawValue)",
                name: "S. America",
                icon: Country.Continent.southAmerica.icon,
                continentFilter: .southAmerica,
                cardType: cardType,
                gradientColors: (Color(hex: "33691E"), Color(hex: "558B2F")),
            ),
            FlashcardDeck(
                id: "oceania_\(cardType.rawValue)",
                name: "Oceania",
                icon: Country.Continent.oceania.icon,
                continentFilter: .oceania,
                cardType: cardType,
                gradientColors: (Color(hex: "01579B"), Color(hex: "0277BD")),
            ),
        ]
    }

    static func makeAllCountriesDeck(cardType: FlashcardType) -> FlashcardDeck {
        FlashcardDeck(
            id: "all_\(cardType.rawValue)",
            name: "All Countries",
            icon: "globe",
            continentFilter: nil,
            cardType: cardType,
            gradientColors: (Color(hex: "1A237E"), Color(hex: "3949AB")),
        )
    }

    static func makeDueForReviewDeck(cardType: FlashcardType) -> FlashcardDeck {
        FlashcardDeck(
            id: "due_\(cardType.rawValue)",
            name: "Due for Review",
            icon: "clock.arrow.circlepath",
            continentFilter: nil,
            cardType: cardType,
            gradientColors: (Color(hex: "6A1B9A"), Color(hex: "8E24AA")),
        )
    }
}
