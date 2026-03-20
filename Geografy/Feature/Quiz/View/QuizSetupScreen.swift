import SwiftUI

struct QuizSetupScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: QuizType = .flagQuiz
    @State private var selectedRegion: QuizRegion = .world
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var selectedCount: QuestionCount = .ten
    @State private var showQuizSession = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    quizTypeSection
                    regionSection
                    difficultySection
                    questionCountSection
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(QuizType.allCases) { type in
                        quizTypeCard(type)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    func quizTypeCard(_ type: QuizType) -> some View {
        Button { selectedType = type } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: type.icon)
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(
                        selectedType == type
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.iconPrimary
                    )

                Text(type.displayName)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)

                Text(type.description)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: DesignSystem.Size.hero)
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

// MARK: - Region Section

private extension QuizSetupScreen {
    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Region")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(QuizRegion.allCases) { region in
                        regionChip(region)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    func regionChip(_ region: QuizRegion) -> some View {
        Button { selectedRegion = region } label: {
            Text(region.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    selectedRegion == region
                        ? DesignSystem.Color.onAccent
                        : DesignSystem.Color.textSecondary
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    selectedRegion == region
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.cardBackground
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut, value: selectedRegion)
    }
}

// MARK: - Difficulty Section

private extension QuizSetupScreen {
    var difficultySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Difficulty")

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    difficultyCard(difficulty)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func difficultyCard(_ difficulty: QuizDifficulty) -> some View {
        Button { selectedDifficulty = difficulty } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: difficulty.icon)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(difficultyColor(difficulty))

                Text(difficulty.displayName)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                VStack(spacing: DesignSystem.Spacing.xxs) {
                    ForEach(difficultyFeatures(difficulty), id: \.self) { feature in
                        Text(feature)
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        selectedDifficulty == difficulty
                            ? difficultyColor(difficulty)
                            : DesignSystem.Color.cardBackground,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut, value: selectedDifficulty)
    }
}

// MARK: - Question Count Section

private extension QuizSetupScreen {
    var questionCountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Questions")

            Picker("Questions", selection: $selectedCount) {
                ForEach(QuestionCount.allCases) { count in
                    Text(count.displayName).tag(count)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Start Button

private extension QuizSetupScreen {
    var startButton: some View {
        Button { showQuizSession = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "play.fill")
                    .font(DesignSystem.Font.title2)

                Text("Start Quiz")
                    .font(DesignSystem.Font.title2)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(.plain)
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

    func makeConfiguration() -> QuizConfiguration {
        QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount
        )
    }

    func difficultyColor(_ difficulty: QuizDifficulty) -> Color {
        switch difficulty {
        case .easy: DesignSystem.Color.success
        case .medium: DesignSystem.Color.warning
        case .hard: DesignSystem.Color.error
        }
    }

    func difficultyFeatures(_ difficulty: QuizDifficulty) -> [String] {
        switch difficulty {
        case .easy:
            ["4 options", "No timer", "Relaxed"]
        case .medium:
            ["4 options", "30s timer", "Moderate"]
        case .hard:
            ["Type answer", "No hints", "Expert"]
        }
    }
}
