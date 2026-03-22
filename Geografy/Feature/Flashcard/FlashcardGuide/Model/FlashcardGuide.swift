import Foundation

struct FlashcardGuidePage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let illustration: Illustration
    let steps: [FlashcardGuideStep]

    enum Illustration {
        case tapToFlip
        case swipeToRate
        case ratingButtons
        case spacedRepetition
        case proTips
    }
}

struct FlashcardGuideStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

enum FlashcardGuide {
    static let pages: [FlashcardGuidePage] = [
        FlashcardGuidePage(
            title: "Tap to Flip",
            subtitle: "Each card has a question on the front. Tap anywhere on the card to reveal the answer on the back.",
            illustration: .tapToFlip,
            steps: [
                FlashcardGuideStep(
                    icon: "hand.tap.fill",
                    title: "Tap the Card",
                    description: "See a country name or flag, then tap to reveal the answer"
                ),
                FlashcardGuideStep(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Card Flips Over",
                    description: "The answer appears with a smooth flip animation"
                ),
            ]
        ),
        FlashcardGuidePage(
            title: "Swipe to Rate",
            subtitle: "After flipping, swipe the card to quickly rate your answer. Or use the buttons below.",
            illustration: .swipeToRate,
            steps: [
                FlashcardGuideStep(
                    icon: "arrow.right",
                    title: "Swipe Right — Good",
                    description: "You recalled the answer correctly"
                ),
                FlashcardGuideStep(
                    icon: "arrow.left",
                    title: "Swipe Left — Again",
                    description: "You didn't know it — review again soon"
                ),
                FlashcardGuideStep(
                    icon: "hand.draw.fill",
                    title: "Skip Before Flipping",
                    description: "Swipe left without flipping to mark as already known"
                ),
            ]
        ),
        FlashcardGuidePage(
            title: "Rate Your Answer",
            subtitle: "Use the rating buttons for precise control over when you'll see the card again.",
            illustration: .ratingButtons,
            steps: [
                FlashcardGuideStep(
                    icon: "arrow.counterclockwise",
                    title: "Again",
                    description: "Didn't know it — shows again this session"
                ),
                FlashcardGuideStep(
                    icon: "tortoise.fill",
                    title: "Hard",
                    description: "Barely remembered — review tomorrow"
                ),
                FlashcardGuideStep(
                    icon: "hand.thumbsup.fill",
                    title: "Good",
                    description: "Recalled with effort — review in 2 days"
                ),
                FlashcardGuideStep(
                    icon: "bolt.fill",
                    title: "Easy",
                    description: "Knew it instantly — review in 4 days"
                ),
            ]
        ),
        FlashcardGuidePage(
            title: "Spaced Repetition",
            subtitle: "Cards you struggle with appear more often. Cards you know are spaced further apart. This is proven to maximize long-term retention.",
            illustration: .spacedRepetition,
            steps: [
                FlashcardGuideStep(
                    icon: "clock.arrow.circlepath",
                    title: "Review Due Cards Daily",
                    description: "Check the 'Due for Review' section for cards ready to study"
                ),
                FlashcardGuideStep(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Watch Your Progress",
                    description: "Mastery percentage grows as you review consistently"
                ),
            ]
        ),
        FlashcardGuidePage(
            title: "Pro Tips",
            subtitle: "Get the most out of your flashcard sessions with these strategies.",
            illustration: .proTips,
            steps: [
                FlashcardGuideStep(
                    icon: "flame.fill",
                    title: "Study Daily",
                    description: "Even 5 minutes a day builds powerful recall over time"
                ),
                FlashcardGuideStep(
                    icon: "square.stack.fill",
                    title: "Try All Card Types",
                    description: "Each type strengthens a different aspect of geography knowledge"
                ),
                FlashcardGuideStep(
                    icon: "brain.fill",
                    title: "Be Honest With Ratings",
                    description: "Accurate self-assessment helps the algorithm serve you better"
                ),
                FlashcardGuideStep(
                    icon: "target",
                    title: "Focus on Due Cards",
                    description: "Reviewing at the right time cements memories most effectively"
                ),
            ]
        ),
    ]
}
