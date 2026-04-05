import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct AchievementUnlockedBanner: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService

    public let achievement: AchievementDefinition
    public let onDismiss: () -> Void

    @State private var slideOffset: CGFloat = -160

    // MARK: - Init
    public init(achievement: AchievementDefinition, onDismiss: @escaping () -> Void) {
        self.achievement = achievement
        self.onDismiss = onDismiss
    }

    // MARK: - Body
    public var body: some View {
        bannerContent
            .offset(y: slideOffset)
            .onAppear {
                hapticsService.impact(.light)
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
        achievement.category.themeColor
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
