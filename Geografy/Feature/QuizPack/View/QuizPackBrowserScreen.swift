import SwiftUI

struct QuizPackBrowserScreen: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var packService = QuizPackService()

    @State private var selectedCategory: QuizPackCategory?
    @State private var selectedPack: QuizPack?
    @State private var countryDataService = CountryDataService()
    @State private var allPacks: [QuizPack] = []
    @State private var showingPaywall = false
    @State private var blobAnimating = false
    @State private var appeared = false

    var body: some View {
        scrollContent
            .background { ambientBackground }
            .navigationTitle("Quiz Packs")
            .task { loadData() }
            .onAppear { startAnimations() }
            .sheet(item: $selectedPack) { pack in
                QuizPackDetailScreen(
                    pack: pack,
                    allPacks: allPacks,
                    packService: packService
                )
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallScreen()
            }
    }
}

// MARK: - Content
private extension QuizPackBrowserScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(
                alignment: .leading,
                spacing: DesignSystem.Spacing.lg
            ) {
                overallProgress
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.0)
                categoryFilter
                    .feedSection(appeared: appeared, delay: 0.08)
                packGrid
                    .feedSection(appeared: appeared, delay: 0.16)
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Overall Progress
private extension QuizPackBrowserScreen {
    var overallProgress: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            overallStat(
                value: "\(totalCompletedPacks)",
                label: "Packs Done",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success
            )
            overallStat(
                value: "\(totalStars)",
                label: "Stars",
                icon: "star.fill",
                color: DesignSystem.Color.warning
            )
            overallStat(
                value: "\(filteredPacks.count)",
                label: "Available",
                icon: "square.grid.2x2.fill",
                color: DesignSystem.Color.accent
            )
        }
    }

    func overallStat(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption2)
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

// MARK: - Category Filter
private extension QuizPackBrowserScreen {
    var categoryFilter: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.sm
        ) {
            SectionHeaderView(title: "Categories")
                .padding(.horizontal, DesignSystem.Spacing.md)
            categoryChips
        }
    }

    var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                allCategoryChip
                ForEach(QuizPackCategory.allCases) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    var allCategoryChip: some View {
        Button { selectedCategory = nil } label: {
            chipLabel(
                emoji: "🌍",
                text: "All",
                isSelected: selectedCategory == nil
            )
        }
        .buttonStyle(.plain)
    }

    func categoryChip(
        _ category: QuizPackCategory
    ) -> some View {
        let isSelected = selectedCategory == category
        return Button { selectedCategory = category } label: {
            chipLabel(
                emoji: category.emoji,
                text: category.displayName,
                isSelected: isSelected
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    func chipLabel(
        emoji: String,
        text: String,
        isSelected: Bool
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text(emoji)
                .font(DesignSystem.Font.subheadline)
            Text(text)
                .font(DesignSystem.Font.caption)
                .fontWeight(isSelected ? .bold : .regular)
        }
        .foregroundStyle(
            isSelected
                ? DesignSystem.Color.onAccent
                : DesignSystem.Color.textPrimary
        )
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            isSelected
                ? DesignSystem.Color.accent
                : DesignSystem.Color.cardBackground,
            in: Capsule()
        )
        .overlay(
            Capsule().strokeBorder(
                isSelected
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.cardBackgroundHighlighted,
                lineWidth: 1
            )
        )
    }
}

// MARK: - Pack Grid
private extension QuizPackBrowserScreen {
    var packGrid: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.sm
        ) {
            SectionHeaderView(
                title: "Packs",
                icon: "square.grid.2x2"
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
            packGridContent
        }
    }

    var packGridContent: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: 140),
                    spacing: DesignSystem.Spacing.sm
                ),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(filteredPacks) { pack in
                packButton(for: pack)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func packButton(for pack: QuizPack) -> some View {
        let unlocked = packService.isPackUnlocked(
            pack,
            allPacks: allPacks
        )
        let completed = packService.completedLevelCount(for: pack)
        let stars = packService.totalStars(for: pack)
        let maxStars = packService.maxStars(for: pack)

        return Button {
            handlePackTap(pack, unlocked: unlocked)
        } label: {
            QuizPackCard(
                pack: pack,
                completedLevels: completed,
                stars: stars,
                maxStars: maxStars,
                isUnlocked: unlocked
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Background
private extension QuizPackBrowserScreen {
    var ambientBackground: some View {
        ZStack {
            DesignSystem.Color.background

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.22),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 30)
                .offset(x: -60, y: -180)
                .scaleEffect(blobAnimating ? 1.08 : 0.92)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.purple.opacity(0.16),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 340, height: 280)
                .blur(radius: 36)
                .offset(x: 120, y: 120)
                .scaleEffect(blobAnimating ? 0.90 : 1.08)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Actions
private extension QuizPackBrowserScreen {
    func loadData() {
        countryDataService.loadCountries()
        packService.loadProgress()
        allPacks = QuizPackService.makeAllPacks(
            countries: countryDataService.countries
        )
    }

    func startAnimations() {
        if !reduceMotion {
            withAnimation(
                .easeInOut(duration: 6)
                    .repeatForever(autoreverses: true)
            ) {
                blobAnimating = true
            }
        } else {
            blobAnimating = true
        }
        withAnimation(.easeOut(duration: 0.7)) {
            appeared = true
        }
    }

    func handlePackTap(
        _ pack: QuizPack,
        unlocked: Bool
    ) {
        guard unlocked else { return }

        if pack.isPremium, !subscriptionService.isPremium {
            showingPaywall = true
            return
        }

        selectedPack = pack
    }
}

// MARK: - Computed Properties
private extension QuizPackBrowserScreen {
    var filteredPacks: [QuizPack] {
        guard let category = selectedCategory else {
            return allPacks
        }
        return allPacks.filter { $0.category == category }
    }

    var totalCompletedPacks: Int {
        allPacks.filter {
            packService.isPackCompleted($0)
        }.count
    }

    var totalStars: Int {
        allPacks.reduce(0) {
            $0 + packService.totalStars(for: $1)
        }
    }
}

// MARK: - Feed Section Modifier
private extension View {
    func feedSection(
        appeared: Bool,
        delay: Double
    ) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .easeOut(duration: 0.5).delay(delay),
                value: appeared
            )
    }
}
