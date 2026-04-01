import Geografy_Core_DesignSystem
import SwiftUI

public struct FlashcardStatsView: View {
    public let cardsReviewed: Int
    public let correctCount: Int
    public let totalCards: Int
    public let averageThinkingTime: TimeInterval

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            headerSection
            statsGrid
            accuracyBar
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
    }
}

// MARK: - Subviews
private extension FlashcardStatsView {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text("Session Complete")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Great work! Keep reviewing to improve mastery.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ResultStatItem(
                icon: "rectangle.on.rectangle",
                value: "\(cardsReviewed)",
                label: "Reviewed"
            )
            ResultStatItem(
                icon: "checkmark.circle.fill",
                value: "\(correctCount)",
                label: "Correct",
                color: DesignSystem.Color.success
            )
            ResultStatItem(
                icon: "chart.bar.fill",
                value: "\(accuracyPercentage)%",
                label: "Accuracy",
                color: DesignSystem.Color.indigo
            )
            ResultStatItem(
                icon: "brain.fill",
                value: formattedThinkingTime,
                label: "Avg. Think Time",
                color: DesignSystem.Color.purple
            )
        }
    }

    var accuracyBar: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("Accuracy")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    Capsule()
                        .fill(accuracyColor)
                        .frame(
                            width: geometry.size.width * accuracyFraction
                        )
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Helpers
private extension FlashcardStatsView {
    var accuracyPercentage: Int {
        guard cardsReviewed > 0 else { return 0 }
        return Int(
            (Double(correctCount) / Double(cardsReviewed) * 100).rounded()
        )
    }

    var accuracyFraction: CGFloat {
        guard cardsReviewed > 0 else { return 0 }
        return CGFloat(correctCount) / CGFloat(cardsReviewed)
    }

    var accuracyColor: Color {
        let percentage = Double(accuracyPercentage)
        if percentage >= 80 { return DesignSystem.Color.success }
        if percentage >= 50 { return DesignSystem.Color.warning }
        return DesignSystem.Color.error
    }

    var formattedThinkingTime: String {
        if averageThinkingTime < 1 {
            return "<1s"
        } else if averageThinkingTime < 60 {
            return "\(Int(averageThinkingTime.rounded()))s"
        } else {
            let minutes = Int(averageThinkingTime) / 60
            let seconds = Int(averageThinkingTime) % 60
            return "\(minutes)m \(seconds)s"
        }
    }
}
