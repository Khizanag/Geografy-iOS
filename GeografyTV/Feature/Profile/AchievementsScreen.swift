import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct AchievementsScreen: View {
    @Environment(AchievementService.self) private var achievementService
    @Environment(XPService.self) private var xpService

    @State private var selectedCategory: AchievementCategory?

    private var filteredAchievements: [AchievementDefinition] {
        let all = AchievementCatalog.all
        guard let selectedCategory else { return all }
        return all.filter { $0.category == selectedCategory }
    }

    var body: some View {
        List {
            Section {
                levelCard
            }

            Section {
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as AchievementCategory?)
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        Label(category.displayName, systemImage: category.iconName)
                            .tag(category as AchievementCategory?)
                    }
                }
            }

            Section {
                ForEach(filteredAchievements) { achievement in
                    achievementRow(achievement)
                }
            }
        }
        .navigationTitle("Achievements")
    }
}

// MARK: - Subviews
private extension AchievementsScreen {
    var levelCard: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text("\(xpService.currentLevel.level)")
                    .font(DesignSystem.Font.system(size: 44, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(xpService.currentLevel.title)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("\(xpService.totalXP) XP")
                    .font(DesignSystem.Font.system(size: 24, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                ProgressView(value: xpService.progressFraction)
                    .tint(DesignSystem.Color.accent)

                Text("\(xpService.xpRequiredForNextLevel - xpService.xpInCurrentLevel) XP to next level")
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func achievementRow(_ achievement: AchievementDefinition) -> some View {
        let isUnlocked = achievementService.isUnlocked(achievement.id)

        return HStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: achievement.iconName)
                .font(DesignSystem.Font.system(size: 28))
                .foregroundStyle(isUnlocked ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(achievement.title)
                    .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        isUnlocked
                            ? DesignSystem.Color.textPrimary
                            : DesignSystem.Color.textSecondary
                    )

                Text(achievement.description)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.iconMedium)
                    .foregroundStyle(DesignSystem.Color.success)
            } else {
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Font.system(size: 20))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}
