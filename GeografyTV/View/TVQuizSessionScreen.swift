import GameController
import SwiftUI

struct TVQuizSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService

    let countryDataService: CountryDataService
    let quizType: QuizType
    let region: QuizRegion
    let difficulty: QuizDifficulty
    let questionCount: Int

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var showQuitConfirmation = false
    @State private var hasGameController = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            AmbientBlobsView(.tvQuiz)

            if showResult {
                resultView
            } else if let question = currentQuestion {
                questionView(question)
            } else {
                ProgressView("Loading…")
                    .font(.system(size: 28))
            }
        }
        .task { generateQuestions() }
        .onAppear { setupGameController() }
        .onDisappear { teardownGameController() }
        .onExitCommand {
            showQuitConfirmation = true
        }
        .confirmationDialog(
            "Quit Quiz?",
            isPresented: $showQuitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Quit", role: .destructive) { dismiss() }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Your progress will be lost.")
        }
    }
}

// MARK: - Question View

private extension TVQuizSessionScreen {
    func questionView(_ question: QuizQuestion) -> some View {
        VStack(spacing: 48) {
            headerBar

            promptSection(question)

            optionsGrid(question)

            if hasGameController {
                controllerHint
            }
        }
        .padding(80)
    }

    var headerBar: some View {
        HStack(spacing: 20) {
            Text("\(currentIndex + 1) / \(questions.count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackground)

                    Capsule()
                        .fill(DesignSystem.Color.accent)
                        .frame(width: geometry.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 10)

            Text("\(correctCount) correct")
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .focusable(false)
    }

    func promptSection(_ question: QuizQuestion) -> some View {
        VStack(spacing: 20) {
            if let flagCode = question.promptFlag {
                FlagView(countryCode: flagCode, height: 140)
            }

            HStack(spacing: 8) {
                Text(question.promptText)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                if let subject = question.promptSubject {
                    Text(subject)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .multilineTextAlignment(.center)
        }
    }

    func optionsGrid(_ question: QuizQuestion) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)],
            spacing: 24
        ) {
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                tvOptionButton(option, question: question, index: index)
            }
        }
        .frame(maxWidth: 900)
    }

    var controllerHint: some View {
        HStack(spacing: 24) {
            ForEach(Array(GamepadButton.allCases.enumerated()), id: \.element) { index, button in
                if let question = currentQuestion, index < question.options.count {
                    Label(button.label, systemImage: button.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
        }
        .focusable(false)
    }

    func tvOptionButton(_ option: QuizOption, question: QuizQuestion, index: Int) -> some View {
        let isCorrect = option.id == question.correctOptionID
        let isSelected = selectedOptionID == option.id
        let backgroundColor: Color = {
            guard showFeedback else { return DesignSystem.Color.cardBackground }
            if isCorrect { return DesignSystem.Color.success.opacity(0.3) }
            if isSelected { return DesignSystem.Color.error.opacity(0.3) }
            return DesignSystem.Color.cardBackground
        }()
        let gamepadButton = GamepadButton.allCases.indices.contains(index)
            ? GamepadButton.allCases[index]
            : nil

        return Button {
            guard !showFeedback else { return }
            selectOption(option, question: question)
        } label: {
            HStack(spacing: 16) {
                if hasGameController, let gamepadButton {
                    Image(systemName: gamepadButton.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(gamepadButton.color)
                        .frame(width: 32)
                }

                if let flagCode = option.flagCode {
                    FlagView(countryCode: flagCode, height: 40)
                }

                Text(option.text ?? "")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer()

                if showFeedback, isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(DesignSystem.Color.success)
                } else if showFeedback, isSelected, !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(DesignSystem.Color.error)
                }
            }
            .padding(24)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.card)
        .disabled(showFeedback)
    }
}

// MARK: - Gamepad Button Mapping

enum GamepadButton: CaseIterable, Hashable {
    case triangle
    case circle
    case cross
    case square

    var label: String {
        switch self {
        case .triangle: "△ Triangle"
        case .circle: "○ Circle"
        case .cross: "✕ Cross"
        case .square: "□ Square"
        }
    }

    var icon: String {
        switch self {
        case .triangle: "triangle.fill"
        case .circle: "circle.fill"
        case .cross: "xmark"
        case .square: "square.fill"
        }
    }

    var color: Color {
        switch self {
        case .triangle: .green
        case .circle: .red
        case .cross: .blue
        case .square: .pink
        }
    }
}

// MARK: - Game Controller

private extension TVQuizSessionScreen {
    func setupGameController() {
        hasGameController = GCController.controllers().contains { $0.extendedGamepad != nil }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            hasGameController = true
            bindControllerButtons()
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { _ in
            hasGameController = GCController.controllers().contains { $0.extendedGamepad != nil }
        }

        bindControllerButtons()
    }

    func teardownGameController() {
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidDisconnect, object: nil)

        for controller in GCController.controllers() {
            guard let gamepad = controller.extendedGamepad else { continue }
            gamepad.buttonA.pressedChangedHandler = nil
            gamepad.buttonB.pressedChangedHandler = nil
            gamepad.buttonX.pressedChangedHandler = nil
            gamepad.buttonY.pressedChangedHandler = nil
        }
    }

    func bindControllerButtons() {
        for controller in GCController.controllers() {
            guard let gamepad = controller.extendedGamepad else { continue }

            // △ Triangle (Y) → Option 0 (top-left)
            gamepad.buttonY.pressedChangedHandler = { _, _, pressed in
                if pressed { handleGamepadPress(index: 0) }
            }

            // ○ Circle (B) → Option 1 (top-right)
            gamepad.buttonB.pressedChangedHandler = { _, _, pressed in
                if pressed { handleGamepadPress(index: 1) }
            }

            // ✕ Cross (A) → Option 2 (bottom-left)
            gamepad.buttonA.pressedChangedHandler = { _, _, pressed in
                if pressed { handleGamepadPress(index: 2) }
            }

            // □ Square (X) → Option 3 (bottom-right)
            gamepad.buttonX.pressedChangedHandler = { _, _, pressed in
                if pressed { handleGamepadPress(index: 3) }
            }
        }
    }

    func handleGamepadPress(index: Int) {
        Task { @MainActor in
            guard !showFeedback,
                  !showResult,
                  let question = currentQuestion,
                  index < question.options.count
            else { return }

            selectOption(question.options[index], question: question)
        }
    }
}

