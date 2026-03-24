import SwiftUI

struct LandmarkQuizScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var quizService = LandmarkQuizService()
    @State private var countryDataService = CountryDataService()
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var timeRemaining: Int = 20
    @State private var isGameOver = false
    @State private var appeared = false
    @State private var answerOptions: [String] = []
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if isGameOver {
                gameOverContent
            } else {
                quizContent
            }
        }
        .navigationTitle("Landmark Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .task { loadQuiz() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
        .onDisappear { stopTimer() }
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    headerBar
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    questionCard
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    answersGrid
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.top, DesignSystem.Spacing.md)
            }
        }
    }

    var headerBar: some View {
        HStack {
            timerBadge
            Spacer()
            scoreBadge
        }
    }

    var timerBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "timer")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(timerColor)
            Text("\(timeRemaining)s")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(timerColor)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: timeRemaining)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(timerColor.opacity(0.15), in: Capsule())
    }

    var timerColor: Color {
        switch timeRemaining {
        case 11...: DesignSystem.Color.success
        case 6...10: DesignSystem.Color.warning
        default: DesignSystem.Color.error
        }
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

    var questionCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                categoryHeader
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                progressIndicator
                    .padding(.horizontal, DesignSystem.Spacing.md)
                questionText
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
    }

    var categoryHeader: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: currentQuestion.category.icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(currentQuestion.category.displayName)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
            Spacer()
            Text("\(currentQuestionIndex + 1) / \(quizService.questions.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var progressIndicator: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(height: 4)
                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(
                        width: geometry.size.width * progressFraction,
                        height: 4
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentQuestionIndex)
            }
        }
        .frame(height: 4)
    }

    var progressFraction: CGFloat {
        guard !quizService.questions.isEmpty else { return 0 }
        return CGFloat(currentQuestionIndex + 1) / CGFloat(quizService.questions.count)
    }

    var questionText: some View {
        Text(currentQuestion.hint)
            .font(DesignSystem.Font.title2)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    var answersGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(answerOptions, id: \.self) { countryCode in
                answerButton(for: countryCode)
            }
        }
    }

    func answerButton(for countryCode: String) -> some View {
        let country = countryDataService.countries.first { $0.code == countryCode }
        let isSelected = selectedAnswer == countryCode
        let isCorrect = countryCode == currentQuestion.answerCountryCode
        let showResult = selectedAnswer != nil

        return Button { selectAnswer(countryCode) } label: {
            CardView {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: countryCode, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                    Text(country?.name ?? countryCode)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(DesignSystem.Spacing.sm)
                .frame(maxWidth: .infinity)
                .overlay {
                    if showResult {
                        resultOverlay(isCorrect: isCorrect, isSelected: isSelected)
                    }
                }
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(selectedAnswer != nil)
    }

    func resultOverlay(isCorrect: Bool, isSelected: Bool) -> some View {
        ZStack {
            let fillColor: Color = isCorrect
                ? DesignSystem.Color.success.opacity(0.25)
                : (isSelected ? DesignSystem.Color.error.opacity(0.25) : .clear)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(fillColor)
            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.success)
            } else if isSelected {
                Image(systemName: "xmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.error)
            }
        }
    }
}

// MARK: - Game Over

private extension LandmarkQuizScreen {
    var gameOverContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            resultIcon
            resultTitle
            scoreDisplay
            Spacer()
            restartButton
                .padding(.horizontal, DesignSystem.Spacing.xl)
            Spacer(minLength: DesignSystem.Spacing.xxl)
        }
    }

    var resultIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            Image(systemName: scoreGrade.icon)
                .font(.system(size: 52))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var resultTitle: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(scoreGrade.title)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(scoreGrade.subtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var scoreDisplay: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            scoreTile(value: "\(score)", label: "Score", icon: "star.fill", color: DesignSystem.Color.warning)
            scoreTile(
                value: "\(score)/\(quizService.questions.count)",
                label: "Correct",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
    }

    func scoreTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var restartButton: some View {
        GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true) {
            restartQuiz()
        }
    }

    struct ScoreGrade {
        let title: String
        let subtitle: String
        let icon: String
    }

    var scoreGrade: ScoreGrade {
        let total = quizService.questions.count
        let fraction = total > 0 ? Double(score) / Double(total) : 0
        return switch fraction {
        case 0.8...:
            ScoreGrade(title: "Geo Expert!", subtitle: "Outstanding knowledge of world landmarks", icon: "trophy.fill")
        case 0.6..<0.8:
            ScoreGrade(title: "Well Done!", subtitle: "Great understanding of world geography", icon: "star.fill")
        case 0.4..<0.6:
            ScoreGrade(title: "Getting There!", subtitle: "Keep exploring the world", icon: "globe")
        default:
            ScoreGrade(title: "Keep Learning!", subtitle: "Every expert was once a beginner", icon: "book.fill")
        }
    }
}

// MARK: - Actions

private extension LandmarkQuizScreen {
    var currentQuestion: LandmarkQuestion {
        quizService.questions[currentQuestionIndex]
    }

    func loadQuiz() {
        countryDataService.loadCountries()
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
        stopTimer()
        selectedAnswer = countryCode
        let isCorrect = countryCode == currentQuestion.answerCountryCode
        if isCorrect {
            score += 1
            hapticsService.impact(.medium)
        } else {
            hapticsService.notification(.error)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    selectAnswer("")
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
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
