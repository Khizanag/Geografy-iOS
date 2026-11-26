#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The end of a flashcard session, in the layout every game ends with.
struct FlashcardResultsView: View {
    // MARK: - Properties
    let deck: FlashcardDeck
    let cardCount: Int
    let correctCount: Int
    let averageThinkingTime: TimeInterval
    let onStudyAgain: () -> Void
    let onDone: () -> Void

    // MARK: - Body
    var body: some View {
        GameResultLayout(
            title: Text("Session Complete"),
            message: Text("\(correctCount) of \(cardCount) cards known the first time"),
            xpEarned: XPRules.flashcardSession(cardsReviewed: cardCount),
            primaryAction: GameResultAction("Study Again", systemImage: "arrow.counterclockwise", action: onStudyAgain),
            onDone: onDone,
            hero: {
                IconBadge(deck.icon, color: FlashcardStyle.color, size: .hero)
                    .accessibilityHidden(true)
            },
            stats: { stats }
        )
        .onAppear { announce() }
    }
}

// MARK: - Subviews
private extension FlashcardResultsView {
    @ViewBuilder
    var stats: some View {
        StatTile(
            value: "\(correctCount)",
            label: "Known",
            icon: "checkmark.circle.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(accuracyPercent)%",
            label: "Accuracy",
            icon: "chart.bar.fill",
            color: DesignSystem.Color.indigo
        )
        StatTile(
            value: averageThinkingTime.formatted(.number.precision(.fractionLength(1))) + "s",
            label: "Avg. Think Time",
            icon: "brain.fill",
            color: FlashcardStyle.color
        )
    }

    var accuracyPercent: Int {
        cardCount == 0 ? 0 : Int((Double(correctCount) / Double(cardCount) * 100).rounded())
    }

    func announce() {
        let message = "Session complete. \(correctCount) of \(cardCount) cards known the first time."
        AccessibilityNotification.Announcement(message).post()
    }
}
#endif
