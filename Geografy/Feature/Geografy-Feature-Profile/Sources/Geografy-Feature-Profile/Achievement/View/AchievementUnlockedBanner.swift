import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct AchievementUnlockedBanner: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

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
            .offset(y: reduceMotion ? 0 : slideOffset)
            .onAppear {
                hapticsService.impact(.light)
                withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7)) {
                    slideOffset = 0
                }
                let announcement = "Achievement unlocked: \(achievement.title). Plus \(achievement.xpReward) XP."
                AccessibilityNotification.Announcement(announcement).post()
                Task {
                    // VoiceOver needs time to finish the announcement before the banner leaves.
                    try? await Task.sleep(for: .seconds(voiceOverEnabled ? 6 : 3))
                    dismiss()
                }
            }
    }
}

// MARK: - Subviews
private extension AchievementUnlockedBanner {
    var bannerContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge(achievement.iconName, color: categoryColor, size: .medium)
                .accessibilityHidden(true)
            textContent
            Spacer()
            xpBadge
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(
            cornerRadius: DesignSystem.CornerRadius.large,
            style: .continuous
        ))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .strokeBorder(categoryColor.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
        .onTapGesture {
            dismiss()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Dismisses the banner")
        .accessibilityAction { dismiss() }
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
        guard !reduceMotion else {
            onDismiss()
            return
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            slideOffset = -160
        }
        Task {
            try? await Task.sleep(for: .milliseconds(380))
            onDismiss()
        }
    }
}
