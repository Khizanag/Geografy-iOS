import SwiftUI

struct NationalSymbolsQuizScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var symbolsService = NationalSymbolsService()
    @State private var countryDataService = CountryDataService()
    @State private var questions: [SymbolQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedOptionIndex: Int?
    @State private var showFeedback = false
    @State private var isGameOver = false

    private let totalQuestions = 15

    var body: some View {
        Group {
            if isGameOver {
                gameOverContent
            } else if questions.isEmpty {
                ProgressView().tint(DesignSystem.Color.accent)
            } else {
                quizContent
            }
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("National Symbols Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircleCloseButton { dismiss() }
            }
        }
        .task { loadQuiz() }
    }
}

// MARK: - Quiz Content

private extension NationalSymbolsQuizScreen {
    var quizContent: some View {
        VStack(spacing: 0) {
            progressSection
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
                .padding(.bottom, DesignSystem.Spacing.md)
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    questionPromptCard
                    answerOptions
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
    }

    var progressSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(progress: progressFraction)
            QuestionCounterPill(current: currentIndex + 1, total: questions.count)
        }
    }

    var progressFraction: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }

    var questionPromptCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                symbolTypeLabel
                Text(currentQuestion.prompt)
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

    var symbolTypeLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: currentQuestion.symbolType.icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(currentQuestion.symbolType.displayName)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var answerOptions: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                if currentQuestion.answerMode == .flags {
                    let country = countryDataService.country(for: option)
                    QuizOptionButton(
                        text: country?.name ?? option,
                        flagCode: option,
                        state: optionState(for: index),
                        index: index
                    ) {
                        selectAnswer(at: index)
                    }
                } else {
                    QuizOptionButton(
                        text: option,
                        flagCode: nil,
                        state: optionState(for: index),
                        index: index
                    ) {
                        selectAnswer(at: index)
                    }
                }
            }
        }
    }

    func optionState(for index: Int) -> QuizOptionButton.OptionState {
        guard showFeedback else { return .default }
        let option = currentQuestion.options[index]
        if option == currentQuestion.correctAnswer { return .correct }
        if index == selectedOptionIndex { return .incorrect }
        return .disabled
    }
}

// MARK: - Game Over

private extension NationalSymbolsQuizScreen {
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
                    .font(.system(size: 44))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            Text(gradeTitle)
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

    var gradeTitle: String {
        switch gradeFraction {
        case 0.8...: "Symbol Expert!"
        case 0.6..<0.8: "Well Done!"
        case 0.4..<0.6: "Getting There!"
        default: "Keep Learning!"
        }
    }
}

// MARK: - Actions

private extension NationalSymbolsQuizScreen {
    var currentQuestion: SymbolQuestion {
        questions[currentIndex]
    }

    func loadQuiz() {
        countryDataService.loadCountries()
        buildQuestions()
    }

    func buildQuestions() {
        let symbols = symbolsService.symbols.shuffled()
        let selected = Array(symbols.prefix(totalQuestions))
        questions = selected.enumerated().map { index, symbol in
            makeQuestion(for: symbol, allSymbols: symbols, index: index)
        }
    }

    func makeQuestion(for symbol: NationalSymbol, allSymbols: [NationalSymbol], index: Int) -> SymbolQuestion {
        let useFlags = index.isMultiple(of: 2)
        let symbolType = SymbolType.allCases[index % SymbolType.allCases.count]
        let symbolValue = value(for: symbolType, in: symbol)

        if useFlags {
            let wrongCodes = allSymbols
                .filter { $0.countryCode != symbol.countryCode }
                .map(\.countryCode)
                .shuffled()
                .prefix(3)
            let options = ([symbol.countryCode] + wrongCodes).shuffled()
            return SymbolQuestion(
                prompt: "Which country's national \(symbolType.displayName.lowercased()) is the \(symbolValue)?",
                symbolType: symbolType,
                options: options,
                correctAnswer: symbol.countryCode,
                answerMode: .flags
            )
        } else {
            let wrongValues = allSymbols
                .filter { $0.countryCode != symbol.countryCode }
                .map { value(for: symbolType, in: $0) }
                .filter { !$0.isEmpty }
                .shuffled()
                .prefix(3)
            let options = ([symbolValue] + wrongValues).shuffled()
            let countryName = countryDataService.countries
                .first { $0.code == symbol.countryCode }?.name ?? symbol.countryCode
            return SymbolQuestion(
                prompt: "What is \(countryName)'s national \(symbolType.displayName.lowercased())?",
                symbolType: symbolType,
                options: options,
                correctAnswer: symbolValue,
                answerMode: .text
            )
        }
    }

    func value(for type: SymbolType, in symbol: NationalSymbol) -> String {
        switch type {
        case .animal: symbol.animal
        case .flower: symbol.flower
        case .sport: symbol.sport
        case .motto: symbol.motto.isEmpty ? symbol.funFact : symbol.motto
        }
    }

    func selectAnswer(at index: Int) {
        guard !showFeedback else { return }
        selectedOptionIndex = index
        showFeedback = true

        let option = currentQuestion.options[index]
        let isCorrect = option == currentQuestion.correctAnswer
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

private extension NationalSymbolsQuizScreen {
    struct SymbolQuestion {
        let prompt: String
        let symbolType: SymbolType
        let options: [String]
        let correctAnswer: String
        let answerMode: AnswerMode
    }

    enum AnswerMode {
        case flags
        case text
    }

    enum SymbolType: CaseIterable {
        case animal
        case flower
        case sport
        case motto

        var displayName: String {
            switch self {
            case .animal: "Animal"
            case .flower: "Flower"
            case .sport: "Sport"
            case .motto: "Motto"
            }
        }

        var icon: String {
            switch self {
            case .animal: "pawprint.fill"
            case .flower: "leaf.fill"
            case .sport: "sportscourt.fill"
            case .motto: "quote.bubble.fill"
            }
        }
    }
}
