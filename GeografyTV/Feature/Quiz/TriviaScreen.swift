import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Trivia
import SwiftUI

struct TriviaScreen: View {
    let countryDataService: CountryDataService

    @State private var questions: [TriviaQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Bool?
    @State private var showExplanation = false
    @State private var showResult = false

    var body: some View {
        ZStack {
            AmbientBlobsView(.tv)

            Group {
                if showResult {
                    resultView
                } else if let question = currentQuestion {
                    questionView(question)
                } else {
                    startView
                }
            }
        }
        .navigationTitle("True or False")
        .onExitCommand {
            if !questions.isEmpty { showResult = true }
        }
    }
}

// MARK: - Start
private extension TriviaScreen {
    var startView: some View {
        VStack(spacing: 40) {
            Image(systemName: "brain.fill")
                .font(DesignSystem.Font.displayXL)
                .foregroundStyle(DesignSystem.Color.accent)

            Text("True or False")
                .font(DesignSystem.Font.system(size: 48, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Test your geography knowledge with true/false questions")
                .font(DesignSystem.Font.system(size: 24))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Button {
                startGame()
            } label: {
                Label("Start", systemImage: "play.fill")
                    .font(DesignSystem.Font.system(size: 28, weight: .bold))
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Question
private extension TriviaScreen {
    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    func questionView(_ question: TriviaQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            Text("\(currentIndex + 1) / \(questions.count)")
                .font(DesignSystem.Font.system(size: 22, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text(question.statement)
                .font(DesignSystem.Font.system(size: 36, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 900)

            if showExplanation {
                Text(question.explanation)
                    .font(DesignSystem.Font.system(size: 24))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
                    .transition(.opacity)
            }

            HStack(spacing: 40) {
                answerButton(label: "True", icon: "checkmark.circle.fill", value: true, question: question)
                answerButton(label: "False", icon: "xmark.circle.fill", value: false, question: question)
            }
        }
        .padding(80)
    }

    func answerButton(label: String, icon: String, value: Bool, question: TriviaQuestion) -> some View {
        let isCorrect = question.isTrue == value
        let isSelected = selectedAnswer == value
        let backgroundColor = answerBackgroundColor(isCorrect: isCorrect, isSelected: isSelected)

        return Button {
            guard !showExplanation else { return }
            answer(value, question: question)
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.system(size: 32))
                Text(label)
                    .font(DesignSystem.Font.system(size: 28, weight: .bold))
            }
            .frame(width: 240)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(
                backgroundColor,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            )
        }
        .buttonStyle(.card)
        .disabled(showExplanation)
    }
}

// MARK: - Result
private extension TriviaScreen {
    var resultView: some View {
        VStack(spacing: 40) {
            Text("Results")
                .font(DesignSystem.Font.system(size: 48, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("\(score) / \(questions.count) correct")
                .font(DesignSystem.Font.system(size: 32))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Button {
                startGame()
            } label: {
                Label("Play Again", systemImage: "arrow.counterclockwise")
                    .font(DesignSystem.Font.system(size: 24, weight: .semibold))
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Helpers
private extension TriviaScreen {
    func answerBackgroundColor(isCorrect: Bool, isSelected: Bool) -> Color {
        guard showExplanation else { return DesignSystem.Color.cardBackground }
        if isCorrect { return DesignSystem.Color.success.opacity(0.3) }
        if isSelected { return DesignSystem.Color.error.opacity(0.3) }
        return DesignSystem.Color.cardBackground
    }
}

// MARK: - Actions
private extension TriviaScreen {
    func startGame() {
        questions = TriviaService()
            .generateQuestions(from: countryDataService.countries)
            .shuffled()
            .prefix(15)
            .map { $0 }
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showExplanation = false
        showResult = false
    }

    func answer(_ value: Bool, question: TriviaQuestion) {
        selectedAnswer = value
        if value == question.isTrue { score += 1 }
        showExplanation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            advanceToNext()
        }
    }

    func advanceToNext() {
        selectedAnswer = nil
        showExplanation = false
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            showResult = true
        }
    }
}
