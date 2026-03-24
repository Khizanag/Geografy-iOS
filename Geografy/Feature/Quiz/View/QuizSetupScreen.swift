import SwiftUI

struct QuizSetupScreen: View {
    @Environment(TabCoordinator.self) private var coordinator
    @Environment(SubscriptionService.self) private var subscriptionService

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @AppStorage("quiz_answerMode") private var answerMode: QuizAnswerMode = .multipleChoice

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                headerSection
                quizTypeSection
                answerModeSection
                regionSection
                difficultySection
                questionCountSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) { startButton }
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Header

private extension QuizSetupScreen {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.15))
                    .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
                Image(systemName: selectedType.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
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
                        coordinator.present(.paywall)
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
                ForEach(QuizAnswerMode.allCases) { mode in
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
        if answerMode == .typing, !selectedType.supportsTypingMode {
            answerModeInfoRow(
                icon: "info.circle",
                text: "Typing isn't available for \(selectedType.displayName) — multiple choice will be used"
            )
        } else if answerMode == .typing {
            answerModeInfoRow(
                icon: "star.fill",
                text: "1.5× XP bonus for typing answers correctly"
            )
        }
    }

    func answerModeInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Region Section

private extension QuizSetupScreen {
    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Region")
            RegionSelectionBar(
                items: QuizRegion.allCases.map { $0 },
                selectedID: selectedRegion.id,
                onSelect: { selectedRegion = $0 }
            )
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
                coordinator.present(.paywall)
            } else {
                coordinator.presentFullScreen(.quizSession(makeConfiguration()))
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
    }

    func makeConfiguration() -> QuizConfiguration {
        let effectiveAnswerMode = selectedType.supportsTypingMode ? answerMode : .multipleChoice
        return QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
            answerMode: effectiveAnswerMode,
        )
    }
}
