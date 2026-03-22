import SwiftUI

struct QuizSetupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionService.self) private var subscriptionService

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @State private var showQuizSession = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    quizTypeSection
                    regionRow
                    difficultySection
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
            .fullScreenCover(isPresented: $showQuizSession) {
                QuizSessionScreen(configuration: makeConfiguration())
            }
            .sheet(isPresented: $showPaywall) {
                PaywallScreen()
            }
        }
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
                        showPaywall = true
                    } else {
                        selectedType = type
                    }
                },
                isLocked: { $0.isPremium && !subscriptionService.isPremium }
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Region Row

private extension QuizSetupScreen {
    var regionRow: some View {
        pickerRow("Region", selection: $selectedRegion) { region in
            Text(region.displayName).tag(region)
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
                Text(selectedDifficulty.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .animation(.easeInOut(duration: 0.2), value: selectedDifficulty)
        }
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
        Button {
            if selectedType.isPremium, !subscriptionService.isPremium {
                showPaywall = true
            } else {
                showQuizSession = true
            }
        } label: {
            Label("Start Quiz", systemImage: "play.fill")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .buttonStyle(.glass)
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
        QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
        )
    }
}