// MARK: - Result

private extension TVQuizSessionScreen {
    var resultView: some View {
        VStack(spacing: 40) {
            Image(systemName: resultIcon)
                .font(.system(size: 80))
                .foregroundStyle(resultColor)

            Text(resultMessage)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("\(correctCount) / \(questions.count) correct")
                .font(.system(size: 32))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text("\(Int(accuracy * 100))%")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(resultColor)

            HStack(spacing: 32) {
                Button {
                    resetQuiz()
                } label: {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.card)

                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(DesignSystem.Color.accent, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.card)
            }
        }
    }

    var accuracy: Double {
        Double(correctCount) / Double(max(questions.count, 1))
    }

    var resultIcon: String {
        if accuracy >= 0.9 { return "star.fill" }
        if accuracy >= 0.7 { return "hand.thumbsup.fill" }
        if accuracy >= 0.5 { return "face.smiling" }
        return "books.vertical"
    }

    var resultColor: Color {
        if accuracy >= 0.9 { return DesignSystem.Color.warning }
        if accuracy >= 0.7 { return DesignSystem.Color.success }
        if accuracy >= 0.5 { return DesignSystem.Color.accent }
        return DesignSystem.Color.textSecondary
    }

    var resultMessage: String {
        if accuracy >= 0.9 { return "Excellent!" }
        if accuracy >= 0.7 { return "Great Job!" }
        if accuracy >= 0.5 { return "Good Effort!" }
        return "Keep Practicing!"
    }
}

// MARK: - Actions

private extension TVQuizSessionScreen {
    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }

    func generateQuestions() {
        let filteredCountries = region.filter(countryDataService.countries)
        questions = QuestionGenerator.generate(
            type: quizType,
            countries: filteredCountries,
            count: questionCount,
            optionCount: 4,
        )
    }

    func selectOption(_ option: QuizOption, question: QuizQuestion) {
        selectedOptionID = option.id
        let isCorrect = option.id == question.correctOptionID
        if isCorrect { correctCount += 1 }
        showFeedback = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            advanceToNext()
        }
    }

    func advanceToNext() {
        selectedOptionID = nil
        showFeedback = false
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            showResult = true
        }
    }

    func resetQuiz() {
        currentIndex = 0
        correctCount = 0
        selectedOptionID = nil
        showFeedback = false
        showResult = false
        generateQuestions()
        bindControllerButtons()
    }
}
