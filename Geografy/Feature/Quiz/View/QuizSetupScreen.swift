import GeografyDesign
import SwiftUI

struct QuizSetupScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(SubscriptionService.self) private var subscriptionService

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @AppStorage("quiz_answerMode") private var answerMode: QuizAnswerMode = .multipleChoice
    @AppStorage("quiz_comparisonMetric") private var comparisonMetric: ComparisonMetric = .population
    @AppStorage("quiz_showAutocomplete") private var showAutocomplete = false
    @AppStorage("quiz_gameMode") private var selectedGameMode: QuizGameMode = .standard

    var body: some View {
        scrollContent
            .background { AmbientBlobsView(.quiz) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { startButton }
    }
}

// MARK: - Subviews
private extension QuizSetupScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                headerSection

                gameModeSection

                quizTypeSection

                if selectedType.hasComparisonMetric {
                    metricSection
                }

                if selectedType.supportedAnswerModes.count > 1 {
                    answerModeSection
                }

                regionSection

                if selectedGameMode == .standard {
                    difficultySection

                    questionCountSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }
}

// MARK: - Header
private extension QuizSetupScreen {
    var gameModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Game Mode")

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizGameMode.allCases) { mode in
                    gameModeChip(mode)
                }
            }
        }
    }

    func gameModeChip(_ mode: QuizGameMode) -> some View {
        let isSelected = selectedGameMode == mode
        return Button { selectedGameMode = mode } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: mode.icon)
                    .font(DesignSystem.Font.subheadline)

                Text(mode.rawValue)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)

                Text(mode.description)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.15))
                    .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
                Image(systemName: selectedType.icon)
                    .font(DesignSystem.Font.iconLarge)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .accessibilityHidden(true)
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(selectedType.displayName)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(selectedType.description)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Quiz Type Section
private extension QuizSetupScreen {
    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Quiz Type")
            TypeSelectionGrid(
                items: QuizType.allCases.map { $0 },
                selectedIDs: [selectedType.id],
                onSelect: { type in
                    if type.isPremium, !subscriptionService.isPremium {
                        coordinator.sheet(.paywall)
                    } else {
                        selectedType = type
                    }
                },
                isLocked: { $0.isPremium && !subscriptionService.isPremium }
            )
        }
    }
}

// MARK: - Answer Mode Section
private extension QuizSetupScreen {
    var answerModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Answer Mode")
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(selectedType.supportedAnswerModes) { mode in
                    modeChip(mode)
                }
            }
            answerModeNote
                .animation(.easeInOut(duration: 0.2), value: answerMode)
                .animation(.easeInOut(duration: 0.2), value: selectedType)
        }
    }

    func modeChip(_ mode: QuizAnswerMode) -> some View {
        let isSelected = answerMode == mode
        return Button { answerMode = mode } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: mode.icon)
                    .font(DesignSystem.Font.caption)
                Text(mode.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    @ViewBuilder
    var answerModeNote: some View {
        if answerMode == .typing {
            answerModeInfoRow(
                icon: "star.fill",
                text: "1.5× XP bonus for typing answers correctly"
            )

            Toggle(isOn: $showAutocomplete) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "text.magnifyingglass")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.accent)

                    Text("Show suggestions")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }
            }
            .tint(DesignSystem.Color.accent)
        } else if answerMode == .spellingBee {
            answerModeInfoRow(
                icon: "textformat.abc",
                text: "Spell the answer letter by letter — 2× XP bonus"
            )
        }
    }

    func answerModeInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Region Section
private extension QuizSetupScreen {
    var metricSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Metric")

            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(ComparisonMetric.allCases) { metric in
                    metricChip(metric)
                }
            }
        }
    }

    func metricChip(_ metric: ComparisonMetric) -> some View {
        let isSelected = comparisonMetric == metric
        return Button { comparisonMetric = metric } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: metric.icon)
                    .font(DesignSystem.Font.caption)

                Text(metric.rawValue)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Region")
                .padding(.horizontal, DesignSystem.Spacing.md)
            RegionCarousel(selectedRegion: $selectedRegion)
        }
    }
}

// MARK: - Difficulty Section
private extension QuizSetupScreen {
    var difficultySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Difficulty")
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    difficultyRow(difficulty)
                }
            }
        }
    }

    func difficultyRow(_ difficulty: QuizDifficulty) -> some View {
        let isSelected = selectedDifficulty == difficulty
        return Button { selectedDifficulty = difficulty } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Color.accent.opacity(isSelected ? 0.2 : 0.08))
                            .frame(width: 40, height: 40)
                        Image(systemName: difficulty.icon)
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(
                                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary
                            )
                    }
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(difficulty.displayName)
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(difficulty.subtitle(for: answerMode))
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.accent)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Question Count Section
private extension QuizSetupScreen {
    var questionCountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Questions")
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuestionCount.allCases) { count in
                    countChip(count)
                }
            }
        }
    }

    func countChip(_ count: QuestionCount) -> some View {
        let isSelected = selectedCount == count
        return Button { selectedCount = count } label: {
            Text(count.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Start Button
private extension QuizSetupScreen {
    var startButton: some View {
        GlassButton("Start \(selectedType.displayName)", systemImage: "play.fill", fullWidth: true) {
            if selectedType.isPremium, !subscriptionService.isPremium {
                coordinator.sheet(.paywall)
            } else {
                coordinator.cover(.quizSession(makeConfiguration()))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Helpers
private extension QuizSetupScreen {
    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.headline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    func makeConfiguration() -> QuizConfiguration {
        let effectiveAnswerMode = selectedType.supportedAnswerModes.contains(answerMode) ? answerMode : .multipleChoice
        return QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
            answerMode: effectiveAnswerMode,
            comparisonMetric: comparisonMetric,
            gameMode: selectedGameMode,
        )
    }
}
