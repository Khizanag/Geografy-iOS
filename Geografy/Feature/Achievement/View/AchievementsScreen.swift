import SwiftUI

struct AchievementsScreen: View {
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) private var hapticsService

    @State private var selectedCategory: AchievementCategory?
    @State private var selectedAchievement: AchievementDefinition?
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                statsHeader

                categoryFilter

                achievementGrid
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedAchievement) { definition in
            AchievementDetailSheet(
                definition: definition,
                isUnlocked: achievementService.isUnlocked(definition.id),
                progress: achievementService.progress(for: definition.id),
                isPinned: achievementService.isPinned(definition.id),
                canPin: achievementService.canPinMore,
                onTogglePin: { achievementService.togglePin(definition.id) }
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Stats Header

private extension AchievementsScreen {
    var statsHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statPill(
                value: "\(unlockedCount)",
                label: "Unlocked",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success
            )

            statPill(
                value: "\(String(AchievementCatalog.all.count))",
                label: "Total",
                icon: "trophy.fill",
                color: DesignSystem.Color.warning
            )

            statPill(
                value: "\(pinnedCount)",
                label: "Pinned",
                icon: "pin.fill",
                color: DesignSystem.Color.accent
            )
        }
    }

    func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(color)

            Text(value)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Category Filter

private extension AchievementsScreen {
    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterChip(title: "All", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    filterChip(
                        title: category.displayName,
                        icon: category.iconName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xxs)
        }
    }

    func filterChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.caption2)

                Text(title)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Achievement Grid

private extension AchievementsScreen {
    var achievementGrid: some View {
        LazyVStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(filteredAchievements.enumerated()), id: \.element.id) { index, definition in
                achievementRow(definition)
                    .onTapGesture {
                        hapticsService.impact(.light)
                        selectedAchievement = definition
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.03),
                        value: appeared
                    )
            }
        }
    }

    func achievementRow(_ definition: AchievementDefinition) -> some View {
        let isUnlocked = achievementService.isUnlocked(definition.id)
        let progress = achievementService.progress(for: definition.id)

        return HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(definition.category.themeColor.opacity(isUnlocked ? 0.2 : 0.08))
                    .frame(width: 48, height: 48)

                Circle()
                    .strokeBorder(
                        isUnlocked ? definition.rarity.borderGradient : LinearGradient(
                            colors: [DesignSystem.Color.textTertiary.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isUnlocked ? definition.rarity.borderWidth : 1
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: isUnlocked ? definition.iconName : "lock.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        isUnlocked ? definition.category.themeColor : DesignSystem.Color.textTertiary
                    )
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(definition.title)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    if achievementService.isPinned(definition.id) {
                        Image(systemName: "pin.fill")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.accent)
                    }
                }

                Text(definition.requirement)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)

                if !isUnlocked {
                    SessionProgressBar(progress: progress.fraction, height: 4)
                }
            }

            Spacer(minLength: 0)

            Text(definition.rarity.displayName)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.bold)
                .foregroundStyle(definition.rarity.borderColor)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Helpers

private extension AchievementsScreen {
    var filteredAchievements: [AchievementDefinition] {
        let all = AchievementCatalog.all
        guard let category = selectedCategory else { return all }
        return all.filter { $0.category == category }
    }

    var unlockedCount: Int {
        AchievementCatalog.all.filter { achievementService.isUnlocked($0.id) }.count
    }

    var pinnedCount: Int {
        achievementService.pinnedIDs.count
    }
}
