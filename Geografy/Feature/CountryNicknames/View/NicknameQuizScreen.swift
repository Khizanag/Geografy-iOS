import SwiftUI

struct NicknameQuizScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    let nicknames: [CountryNickname]
    let countryDataService: CountryDataService

    @State private var questions: [NicknameQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var isGameOver = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if isGameOver {
                gameOverContent
            } else if questions.isEmpty {
                ProgressView().tint(DesignSystem.Color.accent)
            } else {
                quizContent
            }
        }
        .navigationTitle("Nickname Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleCloseButton { dismiss() }
            }
        }
        .task { buildQuestions() }
    }
}

// MARK: - Quiz Content

private extension NicknameQuizScreen {
    var quizContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                progressHeader
                    .padding(.horizontal, DesignSystem.Spacing.md)
                nicknamePromptCard
                    .padding(.horizontal, DesignSystem.Spacing.md)
                answerOptions
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
    }

    var nicknamePromptCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "quote.bubble.fill")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Which country is this?")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.md)
                Text("\"\(currentQuestion.nickname)\"")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
    }

    var answerOptions: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(currentQuestion.options, id: \.self) { countryCode in
                answerButton(for: countryCode)
            }
        }
    }

    func answerButton(for countryCode: String) -> some View {
        let country = countryDataService.countries.first { $0.code == countryCode }
        let isSelected = selectedAnswer == countryCode
        let isCorrect = countryCode == currentQuestion.correctCountryCode
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

private extension NicknameQuizScreen {
    var gameOverContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
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
                Image(systemName: gradeFraction >= 0.8 ? "trophy.fill" : "star.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(gradeFraction >= 0.8 ? "Nickname Expert!" : "Well Played!")
                    .font(DesignSystem.Font.title)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("\(score) out of \(questions.count) correct")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            GeoButton("Play Again", style: .primary) { restartQuiz() }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            Spacer(minLength: DesignSystem.Spacing.xxl)
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
                .map { $0.countryCode }
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

    func selectAnswer(_ countryCode: String) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = countryCode
        let isCorrect = countryCode == currentQuestion.correctCountryCode
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

private extension NicknameQuizScreen {
    struct NicknameQuestion {
        let nickname: String
        let options: [String]
        let correctCountryCode: String
    }
}
