import SwiftUI
import GeografyDesign

struct GuestModePromptBanner: View {
    @Environment(AuthService.self) private var authService

    @AppStorage("guestBannerDismissed") private var isDismissed = false

    @State private var showSignIn = false

    var body: some View {
        if authService.isGuest, !isDismissed {
            bannerContent
                .sheet(isPresented: $showSignIn) {
                    SignInOptionsSheet()
                }
        }
    }
}

// MARK: - Subviews
private extension GuestModePromptBanner {
    var bannerContent: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Sign in to save progress")
                    .font(DesignSystem.Font.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("XP, streaks & achievements sync to your account")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer(minLength: DesignSystem.Spacing.xxs)

            HStack(spacing: DesignSystem.Spacing.xxs) {
                signInButton
                dismissButton
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .strokeBorder(DesignSystem.Color.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }

    var signInButton: some View {
        Button {
            showSignIn = true
        } label: {
            Text("Sign in")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, 6)
                .background(DesignSystem.Color.accent)
                .clipShape(Capsule())
        }
    }

    var dismissButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                isDismissed = true
            }
        } label: {
            Image(systemName: "xmark")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(6)
        }
    }
}
