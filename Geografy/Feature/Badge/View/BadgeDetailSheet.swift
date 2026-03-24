import SwiftUI

struct BadgeDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    let definition: BadgeDefinition
    let isUnlocked: Bool
    let progress: BadgeProgress
    let isPinned: Bool
    let canPin: Bool
    let onTogglePin: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    badgeHeroSection
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

// MARK: - Subviews

private extension BadgeDetailSheet {
    var badgeHeroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            badgeIconLarge
            rarityBadge
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var badgeIconLarge: some View {
        ZStack {
            iconBackground

            iconBorder

            iconImage
        }
    }

    var iconBackground: some View {
        Circle()
            .fill(definition.category.themeColor.opacity(isUnlocked ? 0.2 : 0.08))
            .frame(width: 100, height: 100)
    }

    var iconBorder: some View {
        Circle()
            .strokeBorder(iconBorderGradient, lineWidth: isUnlocked ? definition.rarity.borderWidth * 1.5 : 1.5)
            .frame(width: 100, height: 100)
    }

    var iconBorderGradient: LinearGradient {
        if isUnlocked {
            definition.rarity.borderGradient
        } else {
            LinearGradient(
                colors: [DesignSystem.Color.textTertiary.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var iconImage: some View {
        Image(systemName: isUnlocked ? definition.iconName : "lock.fill")
            .font(.system(size: 44))
            .foregroundStyle(isUnlocked ? definition.category.themeColor : DesignSystem.Color.textTertiary)
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
        .background(
            definition.rarity.borderColor.opacity(0.15),
            in: Capsule()
        )
    }

    var infoSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(definition.description)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
            requirementBadge
        }
    }

    var requirementBadge: some View {
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
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    @ViewBuilder
    var statusSection: some View {
        if isUnlocked {
            unlockedStatusView
        } else {
            lockedProgressView
        }
    }

    var unlockedStatusView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(DesignSystem.Color.success)
                Text("Badge Collected")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            if let unlocked = findUnlockedBadge() {
                Text(
                    "Collected on \(unlocked.unlockedAt.formatted(.dateTime.day().month(.wide).year()))"
                )
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.success.opacity(0.1))
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(
                    DesignSystem.Color.success.opacity(0.3),
                    lineWidth: 1
                )
        )
    }

    var lockedProgressView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(definition.category.themeColor)
                Text("Progress")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            progressBarLarge
            Text(
                "\(progress.currentValue) of \(progress.targetValue) completed"
            )
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var progressBarLarge: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.pill
                )
                .fill(DesignSystem.Color.cardBackgroundHighlighted)
                .frame(height: DesignSystem.Spacing.xs)
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.pill
                )
                .fill(definition.category.themeColor)
                .frame(
                    width: geometry.size.width * progress.fraction,
                    height: DesignSystem.Spacing.xs
                )
            }
        }
        .frame(height: DesignSystem.Spacing.xs)
    }

    var pinSection: some View {
        Button {
            hapticsService.impact(.light)
            onTogglePin()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(
                    systemName: isPinned
                    ? "pin.slash.fill"
                    : "pin.fill"
                )
                Text(isPinned ? "Unpin from Showcase" : "Pin to Showcase")
                    .fontWeight(.semibold)
            }
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(
                isPinned
                ? DesignSystem.Color.error
                : DesignSystem.Color.accent
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                (isPinned
                 ? DesignSystem.Color.error
                 : DesignSystem.Color.accent
                ).opacity(0.12)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
        }
        .buttonStyle(PressButtonStyle())
        .disabled(!canPin && !isPinned)
        .opacity(!canPin && !isPinned ? 0.5 : 1.0)
    }

    var rarityIcon: String {
        switch definition.rarity {
        case .common:    "circle.fill"
        case .rare:      "diamond.fill"
        case .epic:      "star.fill"
        case .legendary: "sparkle"
        }
    }
}

// MARK: - Helpers

private extension BadgeDetailSheet {
    func findUnlockedBadge() -> UnlockedBadge? {
        guard progress.isComplete else { return nil }
        return UnlockedBadge(
            id: definition.id,
            unlockedAt: .now,
            currentValue: progress.currentValue
        )
    }
}
