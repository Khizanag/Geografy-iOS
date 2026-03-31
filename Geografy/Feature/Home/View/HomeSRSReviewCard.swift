import SwiftUI
import GeografyDesign

struct HomeSRSReviewCard: View {
    let dueCount: Int
    let onStartReview: () -> Void

    var body: some View {
        Button(action: onStartReview) {
            CardView {
                cardContent
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension HomeSRSReviewCard {
    var cardContent: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            iconView
            labelStack
            Spacer()
            trailingContent
        }
        .padding(DesignSystem.Spacing.md)
    }

    var iconView: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: "clock.arrow.circlepath")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(iconColor)
        }
    }

    var iconColor: Color {
        dueCount == 0 ? DesignSystem.Color.success : DesignSystem.Color.purple
    }

    var labelStack: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("Spaced Repetition")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(dueCount == 0 ? "All caught up!" : "\(dueCount) cards due today")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: dueCount)
        }
    }

    @ViewBuilder
    var trailingContent: some View {
        if dueCount > 0 {
            dueBadge
        } else {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.success)
        }
    }

    var dueBadge: some View {
        VStack(spacing: 2) {
            Text("\(dueCount)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: dueCount)
            Text("due")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.85))
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.purple)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
