import SwiftUI

struct FlashcardDeck: Identifiable {
    let id: String
    let name: String
    let icon: String
    let continentFilter: Country.Continent?
    let cardType: FlashcardType
    let gradientColors: (Color, Color)
}

// MARK: - Predefined Decks

extension FlashcardDeck {
    static func makeContinentDecks(cardType: FlashcardType) -> [FlashcardDeck] {
        [
            makeAllCountriesDeck(cardType: cardType),
            FlashcardDeck(
                id: "europe_\(cardType.rawValue)",
                name: "Europe",
                icon: "globe.europe.africa",
                continentFilter: .europe,
                cardType: cardType,
                gradientColors: (Color(hex: "1B5E20"), Color(hex: "388E3C")),
            ),
            FlashcardDeck(
                id: "asia_\(cardType.rawValue)",
                name: "Asia",
                icon: "globe.asia.australia",
                continentFilter: .asia,
                cardType: cardType,
                gradientColors: (Color(hex: "B71C1C"), Color(hex: "D32F2F")),
            ),
            FlashcardDeck(
                id: "africa_\(cardType.rawValue)",
                name: "Africa",
                icon: "globe.europe.africa",
                continentFilter: .africa,
                cardType: cardType,
                gradientColors: (Color(hex: "E65100"), Color(hex: "FF8F00")),
            ),
            FlashcardDeck(
                id: "northAmerica_\(cardType.rawValue)",
                name: "N. America",
                icon: "globe.americas",
                continentFilter: .northAmerica,
                cardType: cardType,
                gradientColors: (Color(hex: "004D40"), Color(hex: "00695C")),
            ),
            FlashcardDeck(
                id: "southAmerica_\(cardType.rawValue)",
                name: "S. America",
                icon: "globe.americas",
                continentFilter: .southAmerica,
                cardType: cardType,
                gradientColors: (Color(hex: "33691E"), Color(hex: "558B2F")),
            ),
            FlashcardDeck(
                id: "oceania_\(cardType.rawValue)",
                name: "Oceania",
                icon: "globe.asia.australia",
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
