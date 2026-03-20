import SwiftUI

struct QuizSetupScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: QuizType = .flagQuiz
    @State private var selectedRegion: QuizRegion = .world
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var selectedCount: QuestionCount = .ten
    @State private var showQuizSession = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
    ]

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
                    .padding(.bottom, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Color.background)
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GeoCircleCloseButton()
                }
            }
            .fullScreenCover(isPresented: $showQuizSession) {
                QuizSessionScreen(configuration: makeConfiguration())
            }
        }
    }
}

// MARK: - Quiz Type Section

private extension QuizSetupScreen {
    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Quiz Type")

            LazyVGrid(columns: gridColumns, spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizType.allCases) { type in
                    quizTypeCard(type)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func quizTypeCard(_ type: QuizType) -> some View {
        Button { selectedType = type } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: type.icon)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        selectedType == type
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.iconPrimary
                    )

                Text(type.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)

                Text(type.description)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        selectedType == type
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackground,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut, value: selectedType)
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
        Button { showQuizSession = true } label: {
            Label("Start Quiz", systemImage: "play.fill")
                .font(DesignSystem.Font.headline)
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
