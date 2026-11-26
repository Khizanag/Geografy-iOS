import Foundation
import Geografy_Core_DesignSystem

public enum FlashcardIllustration: Int, CaseIterable {
    case tapToFlip
    case swipeToRate
    case ratingButtons
    case spacedRepetition
    case proTips
}

public enum FlashcardGuide {
    /// Remembers whether the flashcard guide has been shown, as `.gameGuide` does for every game.
    static let id = "flashcards"

    public static let pages: [GuidePage] = [
        GuidePage(
            title: "Tap to Flip",
            subtitle: "Each card has a question on the front."
                + " Tap anywhere on the card to reveal the answer on the back.",
            steps: [
                GuideStep(
                    icon: "hand.tap.fill",
                    title: "Tap the Card",
                    description: "Think of the answer, then tap the card or Show Answer to turn it over"
                ),
                GuideStep(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Card Flips Over",
                    description: "The answer is on the back, with its pronunciation and the country's details"
                ),
            ]
        ),
        GuidePage(
            title: "Swipe to Rate",
            subtitle: "Swipe the card to quickly rate your answer."
                + " You can even swipe right before flipping if you're sure you know it.",
            steps: [
                GuideStep(
                    icon: "arrow.right",
                    title: "Swipe Right — Got It",
                    description: "Before turning it over, it counts as Knew It; after, as Correct"
                ),
                GuideStep(
                    icon: "arrow.left",
                    title: "Swipe Left — Wrong",
                    description: "You didn't know it. It comes back once at the end of the session"
                ),
            ]
        ),
        GuidePage(
            title: "Rate Your Answer",
            subtitle: "Each button shows when the card comes back after it.",
            steps: [
                GuideStep(
                    icon: "xmark.circle.fill",
                    title: "Wrong",
                    description: "Didn't know it. Shows again at the end of this session"
                ),
                GuideStep(
                    icon: "exclamationmark.triangle.fill",
                    title: "Struggled",
                    description: "Barely remembered. Comes back soonest"
                ),
                GuideStep(
                    icon: "checkmark.circle.fill",
                    title: "Correct",
                    description: "Recalled with some effort. Comes back later"
                ),
                GuideStep(
                    icon: "bolt.circle.fill",
                    title: "Knew It",
                    description: "Knew it at once. Comes back latest"
                ),
            ]
        ),
        GuidePage(
            title: "Spaced Repetition",
            subtitle: "Cards you struggle with appear more often."
                + " Cards you know are spaced further apart."
                + " This is proven to maximize long-term retention.",
            steps: [
                GuideStep(
                    icon: "clock.arrow.circlepath",
                    title: "Review Due Cards Daily",
                    description: "Open Flashcards each day; Up Next shows the cards ready to study"
                ),
                GuideStep(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Watch Your Progress",
                    description: "Mastery percentage grows as you review consistently"
                ),
            ]
        ),
        GuidePage(
            title: "Pro Tips",
            subtitle: "Get the most out of your flashcard sessions with these strategies.",
            steps: [
                GuideStep(
                    icon: "flame.fill",
                    title: "Study Daily",
                    description: "Even 5 minutes a day builds powerful recall over time"
                ),
                GuideStep(
                    icon: "square.stack.fill",
                    title: "Try All Card Types",
                    description: "Each type strengthens a different aspect of geography knowledge"
                ),
                GuideStep(
                    icon: "brain.fill",
                    title: "Be Honest With Ratings",
                    description: "Accurate self-assessment helps the algorithm serve you better"
                ),
                GuideStep(
                    icon: "target",
                    title: "Focus on Due Cards",
                    description: "Reviewing at the right time cements memories most effectively"
                ),
            ]
        ),
    ]
}
