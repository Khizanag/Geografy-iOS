import SwiftUI

struct FlashcardStatsView: View {
    let cardsReviewed: Int
    let correctCount: Int
    let totalCards: Int
    let averageThinkingTime: TimeInterval

    var body: some View {
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
            statItem(
                value: "\(cardsReviewed)",
                label: "Reviewed",
                icon: "rectangle.on.rectangle",
                color: DesignSystem.Color.accent
            )
            statItem(
                value: "\(correctCount)",
                label: "Correct",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success
            )
            statItem(
                value: "\(accuracyPercentage)%",
                label: "Accuracy",
                icon: "chart.bar.fill",
                color: DesignSystem.Color.indigo
            )
            statItem(
                value: formattedThinkingTime,
                label: "Avg. Think Time",
                icon: "brain.fill",
                color: DesignSystem.Color.purple
            )
        }
    }

    func statItem(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
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
