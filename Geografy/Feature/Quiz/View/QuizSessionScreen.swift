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
    @State private var blobAnimating = false
    @Namespace private var flagNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Color.background.ignoresSafeArea()
                ambientBlobs
                VStack(spacing: DesignSystem.Spacing.md) {
                    progressSection
                    questionContent
                    Spacer(minLength: 0)
                }
                .padding(.top, DesignSystem.Spacing.sm)
            }
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
            .onAppear {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    blobAnimating = true
                }
            }
            .navigationDestination(item: $navigateToResult) { result in
                QuizResultsScreen(
                    result: result,
                    onPlayAgain: {
                        navigateToResult = nil
                        loadQuiz()
                    },
                    onDone: { dismiss() }
                )
            }
        }
        .overlay {
            if showFlagPreview, let flagCode = currentQuestion?.promptFlag {
                ZoomableFlagView(countryCode: flagCode, namespace: flagNamespace) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showFlagPreview = false
                    }
                }
            }
        }
    }
}

// MARK: - Background

private extension QuizSessionScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.22), .clear],
                    center: .center, startRadius: 0, endRadius: 200
                ))
                .frame(width: 420, height: 320).blur(radius: 36)
                .offset(x: -80, y: -100)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.indigo.opacity(0.18), .clear],
                    center: .center, startRadius: 0, endRadius: 180
                ))
                .frame(width: 360, height: 300).blur(radius: 44)
                .offset(x: 140, y: 60)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.blue.opacity(0.14), .clear],
                    center: .center, startRadius: 0, endRadius: 160
                ))
                .frame(width: 320, height: 260).blur(radius: 40)
                .offset(x: -40, y: 400)
                .scaleEffect(blobAnimating ? 1.05 : 0.95)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension QuizSessionScreen {
    var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                progressBar
                questionCounterPill
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            if configuration.difficulty.hasTimer {
                timerPill
            }
        }
    }

    var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)

                Capsule()
                    .fill(LinearGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.accent.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 6)
    }

    var questionCounterPill: some View {
        Text("Q\(currentIndex + 1)/\(questions.count)")
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())
    }

    var timerPill: some View {
        HStack(spacing: 5) {
            Image(systemName: "timer")
                .font(.system(size: 12, weight: .semibold))
            Text("\(Int(timerRemaining))s")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundStyle(timerColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(timerColor.opacity(0.15), in: Capsule())
        .overlay(Capsule().strokeBorder(timerColor.opacity(0.3), lineWidth: 1))
        .animation(.easeInOut(duration: 0.3), value: timerColor)
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

        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(isCorrect ? .success : .error)

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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceToNext()
        }
    }

    func advanceToNext() {
        if currentIndex + 1 < questions.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
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
