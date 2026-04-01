import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct QuizPackDetailScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(CountryDataService.self) private var countryDataService

    public let packID: String

    @State private var packService = QuizPackService()
    @State private var allPacks: [QuizPack] = []

    public init(packID: String) {
        self.packID = packID
    }

    private var pack: QuizPack? {
        allPacks.first { $0.id == packID }
    }

    public var body: some View {
        Group {
            if let pack {
                packContent(pack)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(DesignSystem.Color.background)
        .navigationTitle(pack?.name ?? "Quiz Pack")
        #if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            packService.loadProgress()
            allPacks = QuizPackService.makeAllPacks(
                countries: countryDataService.countries
            )
        }
    }
}

// MARK: - Content
private extension QuizPackDetailScreen {
    func packContent(_ pack: QuizPack) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                packHeader(pack)
                progressOverview(pack)
                levelsSection(pack)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Header
private extension QuizPackDetailScreen {
    func packHeader(_ pack: QuizPack) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
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

            Text(pack.description)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)

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
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Progress Overview
private extension QuizPackDetailScreen {
    func progressOverview(_ pack: QuizPack) -> some View {
        let completed = packService.completedLevelCount(for: pack)
        let stars = packService.totalStars(for: pack)
        let maxStars = packService.maxStars(for: pack)

        return HStack(spacing: DesignSystem.Spacing.sm) {
            progressStat(
                value: "\(completed)",
                label: "Completed",
                total: "\(pack.levelCount)"
            )
            progressStat(
                value: "\(stars)",
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
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Levels Section
private extension QuizPackDetailScreen {
    func levelsSection(_ pack: QuizPack) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Levels", icon: "chart.bar.fill")

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(
                    Array(pack.levels.enumerated()),
                    id: \.element.id
                ) { index, level in
                    let locked = isLevelLocked(at: index, in: pack)
                    let starCount = packService.stars(for: level.id)

                    Button {
                        handleLevelTap(level, in: pack, locked: locked)
                    } label: {
                        QuizPackLevelCard(
                            level: level,
                            stars: starCount,
                            isLocked: locked
                        )
                    }
                    .buttonStyle(PressButtonStyle())
                    .disabled(locked)
                }
            }
        }
    }

    func isLevelLocked(at index: Int, in pack: QuizPack) -> Bool {
        guard index > 0 else { return false }
        let previousLevel = pack.levels[index - 1]
        return packService.progress(for: previousLevel.id) == nil
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
        .background(DesignSystem.Color.cardBackground, in: Capsule())
    }
}

// MARK: - Actions
private extension QuizPackDetailScreen {
    func handleLevelTap(
        _ level: QuizPackLevel,
        in pack: QuizPack,
        locked: Bool
    ) {
        guard !locked else { return }

        if pack.isPremium, !subscriptionService.isPremium {
            coordinator.sheet(.paywall)
            return
        }

        let metric: ComparisonMetric =
            pack.category == .population ? .population : .area

        let config = QuizConfiguration(
            type: pack.category.quizType,
            region: .world,
            difficulty: .easy,
            questionCount: QuestionCount(rawValue: level.questionCount) ?? .ten,
            answerMode: .multipleChoice,
            comparisonMetric: metric,
            gameMode: .standard,
        )

        coordinator.cover(.quizSession(config))
    }
}
