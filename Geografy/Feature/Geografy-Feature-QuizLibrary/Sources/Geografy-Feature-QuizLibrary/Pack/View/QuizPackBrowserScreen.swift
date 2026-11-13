import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct QuizPackBrowserScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var packService = QuizPackService()
    @State private var selectedCategory: QuizPackCategory?
    @State private var allPacks: [QuizPack] = []
    @State private var appeared = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .task { loadData() }
            .onAppear { startAnimations() }
    }
}

// MARK: - Content
private extension QuizPackBrowserScreen {
    @ViewBuilder
    var scrollContent: some View {
        if allPacks.isEmpty {
            loadingContent
        } else if filteredPacks.isEmpty {
            emptyContent
        } else {
            packScrollView
        }
    }

    var loadingContent: some View {
        LoadingView()
    }

    var emptyContent: some View {
        ContentUnavailableView(
            "No Packs Found",
            systemImage: "square.grid.2x2",
            description: Text("No quiz packs match the selected category.")
        )
    }

    var packScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(
                alignment: .leading,
                spacing: DesignSystem.Spacing.lg
            ) {
                overallProgress
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.0, reduceMotion: reduceMotion)

                categoryFilter
                    .feedSection(appeared: appeared, delay: 0.08, reduceMotion: reduceMotion)

                packGrid
                    .feedSection(appeared: appeared, delay: 0.16, reduceMotion: reduceMotion)
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
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
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
        }
        .accessibilityElement(children: .combine)
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
        SelectableChip("All", isSelected: selectedCategory == nil) {
            selectedCategory = nil
        } icon: {
            Text(verbatim: "🌍")
                .font(DesignSystem.Font.subheadline)
        }
    }

    func categoryChip(
        _ category: QuizPackCategory
    ) -> some View {
        let isSelected = selectedCategory == category
        return SelectableChip(category.displayName, isSelected: isSelected) {
            selectedCategory = category
        } icon: {
            Text(verbatim: category.emoji)
                .font(DesignSystem.Font.subheadline)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isSelected)
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
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
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

// MARK: - Actions
private extension QuizPackBrowserScreen {
    func loadData() {
        packService.loadProgress()
        allPacks = QuizPackService.makeAllPacks(
            countries: countryDataService.countries
        )
    }

    func startAnimations() {
        appeared = true
    }

    func handlePackTap(
        _ pack: QuizPack,
        unlocked: Bool
    ) {
        guard unlocked else { return }
        coordinator.sheet(.quizPackDetail(packID: pack.id))
    }
}

// MARK: - Helpers
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
        delay: Double,
        reduceMotion: Bool
    ) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 20)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.5).delay(delay),
                value: appeared
            )
    }
}
