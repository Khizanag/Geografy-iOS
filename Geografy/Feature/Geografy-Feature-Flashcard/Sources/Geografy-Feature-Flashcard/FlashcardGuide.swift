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
    public static let pages: [GuidePage] = [
        GuidePage(
            title: "Tap to Flip",
            subtitle: "Each card has a question on the front."
                + " Tap anywhere on the card to reveal the answer on the back.",
            steps: [
                GuideStep(
                    icon: "hand.tap.fill",
                    title: "Tap the Card",
                    description: "See a country name or flag, then tap to reveal the answer"
                ),
                GuideStep(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Card Flips Over",
                    description: "The answer appears with a smooth flip animation"
                ),
            ]
        ),
        GuidePage(
            title: "Swipe to Rate",
            subtitle: "Swipe the card to quickly rate your answer."
                + " You can even swipe right before flipping if you're sure you know it!",
            steps: [
                GuideStep(
                    icon: "arrow.right",
                    title: "Swipe Right — Correct",
                    description: "You knew the answer. Swipe right even before flipping to mark as known"
                ),
                GuideStep(
                    icon: "arrow.left",
                    title: "Swipe Left — Wrong",
                    description: "You didn't know it — card comes back for review"
                ),
            ]
        ),
        GuidePage(
            title: "Rate Your Answer",
            subtitle: "Use the rating buttons for precise control over when you'll see the card again.",
            steps: [
                GuideStep(
                    icon: "xmark.circle.fill",
                    title: "Wrong",
                    description: "Didn't know it — shows again this session"
                ),
                GuideStep(
                    icon: "exclamationmark.triangle.fill",
                    title: "Struggled",
                    description: "Barely remembered — review tomorrow"
                ),
                GuideStep(
                    icon: "checkmark.circle.fill",
                    title: "Correct",
                    description: "Recalled with effort — review in 2 days"
                ),
                GuideStep(
                    icon: "bolt.circle.fill",
                    title: "Knew It",
                    description: "Knew it instantly — review in 4 days"
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
                    description: "Check the 'Due for Review' section for cards ready to study"
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
