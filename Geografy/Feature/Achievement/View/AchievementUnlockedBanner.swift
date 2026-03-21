import SwiftUI

struct AchievementUnlockedBanner: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var slideOffset: CGFloat = -160

    var body: some View {
        bannerContent
            .offset(y: slideOffset)
            .onAppear {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    slideOffset = 0
                }
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    dismiss()
                }
            }
    }
}

// MARK: - Subviews

private extension AchievementUnlockedBanner {
    var bannerContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            iconView
            textContent
            Spacer()
            xpBadge
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(categoryColor.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
        .onTapGesture {
            dismiss()
        }
    }

    var iconView: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.18))
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
            Image(systemName: achievement.iconName)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(categoryColor)
        }
    }

    var textContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Achievement Unlocked!")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(categoryColor)
            Text(achievement.title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var xpBadge: some View {
        Text("+\(achievement.xpReward) XP")
            .font(DesignSystem.Font.caption)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(categoryColor, in: Capsule())
    }

    var categoryColor: Color {
        switch achievement.category {
        case .explorer:      DesignSystem.Color.blue
        case .quizMaster:    DesignSystem.Color.purple
        case .travelTracker: DesignSystem.Color.orange
        case .streak:        DesignSystem.Color.error
        case .knowledge:     DesignSystem.Color.ocean
        }
    }
}

// MARK: - Actions

private extension AchievementUnlockedBanner {
    func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            slideOffset = -160
        }
        Task {
            try? await Task.sleep(for: .milliseconds(380))
            onDismiss()
        }
    }
}
