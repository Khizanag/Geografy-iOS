import GeografyDesign
import Geografy_Core_Service
import SwiftUI

struct AchievementCard: View {
    @Environment(HapticsService.self) private var hapticsService

    let definition: AchievementDefinition
    let isUnlocked: Bool
    let unlockedAt: Date?
    let onTap: () -> Void

    var body: some View {
        Button {
            hapticsService.impact(.light)
            onTap()
        } label: {
            cardContent
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("\(definition.title), \(isUnlocked ? "unlocked" : "locked")")
        .accessibilityHint(definition.description)
    }
}

// MARK: - Subviews
private extension AchievementCard {
    var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            iconRow
            nameLabel
            descriptionLabel
            Spacer(minLength: 0)
            bottomRow
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(
                    isUnlocked ? categoryColor.opacity(0.4) : Color.white.opacity(0.06),
                    lineWidth: 1
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.48)
    }

    var iconRow: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(isUnlocked ? 0.2 : 0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: isUnlocked ? definition.iconName : "lock.fill")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(isUnlocked ? categoryColor : DesignSystem.Color.textTertiary)
            }
            Spacer()
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.success)
            }
        }
    }

    var nameLabel: some View {
        Text(definition.title)
            .font(DesignSystem.Font.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    var descriptionLabel: some View {
        Text(definition.description)
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    var bottomRow: some View {
        Text("+\(definition.xpReward) XP")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(isUnlocked ? categoryColor : DesignSystem.Color.textTertiary)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 2)
            .background(
                (isUnlocked ? categoryColor : DesignSystem.Color.textTertiary).opacity(0.12),
                in: Capsule()
            )
    }

    var categoryColor: Color {
        definition.category.themeColor
    }
}
