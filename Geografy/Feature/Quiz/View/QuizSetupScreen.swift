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
                quizTypeSection
                regionSection
                difficultySection
                answerModeSection
                questionCountRow
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            startButton
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
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

            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    Text(difficulty.displayName).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DesignSystem.Spacing.md)

            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: selectedDifficulty.icon)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(selectedDifficulty.subtitle(for: answerMode))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .animation(.easeInOut(duration: 0.2), value: selectedDifficulty)
        }
    }
}

// MARK: - Answer Mode Section

private extension QuizSetupScreen {
    var answerModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Answer Mode")

            Picker("Answer Mode", selection: $answerMode) {
                ForEach(QuizAnswerMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DesignSystem.Spacing.md)

            answerModeNote
                .animation(.easeInOut(duration: 0.2), value: answerMode)
                .animation(.easeInOut(duration: 0.2), value: selectedType)
        }
    }

    @ViewBuilder
    var answerModeNote: some View {
        if answerMode == .typing, !selectedType.supportsTypingMode {
            answerModeInfoRow(
                icon: "info.circle",
                text: "Typing isn't available for Reverse Flag — multiple choice will be used"
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
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Question Count Row

private extension QuizSetupScreen {
    var questionCountRow: some View {
        pickerRow("Questions", selection: $selectedCount) { count in
            Text(count.displayName).tag(count)
        }
    }
}

// MARK: - Start Button

private extension QuizSetupScreen {
    var startButton: some View {
        GlassButton("Start Quiz", systemImage: "play.fill", fullWidth: true) {
            if selectedType.isPremium, !subscriptionService.isPremium {
                coordinator.present(.paywall)
            } else {
                coordinator.presentFullScreen(.quizSession(makeConfiguration()))
            }
        }
    }
}

// MARK: - Helpers

private extension QuizSetupScreen {
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func pickerRow<T: Hashable, Content: View>(
        _ title: String,
        selection: Binding<T>,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View where T: CaseIterable, T: Identifiable, T.AllCases: RandomAccessCollection {
        HStack {
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Picker(title, selection: selection) {
                ForEach(Array(T.allCases)) { item in
                    content(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DesignSystem.Color.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
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
