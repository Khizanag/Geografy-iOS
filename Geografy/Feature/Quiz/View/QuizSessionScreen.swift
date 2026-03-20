import SwiftUI

struct QuizSessionScreen: View {
    @Environment(\.dismiss) private var dismiss

    let configuration: QuizConfiguration

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var answers: [QuizAnswer] = []
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var timerRemaining: TimeInterval = 0
    @State private var startTime = Date()
    @State private var questionStartTime = Date()
    @State private var showQuitAlert = false
    @State private var showFlagPreview = false
    @State private var navigateToResult: QuizResult?
    @State private var countryDataService = CountryDataService()

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.lg) {
                progressSection
                questionContent
                Spacer()
            }
            .padding(.top, DesignSystem.Spacing.md)
            .background(DesignSystem.Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GeoCircleCloseButton { showQuitAlert = true }
                }
            }
            .alert("Quit Quiz?", isPresented: $showQuitAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Quit", role: .destructive) { dismiss() }
            } message: {
                Text("Your progress will be lost.")
            }
            .task { loadQuiz() }
            .navigationDestination(item: $navigateToResult) { result in
                QuizResultsScreen(result: result) {
                    navigateToResult = nil
                    loadQuiz()
                }
            }
        }
        .overlay {
            if showFlagPreview, let flagCode = currentQuestion?.promptFlag {
                ZoomableFlagView(countryCode: flagCode) {
                    showFlagPreview = false
                }
            }
        }
    }
}

// MARK: - Subviews

private extension QuizSessionScreen {
    var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack {
                progressBar
                questionCounter
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            if configuration.difficulty.hasTimer {
                timerIndicator
            }
        }
    }

    var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackground)

                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: DesignSystem.Size.xs)
    }

    var questionCounter: some View {
        Text("\(currentIndex + 1)/\(questions.count)")
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var timerIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "clock.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(timerColor)

            Text("\(Int(timerRemaining))s")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(timerColor)
                .contentTransition(.numericText())
        }
    }

    @ViewBuilder
    var questionContent: some View {
        if let question = currentQuestion {
            QuizQuestionView(
                question: question,
                quizType: configuration.type,
                selectedOptionID: selectedOptionID,
                correctOptionID: question.correctOptionID,
                showFeedback: showFeedback,
                showFlagPreview: $showFlagPreview,
                onSelectOption: { optionID in selectOption(optionID) }
            )
            .id(question.id)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
    }
}

// MARK: - Actions

private extension QuizSessionScreen {
    func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil else { return }
        selectedOptionID = optionID

        let question = questions[currentIndex]
        let isCorrect = optionID == question.correctOptionID
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: optionID,
            isCorrect: isCorrect,
            timeSpent: timeSpent
        )
        answers.append(answer)

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            advanceToNext()
        }
    }

    func advanceToNext() {
        if currentIndex + 1 < questions.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
                selectedOptionID = nil
                showFeedback = false
                questionStartTime = Date()
                timerRemaining = configuration.difficulty.timerDuration
            }
        } else {
            finishQuiz()
        }
    }

    func finishQuiz() {
        let totalTime = Date().timeIntervalSince(startTime)
        navigateToResult = QuizResult(
            configuration: configuration,
            answers: answers,
            totalTime: totalTime
        )
    }

    func loadQuiz() {
        countryDataService.loadCountries()
        let pool = configuration.region.filter(countryDataService.countries)
        let optionCount = max(configuration.difficulty.optionCount, 4)
        guard pool.count >= optionCount else { return }

        questions = QuestionGenerator.generate(
            type: configuration.type,
            countries: pool,
            count: min(configuration.questionCount.rawValue, pool.count),
            optionCount: optionCount
        )
        currentIndex = 0
        answers = []
        selectedOptionID = nil
        showFeedback = false
        startTime = Date()
        questionStartTime = Date()
        timerRemaining = configuration.difficulty.timerDuration
    }

    func resetQuiz() {
        currentIndex = 0
        answers = []
        selectedOptionID = nil
        showFeedback = false
        startTime = Date()
        questionStartTime = Date()
        timerRemaining = configuration.difficulty.timerDuration
    }
}

// MARK: - Helpers

private extension QuizSessionScreen {
    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }

    var timerColor: Color {
        if timerRemaining <= 5 {
            DesignSystem.Color.error
        } else if timerRemaining <= 10 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.textSecondary
        }
    }
}
