import SwiftUI
import Combine
import GeografyDesign

struct LandmarkQuizScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var quizService = LandmarkQuizService()
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var timeRemaining: Int = 20
    @State private var isGameOver = false
    @State private var answerOptions: [String] = []
    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        ZStack {
            if isGameOver {
                gameOverContent
            } else {
                quizContent
            }
        }
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Landmark Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .task { loadQuiz() }
        .onDisappear { timerCancellable?.cancel() }
    }
}

// MARK: - Quiz Content
private extension LandmarkQuizScreen {
    @ViewBuilder
    var quizContent: some View {
        if quizService.questions.isEmpty {
            ProgressView()
                .tint(DesignSystem.Color.accent)
        } else {
            VStack(spacing: DesignSystem.Spacing.md) {
                SessionProgressView(
                    progress: progressFraction,
                    current: currentQuestionIndex + 1,
                    total: quizService.questions.count
                )

                headerBar

                questionText

                answersGrid

                Spacer(minLength: 0)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
        }
    }

    var headerBar: some View {
        HStack {
            timerBadge

            Spacer()

            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: currentQuestion.category.icon)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(currentQuestion.category.displayName)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            Spacer()

            scoreBadge
        }
    }

    var timerBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "timer")
                .font(DesignSystem.Font.caption)

            Text("\(String(timeRemaining))s")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .contentTransition(.numericText())
        }
        .foregroundStyle(timerColor)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(timerColor.opacity(0.15), in: Capsule())
    }

    var scoreBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.warning)

            Text("\(score)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.cardBackground, in: Capsule())
    }

    var questionText: some View {
        Text(currentQuestion.hint)
            .font(DesignSystem.Font.title2)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
    }

    var answersGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(Array(answerOptions.enumerated()), id: \.element) { index, countryCode in
                QuizOptionButton(
                    text: countryDataService.countries.first { $0.code == countryCode }?.name,
                    flagCode: countryCode,
                    state: optionState(for: countryCode),
                    index: index
                ) {
                    selectAnswer(countryCode)
                }
            }
        }
    }

    var timerColor: Color {
        switch timeRemaining {
        case 11...: DesignSystem.Color.success
        case 6...10: DesignSystem.Color.warning
        default: DesignSystem.Color.error
        }
    }

    var progressFraction: CGFloat {
        guard !quizService.questions.isEmpty else { return 0 }
        return CGFloat(currentQuestionIndex) / CGFloat(quizService.questions.count)
    }

    func optionState(for countryCode: String) -> QuizOptionButton.OptionState {
        guard selectedAnswer != nil else { return .default }
        if countryCode == currentQuestion.answerCountryCode { return .correct }
        if countryCode == selectedAnswer { return .incorrect }
        return .disabled
    }
}

// MARK: - Game Over
private extension LandmarkQuizScreen {
    var gameOverContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer(minLength: DesignSystem.Spacing.xl)

                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.12))
                        .frame(width: 96, height: 96)

                    Image(systemName: scoreGrade.icon)
                        .font(DesignSystem.Font.displayXS)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .symbolEffect(.bounce)
                }

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(scoreGrade.title)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text(scoreGrade.subtitle)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .multilineTextAlignment(.center)
                }

                CardView {
                    HStack(spacing: 0) {
                        ResultStatItem(
                            icon: "star.fill",
                            value: "\(score)",
                            label: "Score",
                            color: DesignSystem.Color.warning
                        )

                        ResultStatItem(
                            icon: "checkmark.circle.fill",
                            value: "\(score)/\(String(quizService.questions.count))",
                            label: "Correct",
                            color: DesignSystem.Color.success
                        )
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true) {
                restartQuiz()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    var scoreGrade: (title: String, subtitle: String, icon: String) {
        let total = quizService.questions.count
        let fraction = total > 0 ? Double(score) / Double(total) : 0
        return switch fraction {
        case 0.8...: ("Geo Expert!", "Outstanding knowledge of world landmarks", "trophy.fill")
        case 0.6..<0.8: ("Well Done!", "Great understanding of world geography", "star.fill")
        case 0.4..<0.6: ("Getting There!", "Keep exploring the world", "globe")
        default: ("Keep Learning!", "Every expert was once a beginner", "book.fill")
        }
    }
}

// MARK: - Actions
private extension LandmarkQuizScreen {
    var currentQuestion: LandmarkQuestion {
        quizService.questions[currentQuestionIndex]
    }

    func loadQuiz() {
        quizService.loadQuestions()
        prepareAnswers()
        startTimer()
    }

    func prepareAnswers() {
        guard !quizService.questions.isEmpty else { return }
        let question = quizService.questions[currentQuestionIndex]
        let allCodes = countryDataService.countries.map { $0.code }
        let wrongCodes = quizService.randomWrongAnswers(
            excluding: question.answerCountryCode,
            from: allCodes,
            count: 3
        )
        answerOptions = ([question.answerCountryCode] + wrongCodes).shuffled()
    }

    func selectAnswer(_ countryCode: String) {
        guard selectedAnswer == nil else { return }
        timerCancellable?.cancel()
        selectedAnswer = countryCode
        let isCorrect = countryCode == currentQuestion.answerCountryCode

        if isCorrect {
            score += 1
            hapticsService.notification(.success)
        } else {
            hapticsService.notification(.error)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceQuestion()
        }
    }

    func advanceQuestion() {
        let nextIndex = currentQuestionIndex + 1
        if nextIndex >= quizService.questions.count {
            withAnimation { isGameOver = true }
        } else {
            withAnimation {
                currentQuestionIndex = nextIndex
                selectedAnswer = nil
                timeRemaining = 20
            }
            prepareAnswers()
            startTimer()
        }
    }

    func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    selectAnswer("")
                }
            }
    }

    func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        timeRemaining = 20
        isGameOver = false
        quizService.loadQuestions()
        prepareAnswers()
        startTimer()
    }
}
