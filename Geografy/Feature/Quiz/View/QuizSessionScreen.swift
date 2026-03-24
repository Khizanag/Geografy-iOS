import Combine
import SwiftUI

struct QuizSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    let configuration: QuizConfiguration

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var answers: [QuizAnswer] = []
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var timerRemaining: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var startTime = Date()
    @State private var questionStartTime = Date()
    @State private var showQuitAlert = false
    @State private var showFlagPreview = false
    @State private var isPaused = false
    @State private var navigateToResult: QuizResult?
    @State private var countryDataService = CountryDataService()

    @State private var typingInput: String = ""
    @State private var showHint: Bool = false
    @State private var typingIsCorrect: Bool = false
    @State private var currentStreak: Int = 0
    @State private var showStreakBurst = false
    @Namespace private var flagNamespace

    var body: some View {
        NavigationStack {
            quizContent
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .alert("Quit Quiz?", isPresented: $showQuitAlert) {
                    quitAlertActions
                } message: {
                    Text("Your progress will be lost.")
                }
                .task { loadQuiz() }
                .onDisappear { timerCancellable?.cancel() }
                .navigationDestination(item: $navigateToResult) { result in
                    resultsDestination(for: result)
                }
        }
        .overlay { flagPreviewOverlay }
        .overlay { pauseOverlay }
    }
}

// MARK: - Body Subviews

private extension QuizSessionScreen {
    var quizContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            progressSection
            questionContent
            Spacer(minLength: 0)
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .blur(radius: isPaused ? 12 : 0)
        .allowsHitTesting(!isPaused)
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if configuration.difficulty.hasTimer {
            ToolbarItem(placement: .topBarLeading) {
                pauseButton
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            CircleCloseButton { showQuitAlert = true }
        }
    }

    var pauseButton: some View {
        Button { togglePause() } label: {
            Image(systemName: "pause.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .buttonStyle(.plain)
        .disabled(showFeedback)
        .opacity(showFeedback ? 0.4 : 1)
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { dismiss() }
    }

    func resultsDestination(for result: QuizResult) -> some View {
        QuizResultsScreen(
            result: result,
            onPlayAgain: {
                navigateToResult = nil
                loadQuiz()
            },
            onDone: { dismiss() }
        )
    }

    @ViewBuilder
    var flagPreviewOverlay: some View {
        if showFlagPreview, let flagCode = currentQuestion?.promptFlag {
            ZoomableFlagView(countryCode: flagCode, namespace: flagNamespace) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showFlagPreview = false
                }
            }
        }
    }

    @ViewBuilder
    var pauseOverlay: some View {
        if isPaused {
            VStack(spacing: DesignSystem.Spacing.xl) {
                pauseIcon
                pauseInfo
                resumeButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Color.background.opacity(0.5).ignoresSafeArea())
            .transition(.opacity)
        }
    }

    var pauseIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 80, height: 80)
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var pauseInfo: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Paused")
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("\(Int(timerRemaining))s remaining")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text("Question \(currentIndex + 1) of \(questions.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var resumeButton: some View {
        Button { togglePause() } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "play.fill")
                Text("Resume")
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(width: 200)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }

}

// MARK: - Subviews

private extension QuizSessionScreen {
    var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                progressBar
                if currentStreak >= 2 {
                    streakBadge
                        .transition(.scale.combined(with: .opacity))
                } else {
                    questionCounterPill
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStreak)

            if configuration.difficulty.hasTimer {
                timerPill
            }
        }
    }

    var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11, weight: .black))
            Text("\(currentStreak)×")
                .font(.system(size: 13, weight: .black, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            LinearGradient(
                colors: [DesignSystem.Color.orange, DesignSystem.Color.error],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: Capsule()
        )
        .shadow(color: DesignSystem.Color.error.opacity(0.4), radius: 8, y: 2)
        .scaleEffect(showStreakBurst ? 1.25 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: showStreakBurst)
    }

    var progressBar: some View {
        SessionProgressBar(progress: progress)
    }

    var questionCounterPill: some View {
        QuestionCounterPill(current: currentIndex + 1, total: questions.count)
    }

    var timerPill: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            timerProgressRing
            Text("\(Int(timerRemaining))s")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundStyle(timerColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(timerColor.opacity(0.15), in: Capsule())
        .overlay(Capsule().strokeBorder(timerColor.opacity(0.3), lineWidth: 1))
        .scaleEffect(timerRemaining <= configuration.difficulty.timerDuration * 0.25 ? 1.08 : 1.0)
        .opacity(timerPulseOpacity)
        .animation(.easeInOut(duration: 0.3), value: timerRemaining)
        .animation(.easeInOut(duration: 0.3), value: timerColor)
    }

    var timerProgressRing: some View {
        ZStack {
            Circle()
                .stroke(timerColor.opacity(0.2), lineWidth: 2)
            Circle()
                .trim(from: 0, to: timerProgress)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timerProgress)
        }
        .frame(width: 16, height: 16)
    }

    @ViewBuilder
    var questionContent: some View {
        if let question = currentQuestion {
            switch configuration.answerMode {
            case .multipleChoice:
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
                .transition(questionTransition)
            case .typing:
                QuizTypingInputView(
                    question: question,
                    quizType: configuration.type,
                    showFeedback: showFeedback,
                    isCorrectAnswer: typingIsCorrect,
                    typingInput: $typingInput,
                    showHint: $showHint,
                    showFlagPreview: $showFlagPreview,
                    onSubmit: { submitTypingAnswer() }
                )
                .id(question.id)
                .transition(questionTransition)
            }
        }
    }

    var questionTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - Actions

