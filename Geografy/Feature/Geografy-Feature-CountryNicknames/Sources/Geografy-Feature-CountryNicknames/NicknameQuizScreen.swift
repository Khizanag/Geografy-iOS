import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct NicknameQuizScreen: View {
    public init() {}
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    public var nicknames: [CountryNickname] = CountryNicknamesService().nicknames

    @State private var questions: [NicknameQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedOptionIndex: Int?
    @State private var showFeedback = false
    @State private var isGameOver = false

    public var body: some View {
        mainContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Nickname Quiz")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton { dismiss() }
                }
            }
            .task { buildQuestions() }
    }
}

// MARK: - Main Content
private extension NicknameQuizScreen {
    @ViewBuilder
    var mainContent: some View {
        if isGameOver {
            gameOverContent
        } else if questions.isEmpty {
            ProgressView().tint(DesignSystem.Color.accent)
        } else {
            quizContent
        }
    }
}

// MARK: - Quiz Content
private extension NicknameQuizScreen {
    var quizContent: some View {
        VStack(spacing: 0) {
            progressSection
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
                .padding(.bottom, DesignSystem.Spacing.md)
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    nicknamePromptCard
                    answerOptions
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
            }
        }
    }

    var progressSection: some View {
        SessionProgressView(progress: progressFraction, current: currentIndex + 1, total: questions.count)
    }

    var progressFraction: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }

    var nicknamePromptCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Which country is known as…")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text("\"\(currentQuestion.nickname)\"")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.lg)
        }
    }

    var answerOptions: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(currentQuestion.options.enumerated()), id: \.element) { index, countryCode in
                let country = countryDataService.country(for: countryCode)
                QuizOptionButton(
                    text: country?.name ?? countryCode,
                    flagCode: countryCode,
                    state: optionState(for: index),
                    index: index
                ) {
                    selectAnswer(at: index)
                }
            }
        }
    }

    func optionState(for index: Int) -> QuizOptionButton.OptionState {
        guard showFeedback else { return .default }
        let countryCode = currentQuestion.options[index]
        if countryCode == currentQuestion.correctCountryCode { return .correct }
        if index == selectedOptionIndex { return .incorrect }
        return .disabled
    }
}

// MARK: - Game Over
private extension NicknameQuizScreen {
    var gameOverContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                resultHeader
                statsGrid
            }
            .padding(DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true) {
                restartQuiz()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    var resultHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: gradeFraction >= 0.8 ? "trophy.fill" : "star.fill")
                    .font(DesignSystem.Font.displayXS)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            Text(gradeFraction >= 0.8 ? "Nickname Expert!" : "Well Played!")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var statsGrid: some View {
        CardView {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DesignSystem.Spacing.sm
            ) {
                ResultStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(score)",
                    label: "Correct",
                    color: DesignSystem.Color.success
                )
                ResultStatItem(
                    icon: "xmark.circle.fill",
                    value: "\(questions.count - score)",
                    label: "Wrong",
                    color: DesignSystem.Color.error
                )
                ResultStatItem(
                    icon: "chart.bar.fill",
                    value: "\(Int(gradeFraction * 100))%",
                    label: "Accuracy",
                    color: DesignSystem.Color.accent
                )
                ResultStatItem(
                    icon: "number",
                    value: "\(questions.count)",
                    label: "Questions",
                    color: DesignSystem.Color.indigo
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var gradeFraction: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(score) / Double(questions.count)
    }
}

// MARK: - Actions
private extension NicknameQuizScreen {
    var currentQuestion: NicknameQuestion {
        questions[currentIndex]
    }

    func buildQuestions() {
        let shuffled = nicknames.shuffled()
        let selected = Array(shuffled.prefix(15))
        questions = selected.map { nickname in
            let wrongCodes = nicknames
                .filter { $0.countryCode != nickname.countryCode }
                .map(\.countryCode)
                .shuffled()
                .prefix(3)
            let options = ([nickname.countryCode] + wrongCodes).shuffled()
            return NicknameQuestion(
                nickname: nickname.nickname,
                options: options,
                correctCountryCode: nickname.countryCode
            )
        }
    }

    func selectAnswer(at index: Int) {
        guard !showFeedback else { return }
        selectedOptionIndex = index
        showFeedback = true

        let countryCode = currentQuestion.options[index]
        let isCorrect = countryCode == currentQuestion.correctCountryCode
        if isCorrect {
            score += 1
            #if !os(tvOS)
            hapticsService.notification(.success)
            #endif
        } else {
            #if !os(tvOS)
            hapticsService.notification(.error)
            #endif
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceQuestion()
        }
    }

    func advanceQuestion() {
        let nextIndex = currentIndex + 1
        if nextIndex >= questions.count {
            withAnimation { isGameOver = true }
        } else {
            withAnimation {
                currentIndex = nextIndex
                selectedOptionIndex = nil
                showFeedback = false
            }
        }
    }

    func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedOptionIndex = nil
        showFeedback = false
        isGameOver = false
        buildQuestions()
    }
}

// MARK: - Supporting Types
private extension NicknameQuizScreen {
    public struct NicknameQuestion {
        let nickname: String
        let options: [String]
        let correctCountryCode: String
    }
}
