import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// A solo Map Puzzle's result: the score, the XP it earned, and Play Again.
struct MapPuzzleSummaryView: View {
    // MARK: - Properties
    let correctCount: Int
    let questionCount: Int
    let onPlayAgain: () -> Void
    let onDone: () -> Void

    private let gameColor = DesignSystem.Color.purple

    // MARK: - Body
    var body: some View {
        let isPassing = correctCount >= questionCount / 2
        GameResultLayout(
            title: Text(summaryTitle),
            message: Text("You got \(correctCount) out of \(questionCount) correct"),
            xpEarned: XPRules.mapPuzzle(questions: questionCount, correct: correctCount),
            primaryAction: .playAgain { onPlayAgain() },
            onDone: onDone,
            hero: {
                IconBadge(
                    isPassing ? "star.fill" : "arrow.counterclockwise",
                    color: isPassing ? DesignSystem.Color.warning : gameColor,
                    size: .hero
                )
                .accessibilityHidden(true)
            },
            stats: { summaryStats }
        )
        .onAppear {
            let announcement = "\(summaryTitle) You got \(correctCount) out of \(questionCount) correct."
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
}

// MARK: - Subviews
private extension MapPuzzleSummaryView {
    @ViewBuilder
    var summaryStats: some View {
        StatTile(
            value: "\(correctCount)",
            label: "Correct",
            icon: "checkmark.circle.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(questionCount - correctCount)",
            label: "Wrong",
            icon: "xmark.circle.fill",
            color: DesignSystem.Color.error
        )
        StatTile(
            value: "\(Int((Double(correctCount) / Double(max(questionCount, 1))) * 100))%",
            label: "Accuracy",
            icon: "chart.bar.fill",
            color: gameColor
        )
    }
}

// MARK: - Helpers
private extension MapPuzzleSummaryView {
    var summaryTitle: String {
        let fraction = Double(correctCount) / Double(max(questionCount, 1))
        return switch fraction {
        case 0.8...: "Excellent"
        case 0.6..<0.8: "Well Done"
        case 0.4..<0.6: "Good Try"
        default: "Keep Practicing"
        }
    }
}