private extension QuizSessionScreen {
    func togglePause() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPaused.toggle()
        }
        if isPaused {
            timerCancellable?.cancel()
        } else {
            startTimer()
        }
    }

    func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil else { return }
        timerCancellable?.cancel()
        selectedOptionID = optionID

        let question = questions[currentIndex]
        let isCorrect = optionID == question.correctOptionID
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        // TODO: Speed bonus for future implementation
        // - Answered in < 3s of timerDuration: "Lightning Fast" bonus XP
        // - Answered in < 5s of timerDuration: "Quick" bonus XP

        if isCorrect {
            hapticsService.notification(.success)
            currentStreak += 1
            if currentStreak >= 2 {
                showStreakBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showStreakBurst = false
                }
            }
        } else {
            hapticsService.impact(.light)
            currentStreak = 0
        }

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
                typingInput = ""
                showHint = false
                typingIsCorrect = false
                questionStartTime = Date()
                timerRemaining = configuration.difficulty.timerDuration
            }
            startTimer()
        } else {
            timerCancellable?.cancel()
            finishQuiz()
        }
    }

    func submitTypingAnswer() {
        guard !showFeedback else { return }
        let trimmedInput = typingInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedInput.isEmpty else { return }

        timerCancellable?.cancel()

        let question = questions[currentIndex]
        let isCorrect = isTypingAnswerCorrect(input: trimmedInput, question: question)
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        if isCorrect {
            hapticsService.notification(.success)
            currentStreak += 1
            if currentStreak >= 2 {
                showStreakBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showStreakBurst = false
                }
            }
        } else {
            hapticsService.impact(.light)
            currentStreak = 0
        }

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: isCorrect ? question.correctOptionID : nil,
            isCorrect: isCorrect,
            timeSpent: timeSpent,
        )
        answers.append(answer)
        typingIsCorrect = isCorrect

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            advanceToNext()
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
        typingInput = ""
        showHint = false
        typingIsCorrect = false
        currentStreak = 0
        showStreakBurst = false
        startTime = Date()
        questionStartTime = Date()
        timerRemaining = configuration.difficulty.timerDuration
        startTimer()
    }
}

// MARK: - Timer

private extension QuizSessionScreen {
    func startTimer() {
        timerCancellable?.cancel()
        guard configuration.difficulty.hasTimer else { return }

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard !showFeedback, !isPaused else { return }

                withAnimation(.easeInOut(duration: 0.3)) {
                    timerRemaining -= 1
                }

                if timerRemaining <= 0 {
                    handleTimerExpired()
                }
            }
    }

    func handleTimerExpired() {
        timerCancellable?.cancel()

        let question = questions[currentIndex]
        let timeSpent = configuration.difficulty.timerDuration

        hapticsService.impact(.light)
        currentStreak = 0

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: nil,
            isCorrect: false,
            timeSpent: timeSpent
        )
        answers.append(answer)
        typingIsCorrect = false

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceToNext()
        }
    }
}

// MARK: - Helpers

private extension QuizSessionScreen {
    func isTypingAnswerCorrect(input: String, question: QuizQuestion) -> Bool {
        let normalizedInput = normalizeText(input)
        return makeAcceptableAnswers(for: question).contains { normalizeText($0) == normalizedInput }
    }

    func normalizeText(_ string: String) -> String {
        string
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    func makeAcceptableAnswers(for question: QuizQuestion) -> [String] {
        var answers: [String] = []

        if let correctOption = question.options.first(where: { $0.id == question.correctOptionID }),
           let text = correctOption.text {
            answers.append(text)
        }

        if configuration.type == .capitalQuiz {
            answers += question.correctCountry.allCapitals.map { $0.name }
            answers.append(question.correctCountry.capital)
        }

        answers.append(question.correctCountry.name)

        return answers.filter { !$0.isEmpty }
    }

    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }

    var timerProgress: CGFloat {
        guard configuration.difficulty.timerDuration > 0 else { return 0 }
        return timerRemaining / configuration.difficulty.timerDuration
    }

    var timerPulseOpacity: Double {
        let threshold = configuration.difficulty.timerDuration * 0.4
        guard timerRemaining <= threshold else { return 1.0 }
        return timerRemaining.truncatingRemainder(dividingBy: 2) < 1 ? 0.7 : 1.0
    }

    var timerColor: Color {
        let duration = configuration.difficulty.timerDuration
        return if timerRemaining <= duration * 0.25 {
            DesignSystem.Color.error
        } else if timerRemaining <= duration * 0.5 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.accent
        }
    }
}
