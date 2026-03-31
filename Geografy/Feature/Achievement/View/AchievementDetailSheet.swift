import SwiftUI
import GeografyDesign

struct AchievementDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    let definition: AchievementDefinition
    let isUnlocked: Bool
    let progress: AchievementProgress
    let isPinned: Bool
    let canPin: Bool
    let onTogglePin: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    heroSection

                    infoSection

                    statusSection

                    if isUnlocked {
                        pinSection
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .navigationTitle(definition.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton { dismiss() }
                }
            }
            .presentationDetents([.fraction(0.65), .large])
        }
    }
}

// MARK: - Hero
private extension AchievementDetailSheet {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            iconView

            rarityBadge
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var iconView: some View {
        ZStack {
            Circle()
                .fill(definition.category.themeColor.opacity(isUnlocked ? 0.2 : 0.08))
                .frame(width: 100, height: 100)

            Circle()
                .strokeBorder(
                    isUnlocked
                        ? definition.rarity.borderGradient
                        : LinearGradient(
                            colors: [DesignSystem.Color.textTertiary.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                    lineWidth: isUnlocked ? definition.rarity.borderWidth * 1.5 : 1.5
                )
                .frame(width: 100, height: 100)

            Image(systemName: isUnlocked ? definition.iconName : "lock.fill")
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(
                    isUnlocked ? definition.category.themeColor : DesignSystem.Color.textTertiary
                )
        }
    }

    var rarityBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: rarityIcon)
                .font(DesignSystem.Font.caption2)

            Text(definition.rarity.displayName.uppercased())
                .font(DesignSystem.Font.caption2)
                .fontWeight(.bold)
        }
        .foregroundStyle(definition.rarity.borderColor)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(definition.rarity.borderColor.opacity(0.15), in: Capsule())
    }

    var rarityIcon: String {
        switch definition.rarity {
        case .common: "circle.fill"
        case .rare: "diamond.fill"
        case .epic: "star.fill"
        case .legendary: "sparkle"
        }
    }
}

// MARK: - Info
private extension AchievementDetailSheet {
    var infoSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(definition.description)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "target")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(definition.category.themeColor)

                Text(definition.requirement)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))

            if definition.xpReward > 0 {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "star.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.warning)

                    Text("+\(String(definition.xpReward)) XP")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }
            }
        }
    }
}

// MARK: - Status
private extension AchievementDetailSheet {
    @ViewBuilder
    var statusSection: some View {
        if isUnlocked {
            unlockedView
        } else {
            progressView
        }
    }

    var unlockedView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(DesignSystem.Color.success)

                Text("Unlocked")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }

            if let date = progress.unlockedAt {
                Text("Collected on \(date.formatted(.dateTime.day().month(.wide).year()))")
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

    var progressView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(definition.category.themeColor)

                Text("Progress")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }

            SessionProgressBar(progress: progress.fraction, height: 8)

            Text("\(String(progress.currentValue)) of \(String(definition.targetValue)) completed")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Pin
private extension AchievementDetailSheet {
    var pinSection: some View {
        Button {
            hapticsService.impact(.light)
            onTogglePin()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: isPinned ? "pin.slash.fill" : "pin.fill")

                Text(isPinned ? "Unpin from Showcase" : "Pin to Showcase")
                    .fontWeight(.semibold)
            }
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(isPinned ? DesignSystem.Color.error : DesignSystem.Color.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                (isPinned ? DesignSystem.Color.error : DesignSystem.Color.accent).opacity(0.12)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(PressButtonStyle())
        .disabled(!canPin && !isPinned)
        .opacity(!canPin && !isPinned ? 0.5 : 1.0)
    }
}
