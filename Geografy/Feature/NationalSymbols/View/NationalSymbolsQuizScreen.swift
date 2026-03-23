import SwiftUI

struct NationalSymbolsQuizScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var symbolsService = NationalSymbolsService()
    @State private var countryDataService = CountryDataService()
    @State private var questions: [SymbolQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var isGameOver = false

    private let totalQuestions = 15

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if isGameOver {
                gameOverContent
            } else if questions.isEmpty {
                ProgressView()
                    .tint(DesignSystem.Color.accent)
            } else {
                quizContent
            }
        }
        .navigationTitle("National Symbols Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleCloseButton { dismiss() }
            }
        }
        .task { loadQuiz() }
    }
}

// MARK: - Quiz Content

private extension NationalSymbolsQuizScreen {
    var quizContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                progressHeader
                    .padding(.horizontal, DesignSystem.Spacing.md)
                questionCard
                    .padding(.horizontal, DesignSystem.Spacing.md)
                answersSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
    }

    var progressHeader: some View {
        HStack {
            Text("\(currentIndex + 1) / \(questions.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            scoreBadge
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
                questionTypeLabel
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                progressBar
                    .padding(.horizontal, DesignSystem.Spacing.md)
                questionPrompt
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
    }

    var questionTypeLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: currentQuestion.symbolType.icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(currentQuestion.symbolType.displayName)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
            Spacer()
        }
    }

    var progressBar: some View {
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
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
        .frame(height: 4)
    }

    var progressFraction: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex + 1) / CGFloat(questions.count)
    }

    var questionPrompt: some View {
        Text(currentQuestion.prompt)
            .font(DesignSystem.Font.title2)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var answersSection: some View {
        if currentQuestion.answerMode == .flags {
            flagAnswersGrid
        } else {
            textAnswersStack
        }
    }

    var flagAnswersGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(currentQuestion.options, id: \.self) { option in
                flagAnswerButton(for: option)
            }
        }
    }

    func flagAnswerButton(for countryCode: String) -> some View {
        let country = countryDataService.countries.first { $0.code == countryCode }
        let isSelected = selectedAnswer == countryCode
        let isCorrect = countryCode == currentQuestion.correctAnswer
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
                        answerOverlay(isCorrect: isCorrect, isSelected: isSelected)
                    }
                }
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(selectedAnswer != nil)
    }

    var textAnswersStack: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(currentQuestion.options, id: \.self) { option in
                textAnswerButton(for: option)
            }
        }
    }

    func textAnswerButton(for option: String) -> some View {
        let isSelected = selectedAnswer == option
        let isCorrect = option == currentQuestion.correctAnswer
        let showResult = selectedAnswer != nil

        return Button { selectAnswer(option) } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Text(option)
                    .font(DesignSystem.Font.body)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showResult {
                    let iconName = isCorrect
                        ? "checkmark.circle.fill"
                        : (isSelected ? "xmark.circle.fill" : "circle")
                    let iconColor: Color = isCorrect
                        ? DesignSystem.Color.success
                        : (isSelected ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                    Image(systemName: iconName)
                        .foregroundStyle(iconColor)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                showResult
                    ? (isCorrect
                        ? DesignSystem.Color.success.opacity(0.15)
                        : (isSelected ? DesignSystem.Color.error.opacity(0.15) : DesignSystem.Color.cardBackground))
                    : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
        .disabled(selectedAnswer != nil)
    }

    func answerOverlay(isCorrect: Bool, isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(
                    isCorrect
                        ? DesignSystem.Color.success.opacity(0.25)
                        : (isSelected ? DesignSystem.Color.error.opacity(0.25) : .clear)
                )
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

private extension NationalSymbolsQuizScreen {
    var gameOverContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            resultIcon
            resultTexts
            scoreStats
            Spacer()
            playAgainButton
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
            Image(systemName: gradeIcon)
                .font(.system(size: 52))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var resultTexts: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(gradeTitle)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(gradeSubtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var scoreStats: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            statTile(
                value: "\(score)", label: "Correct",
                icon: "checkmark.circle.fill", color: DesignSystem.Color.success
            )
            statTile(
                value: "\(questions.count)", label: "Questions",
                icon: "list.bullet", color: DesignSystem.Color.accent
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
    }

    func statTile(value: String, label: String, icon: String, color: Color) -> some View {
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

    var playAgainButton: some View {
        GlassButton("Play Again", fullWidth: true) {
            restartQuiz()
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

    var gradeSubtitle: String {
        switch gradeFraction {
        case 0.8...: "You know your national symbols brilliantly"
        case 0.6..<0.8: "Good knowledge of national symbols"
        case 0.4..<0.6: "Keep exploring countries and their symbols"
        default: "Every expert starts somewhere — keep going!"
        }
    }

    var gradeIcon: String {
        switch gradeFraction {
        case 0.8...: "trophy.fill"
        case 0.6..<0.8: "star.fill"
        case 0.4..<0.6: "globe"
        default: "book.fill"
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
                .map { $0.countryCode }
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

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = answer
        let isCorrect = answer == currentQuestion.correctAnswer
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
        let nextIndex = currentIndex + 1
        if nextIndex >= questions.count {
            withAnimation { isGameOver = true }
        } else {
            withAnimation {
                currentIndex = nextIndex
                selectedAnswer = nil
            }
        }
    }

    func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
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
