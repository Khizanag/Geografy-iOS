import Foundation

struct FlashcardGuideSection: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let items: [String]
}

struct FlashcardGuideTip: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}

enum FlashcardGuide {
    static let sections: [FlashcardGuideSection] = [
        FlashcardGuideSection(
            icon: "rectangle.on.rectangle.angled",
            title: "How Flashcards Work",
            items: [
                "Each card has a question on the front and an answer on the back",
                "Tap the card to flip and reveal the answer",
                "Rate how well you knew the answer to schedule future reviews",
            ]
        ),
        FlashcardGuideSection(
            icon: "square.stack.fill",
            title: "Card Types",
            items: [
                "Country → Capital: See the country, guess its capital city",
                "Flag → Country: See the flag, name the country",
                "Capital → Country: See the capital, name the country",
                "Country → Flag: See the country name, recall its flag",
            ]
        ),
        FlashcardGuideSection(
            icon: "globe.americas.fill",
            title: "Decks",
            items: [
                "Cards are organized by continent for focused study",
                "Each deck contains up to 20 cards per session",
                "Complete all continents to master world geography",
            ]
        ),
        FlashcardGuideSection(
            icon: "clock.arrow.circlepath",
            title: "Spaced Repetition",
            items: [
                "Cards you struggle with appear more frequently",
                "Cards you know well are shown less often",
                "Review due cards daily for the best retention",
            ]
        ),
        FlashcardGuideSection(
            icon: "star.fill",
            title: "Difficulty Ratings",
            items: [
                "Easy — You knew it instantly (next review in 4 days)",
                "Good — You recalled it with some thought (next in 2 days)",
                "Hard — You barely remembered (next review tomorrow)",
                "Again — You didn't know it (review again this session)",
            ]
        ),
    ]

    static let tips: [FlashcardGuideTip] = [
        FlashcardGuideTip(emoji: "🔥", text: "Study daily to build a streak"),
        FlashcardGuideTip(emoji: "🎯", text: "Focus on due cards first for best results"),
        FlashcardGuideTip(emoji: "🧠", text: "Be honest with ratings — it helps the algorithm"),
        FlashcardGuideTip(emoji: "🌍", text: "Try different card types to strengthen different skills"),
    ]
}
