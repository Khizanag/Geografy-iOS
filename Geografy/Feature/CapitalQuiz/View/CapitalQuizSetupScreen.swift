import SwiftUI

struct CapitalQuizSetupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TabCoordinator.self) private var coordinator

    @AppStorage("capitalQuiz_region") private var selectedRegion: QuizRegion = .world
    @AppStorage("capitalQuiz_difficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("capitalQuiz_count") private var selectedCount: QuestionCount = .ten
    @AppStorage("capitalQuiz_answerMode") private var answerMode: QuizAnswerMode = .multipleChoice

    @State private var blobAnimating = false

    var body: some View {
        contentView
            .navigationTitle("Capital Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .safeAreaInset(edge: .bottom) { startButton }
            .onAppear { startBlobAnimation() }
    }
}

// MARK: - Toolbar

private extension CapitalQuizSetupScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CircleCloseButton()
        }
    }
}

// MARK: - Content

private extension CapitalQuizSetupScreen {
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                headerSection
                modeSection
                regionSection
                difficultySection
                questionCountSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }
}

// MARK: - Header

private extension CapitalQuizSetupScreen {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.indigo.opacity(0.15))
                    .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.indigo)
            }
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text("Capital City Quiz")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Test your knowledge of world capitals")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
}

// MARK: - Mode Section

private extension CapitalQuizSetupScreen {
    var modeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Answer Mode")
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizAnswerMode.allCases) { mode in
                    modeChip(mode)
                }
            }
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
                isSelected ? DesignSystem.Color.indigo : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Region Section

private extension CapitalQuizSetupScreen {
    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Region")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(QuizRegion.allCases) { region in
                        regionChip(region)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
            }
            .scrollClipDisabled()
        }
    }

    func regionChip(_ region: QuizRegion) -> some View {
        let isSelected = selectedRegion == region
        return Button { selectedRegion = region } label: {
            Text(region.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    isSelected ? DesignSystem.Color.indigo : DesignSystem.Color.cardBackground,
                    in: Capsule()
                )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Difficulty Section

private extension CapitalQuizSetupScreen {
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
                            .fill(DesignSystem.Color.indigo.opacity(isSelected ? 0.2 : 0.08))
                            .frame(width: 40, height: 40)
                        Image(systemName: difficulty.icon)
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(
                                isSelected ? DesignSystem.Color.indigo : DesignSystem.Color.textSecondary
                            )
                    }
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(difficulty.displayName)
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(difficulty.subtitle)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.indigo)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Question Count Section

private extension CapitalQuizSetupScreen {
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
                    isSelected ? DesignSystem.Color.indigo : DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Start Button

private extension CapitalQuizSetupScreen {
    var startButton: some View {
        Button { startQuiz() } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "play.fill")
                Text("Start Capital Quiz")
                    .fontWeight(.bold)
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(.glass)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Background

private extension CapitalQuizSetupScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 420, height: 320)
                .blur(radius: 40)
                .offset(x: -80, y: -100)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.16), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 48)
                .offset(x: 140, y: 300)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    func startBlobAnimation() {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            blobAnimating = true
        }
    }
}

// MARK: - Actions

private extension CapitalQuizSetupScreen {
    func startQuiz() {
        let configuration = QuizConfiguration(
            type: .capitalQuiz,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
            answerMode: answerMode
        )
        dismiss()
        coordinator.presentFullScreen(.quizSession(configuration))
    }
}

// MARK: - Helpers

private extension CapitalQuizSetupScreen {
    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.headline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }
}
