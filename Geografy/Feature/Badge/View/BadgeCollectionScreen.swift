import SwiftUI

struct BadgeCollectionScreen: View {
    @Environment(\.dismiss) private var dismiss

    let badgeService: BadgeService

    @State private var selectedBadge: BadgeDefinition?
    @State private var selectedCategory: BadgeCategory?
    @State private var blobAnimating = false
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                collectionProgressCard
                showcaseSection
                filterBar
                badgeSections
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background { ambientBlobs }
        .background(
            DesignSystem.Color.background.ignoresSafeArea()
        )
        .navigationTitle("Badge Collection")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailSheet(
                definition: badge,
                isUnlocked: badgeService.isUnlocked(badge.id),
                progress: badgeService.progress(for: badge),
                isPinned: badgeService.isPinned(badge.id),
                canPin: badgeService.pinnedBadgeIDs.count < 3,
                onTogglePin: { badgeService.togglePin(badge.id) }
            )
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6)
                    .repeatForever(autoreverses: true)
            ) {
                blobAnimating = true
            }
            withAnimation(
                .easeOut(duration: 0.4).delay(0.1)
            ) {
                appeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension BadgeCollectionScreen {
    var collectionProgressCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(
                        alignment: .leading,
                        spacing: DesignSystem.Spacing.xxs
                    ) {
                        Text("Collection")
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                DesignSystem.Color.textPrimary
                            )
                        Text(collectionSubtitle)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(
                                DesignSystem.Color.textSecondary
                            )
                    }
                    Spacer()
                    completionPercentage
                }
                collectionProgressBar
            }
            .padding(DesignSystem.Spacing.md)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    var collectionSubtitle: String {
        let unlocked = badgeService.unlockedBadges.count
        let total = BadgeDefinition.all.count
        return "\(unlocked) of \(total) badges collected"
    }

    var completionPercentage: some View {
        VStack(spacing: 2) {
            Text(progressPercentText)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Complete")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var progressPercentText: String {
        let percent = Int(badgeService.collectionProgress * 100)
        return "\(percent)%"
    }

    var collectionProgressBar: some View {
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
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Color.accent,
                            DesignSystem.Color.accentDark,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(
                    width: geometry.size.width
                        * badgeService.collectionProgress,
                    height: DesignSystem.Spacing.xs
                )
            }
        }
        .frame(height: DesignSystem.Spacing.xs)
    }

    var showcaseSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Showcase", icon: "star.fill")
            CardView {
                BadgeShowcase(
                    pinnedBadges: badgeService.pinnedBadges
                )
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(BadgeCategory.allCases, id: \.rawValue) { category in
                    filterChip(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xxs)
        }
    }

    func filterChip(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Font.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundStyle(
                    isSelected
                        ? DesignSystem.Color.onAccent
                        : DesignSystem.Color.textSecondary
                )
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    isSelected
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.cardBackground,
                    in: Capsule()
                )
        }
        .buttonStyle(PressButtonStyle())
    }

    var badgeSections: some View {
        ForEach(filteredCategories, id: \.rawValue) { category in
            let badges = BadgeDefinition.all.filter {
                $0.category == category
            }
            BadgeCategorySection(
                category: category,
                badges: badges,
                badgeService: badgeService,
                onBadgeTap: { selectedBadge = $0 }
            )
        }
    }

    var filteredCategories: [BadgeCategory] {
        if let selected = selectedCategory {
            [selected]
        } else {
            BadgeCategory.allCases
        }
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.18),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 36)
                .offset(x: -60, y: -100)
                .scaleEffect(blobAnimating ? 1.08 : 0.92)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.indigo.opacity(0.12),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 40)
                .offset(x: 120, y: 200)
                .scaleEffect(blobAnimating ? 0.90 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
