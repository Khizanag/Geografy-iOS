import SwiftUI

struct AchievementDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let definition: AchievementDefinition
    let isUnlocked: Bool
    let unlockedAt: Date?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Color.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        iconSection
                        infoSection
                        if isUnlocked {
                            unlockedSection
                        } else {
                            howToUnlockSection
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle(definition.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GeoCircleCloseButton { dismiss() }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension AchievementDetailSheet {
    var iconSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(isUnlocked ? 0.2 : 0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: isUnlocked ? definition.iconName : "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(isUnlocked ? categoryColor : DesignSystem.Color.textTertiary)
            }
            categoryBadge
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var categoryBadge: some View {
        Text(definition.category.displayName.uppercased())
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(categoryColor)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(categoryColor.opacity(0.15), in: Capsule())
    }

    var infoSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(definition.description)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
            xpRewardBadge
        }
    }

    var xpRewardBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(.yellow)
            Text("+\(definition.xpReward) XP Reward")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var unlockedSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(DesignSystem.Color.success)
                Text("Achievement Unlocked")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            if let date = unlockedAt {
                Text("Unlocked on \(date.formatted(.dateTime.day().month(.wide).year()))")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.success.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(DesignSystem.Color.success.opacity(0.3), lineWidth: 1)
        )
    }

    var howToUnlockSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("How to Unlock")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            Text(definition.isSecret ? "This is a secret achievement. Keep exploring!" : definition.description)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var categoryColor: Color {
        switch definition.category {
        case .explorer:      DesignSystem.Color.blue
        case .quizMaster:    DesignSystem.Color.purple
        case .travelTracker: DesignSystem.Color.orange
        case .streak:        DesignSystem.Color.error
        case .knowledge:     DesignSystem.Color.ocean
        }
    }
}

// MARK: - AchievementCategory Display Name

extension AchievementCategory {
    var displayName: String {
        switch self {
        case .explorer:      "Explorer"
        case .quizMaster:    "Quiz Master"
        case .travelTracker: "Travel Tracker"
        case .streak:        "Streak"
        case .knowledge:     "Knowledge"
        }
    }
}
