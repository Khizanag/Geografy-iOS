import SwiftUI

struct QuizPackDetailScreen: View {
    @Environment(QuizPackService.self) private var packService
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.dismiss) private var dismiss

    let pack: QuizPack
    let allPacks: [QuizPack]

    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            scrollContent
                .background(DesignSystem.Color.background)
                .navigationTitle(pack.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { closeToolbarItem }
                .sheet(isPresented: $showingPaywall) {
                    PaywallScreen()
                }
        }
    }
}

// MARK: - Content

private extension QuizPackDetailScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                packHeader
                progressOverview
                levelsSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Header

private extension QuizPackDetailScreen {
    var packHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            headerIconCircle
            headerDescription
            headerBadges
        }
        .padding(.top, DesignSystem.Spacing.md)
    }

    var headerIconCircle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            pack.gradientColors.0,
                            pack.gradientColors.1,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: DesignSystem.Size.xxxl,
                    height: DesignSystem.Size.xxxl
                )

            Image(systemName: pack.icon)
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
    }

    var headerDescription: some View {
        Text(pack.description)
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignSystem.Spacing.lg)
    }

    @ViewBuilder
    var headerBadges: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            infoPill(
                text: "\(pack.totalQuestions) questions",
                icon: "questionmark.circle"
            )
            infoPill(
                text: "\(pack.levelCount) levels",
                icon: "chart.bar.fill"
            )
            if pack.isPremium {
                PremiumBadge()
            }
        }
    }
}

// MARK: - Progress Overview

private extension QuizPackDetailScreen {
    var progressOverview: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            progressStat(
                value: "\(completedLevels)",
                label: "Completed",
                total: "\(pack.levelCount)"
            )
            progressStat(
                value: "\(earnedStars)",
                label: "Stars",
                total: "\(maxStars)"
            )
        }
    }

    func progressStat(
        value: String,
        label: String,
        total: String
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            HStack(spacing: 0) {
                Text(value)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("/\(total)")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
    }
}

// MARK: - Levels Section

private extension QuizPackDetailScreen {
    var levelsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Levels", icon: "chart.bar.fill")
            levelsList
        }
    }

    var levelsList: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(
                Array(pack.levels.enumerated()),
                id: \.element.id
            ) { index, level in
                levelRow(for: level, at: index)
            }
        }
    }

    func levelRow(
        for level: QuizPackLevel,
        at index: Int
    ) -> some View {
        let locked = isLevelLocked(at: index)
        let starCount = packService.stars(for: level.id)

        return Button { handleLevelTap(level, locked: locked) } label: {
            QuizPackLevelCard(
                level: level,
                stars: starCount,
                isLocked: locked
            )
        }
        .buttonStyle(GeoPressButtonStyle())
        .disabled(locked)
    }
}

// MARK: - Toolbar

private extension QuizPackDetailScreen {
    var closeToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton { dismiss() }
        }
    }
}

// MARK: - Helpers

private extension QuizPackDetailScreen {
    func infoPill(text: String, icon: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
            Text(text)
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(DesignSystem.Color.textSecondary)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.cardBackground,
            in: Capsule()
        )
    }

    var completedLevels: Int {
        packService.completedLevelCount(for: pack)
    }

    var earnedStars: Int {
        packService.totalStars(for: pack)
    }

    var maxStars: Int {
        packService.maxStars(for: pack)
    }

    func isLevelLocked(at index: Int) -> Bool {
        guard index > 0 else { return false }
        let previousLevel = pack.levels[index - 1]
        return packService.progress(for: previousLevel.id) == nil
    }
}

// MARK: - Actions

private extension QuizPackDetailScreen {
    func handleLevelTap(
        _ level: QuizPackLevel,
        locked: Bool
    ) {
        guard !locked else { return }

        if pack.isPremium, !subscriptionService.isPremium {
            showingPaywall = true
            return
        }

        // Level tap will be wired to quiz session in future
    }
}
