import SwiftUI

struct CountryProfileScreen: View {
    @Environment(SubscriptionService.self) private var subscriptionService

    @State private var showPaywall = false

    let country: Country
    let profile: CountryProfile?

    var body: some View {
        Group {
            if let profile {
                profileContent(profile)
            } else {
                comingSoonPlaceholder
            }
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Deep Dive")
        .sheet(isPresented: $showPaywall) { PaywallScreen() }
    }
}

// MARK: - Profile Content
private extension CountryProfileScreen {
    @ViewBuilder
    func profileContent(_ profile: CountryProfile) -> some View {
        if subscriptionService.isPremium {
            unlockedContent(profile)
        } else {
            lockedContent
        }
    }

    func unlockedContent(_ profile: CountryProfile) -> some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroHeader
                CountryProfileSection(profile: profile)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var lockedContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            lockedIcon
            lockedText
            unlockButton
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Hero Header
private extension CountryProfileScreen {
    var heroHeader: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            FlagView(
                countryCode: country.code,
                height: DesignSystem.Size.xxl
            )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(country.continent.displayName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            PremiumBadge()
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Locked State
private extension CountryProfileScreen {
    var lockedIcon: some View {
        Image(systemName: "lock.fill")
            .font(DesignSystem.IconSize.xLarge)
            .foregroundStyle(DesignSystem.Color.accent)
    }

    var lockedText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Premium Feature")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Unlock deep dives to explore culture, history, and more.")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }

    var unlockButton: some View {
        Button { showPaywall = true } label: {
            Text("Unlock with Premium")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Color.accent, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Coming Soon
private extension CountryProfileScreen {
    var comingSoonPlaceholder: some View {
        ComingSoonView(
            icon: "book.pages",
            title: "Deep Dive"
        )
    }
}
