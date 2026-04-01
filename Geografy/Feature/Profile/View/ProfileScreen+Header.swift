#if !os(tvOS)
import GeografyDesign
import SwiftUI

// MARK: - Guest Banner
extension ProfileScreen {
    var guestBanner: some View {
        Button {
            hapticsService.impact(.medium)
            coordinator.sheet(.signIn)
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.warning.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                        .font(DesignSystem.Font.iconSmall)
                        .foregroundStyle(DesignSystem.Color.warning)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Save your progress")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Create an account — your XP & achievements will be linked")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.warning)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.warning.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .strokeBorder(DesignSystem.Color.warning.opacity(0.30), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Header
extension ProfileScreen {
    var headerSection: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                avatarWithRing
                userInfoStack
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }

    var editButton: some View {
        Button {
            hapticsService.impact(.light)
            coordinator.sheet(.editProfile)
        } label: {
            Image(systemName: "pencil")
        }
    }

    var displayName: String {
        authService.currentProfile?.displayName ?? "Explorer"
    }
}

// MARK: - Header Subviews
private extension ProfileScreen {
    var avatarWithRing: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.indigo, DesignSystem.Color.accent],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 76, height: 76)
                .opacity(0.6)

            ProfileAvatarView(name: displayName, size: 66)
                .shadow(color: DesignSystem.Color.accent.opacity(0.30), radius: 10, x: 0, y: 4)
        }
    }

    var userInfoStack: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(displayName)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            if let email = authService.currentProfile?.email {
                Text(email)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }
            HStack(spacing: DesignSystem.Spacing.xs) {
                if authService.isGuest {
                    guestPill
                } else {
                    LevelBadgeView(level: xpService.currentLevel, size: .small, animated: true)
                }
                if subscriptionService.isPremium {
                    premiumPill
                }
            }
        }
    }

    var guestPill: some View {
        Text("Guest")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.warning)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 3)
            .background(DesignSystem.Color.warning.opacity(0.15), in: Capsule())
    }

    var premiumPill: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(DesignSystem.Font.nano)
            Text("Premium")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, 3)
        .background(DesignSystem.Color.accent.opacity(0.15), in: Capsule())
    }
}
#endif
