import Geografy_Core_Common

/// What a flashcard session studies: its title, its glyph, and the kind of card it asks.
public struct FlashcardDeck: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let icon: String
    public let cardType: FlashcardType

    public init(id: String, name: String, icon: String, cardType: FlashcardType) {
        self.id = id
        self.name = name
        self.icon = icon
        self.cardType = cardType
    }
}

// MARK: - Decks
public extension FlashcardDeck {
    /// The cards a game just missed, reviewed right after it.
    static func missed(cardType: FlashcardType) -> FlashcardDeck {
        FlashcardDeck(
            id: "missed_\(cardType.rawValue)",
            name: String(localized: "Missed Answers"),
            icon: "arrow.uturn.backward.circle.fill",
            cardType: cardType
        )
    }

    /// The cards due in a region, as Flashcards' setup starts them.
    static func review(cardType: FlashcardType, region: QuizRegion) -> FlashcardDeck {
        FlashcardDeck(
            id: "review_\(cardType.rawValue)_\(region.rawValue)",
            name: String(localized: "Flashcards"),
            icon: cardType.icon,
            cardType: cardType
        )
    }
}
