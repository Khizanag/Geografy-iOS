import SwiftUI
import GeografyDesign

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
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(xpService.currentLevel.level)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(xpService.currentLevel.title)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(xpService.totalXP) XP")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                ProgressView(value: xpService.progressFraction)
                    .tint(DesignSystem.Color.accent)

                Text("\(xpService.xpRequiredForNextLevel - xpService.xpInCurrentLevel) XP to next level")
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func achievementRow(_ achievement: AchievementDefinition) -> some View {
        let isUnlocked = achievementService.isUnlocked(achievement.id)

        return HStack(spacing: 20) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 28))
                .foregroundStyle(isUnlocked ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        isUnlocked
                            ? DesignSystem.Color.textPrimary
                            : DesignSystem.Color.textSecondary
                    )

                Text(achievement.description)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(DesignSystem.Color.success)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}
