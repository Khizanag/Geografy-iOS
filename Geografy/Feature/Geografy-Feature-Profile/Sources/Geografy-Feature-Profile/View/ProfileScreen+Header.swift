#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Guest Banner
extension ProfileScreen {
    public var guestBanner: some View {
        Callout(
            tint: DesignSystem.Color.warning,
            action: { coordinator.push(ProfileLocalRoute.signIn) },
            content: { guestBannerLabel }
        )
    }
}

// MARK: - Header
extension ProfileScreen {
    /// The name and avatar; a tap opens Edit Profile, for guests too.
    public var headerSection: some View {
        Button {
            coordinator.push(ProfileLocalRoute.editProfile)
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    avatarWithRing
                    userInfoStack
                    Spacer()
                    RowChevron()
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Edits your name")
    }

    public var displayName: String {
        authService.currentProfile?.displayName ?? AuthService.defaultDisplayName
    }
}

// MARK: - Guest Banner Label
private extension ProfileScreen {
    var guestBannerLabel: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            IconBadge(
                "person.crop.circle.badge.exclamationmark.fill",
                color: DesignSystem.Color.warning,
                size: .medium
            )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
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
                .opacity(DesignSystem.Opacity.strong)

            ProfileAvatarView(name: displayName, size: 66)
                .geoShadow(.card)
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
                    LevelBadgeView(level: xpService.currentLevel, size: .small, animated: false)
                }
            }
        }
    }

    var guestPill: some View {
        InfoPill("Guest", style: .tinted(DesignSystem.Color.warning))
    }
}
#endif
