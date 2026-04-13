import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Quiz
import Geografy_Core_Service
import SwiftUI

public struct TriviaScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    @State private var questions: [TriviaQuestion] = []
    @State private var session = QuizSession(
        configuration: QuizSession.Configuration(
            totalQuestions: 30,
            initialLives: 0,
            xpPerCorrect: 10,
            streakBonusEvery: 3,
            timePerQuestion: nil
        )
    )
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var swipeHint: SwipeHint = .none
    @State private var showExplanation = false
    @State private var lastAnswerWasCorrect: Bool?
    @State private var isAnimating = false

    private let service = TriviaService()

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        contentSwitcher
            .background { backgroundView }
            .navigationTitle("Trivia")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                loadQuestions()
            }
    }
}

// MARK: - Subviews
private extension TriviaScreen {
    @ViewBuilder
    var contentSwitcher: some View {
        if questions.isEmpty {
            loadingView
        } else if case .complete(let summary) = session.state {
            completionView(summary: summary)
        } else {
            gameContent
        }
    }

    var backgroundView: some View {
        DesignSystem.Color.background
            .ignoresSafeArea()
    }

    var loadingView: some View {
        ProgressView()
            .tint(DesignSystem.Color.accent)
    }

    var gameContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            streakAndProgressBar

            Spacer()

            cardStack

            swipeLabels

            Spacer()

            instructionLabel
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.lg)
    }

    var streakAndProgressBar: some View {
        SessionProgressView(
            progress: progress,
            current: session.questionIndex + 1,
            total: questions.count
        )
    }

    var cardStack: some View {
        ZStack {
            if session.questionIndex + 1 < questions.count {
                triviaCard(for: questions[session.questionIndex + 1], isBack: true)
                    .scaleEffect(0.92)
                    .offset(y: 12)
            }
            if session.questionIndex < questions.count {
                triviaCard(for: questions[session.questionIndex], isBack: false)
                    .offset(x: cardOffset)
                    .rotationEffect(.degrees(cardRotation))
                    #if !os(tvOS)
                    .gesture(dragGesture)
                    #endif
            }
        }
    }

    func triviaCard(for question: TriviaQuestion, isBack: Bool) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Text(question.statement)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, DesignSystem.Spacing.xs)

                if showExplanation, !isBack, let correct = lastAnswerWasCorrect {
                    Divider()
                    explanationView(for: question, wasCorrect: correct)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.xl)
        }
        .overlay(swipeOverlay(isBack: isBack))
        .frame(maxWidth: .infinity)
        .frame(height: 260)
    }

    func swipeOverlay(isBack: Bool) -> some View {
        Group {
            if !isBack {
                ZStack {
                    if swipeHint == .trueSwipe {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(DesignSystem.Color.success, lineWidth: 3)
                    } else if swipeHint == .falseSwipe {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(DesignSystem.Color.error, lineWidth: 3)
                    }
                }
            }
        }
    }

    func explanationView(for question: TriviaQuestion, wasCorrect: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(wasCorrect ? DesignSystem.Color.success : DesignSystem.Color.error)
            Text(question.explanation)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(3)
        }
    }

    var swipeLabels: some View {
        HStack {
            swipeLabel(text: "FALSE", color: DesignSystem.Color.error, opacity: falseOpacity)
            Spacer()
            swipeLabel(text: "TRUE", color: DesignSystem.Color.success, opacity: trueOpacity)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    func swipeLabel(text: String, color: Color, opacity: Double) -> some View {
        Text(text)
            .font(DesignSystem.Font.headline)
            .fontWeight(.black)
            .foregroundStyle(color)
            .opacity(opacity)
    }

    var instructionLabel: some View {
        Text("Swipe right for TRUE · Swipe left for FALSE")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }
}

// MARK: - Completion
private extension TriviaScreen {
    func completionView(summary: QuizResultSummary) -> some View {
        QuizResultScreen(
            summary: summary,
            onRetry: retry,
            onContinue: coordinator.dismiss
        )
    }
}

#if !os(tvOS)
// MARK: - Drag Gesture
private extension TriviaScreen {
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isAnimating, !showExplanation else { return }
                cardOffset = value.translation.width
                cardRotation = value.translation.width / 20
                let xOffset = value.translation.width
                swipeHint = xOffset > 20 ? .trueSwipe : xOffset < -20 ? .falseSwipe : .none
            }
            .onEnded { value in
                guard !isAnimating else { return }
                let threshold: CGFloat = 80
                if value.translation.width > threshold {
                    commitAnswer(answeredTrue: true)
                } else if value.translation.width < -threshold {
                    commitAnswer(answeredTrue: false)
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        cardOffset = 0
                        cardRotation = 0
                        swipeHint = .none
                    }
                }
            }
    }
}
#endif

// MARK: - Actions
private extension TriviaScreen {
    func loadQuestions() {
        let generated = service.generateQuestions(from: countryDataService.countries)
        let pool = Array(generated.prefix(30))
        questions = pool
        session = QuizSession(
            configuration: QuizSession.Configuration(
                totalQuestions: pool.count,
                initialLives: 0,
                xpPerCorrect: 10,
                streakBonusEvery: 3,
                timePerQuestion: nil
            )
        )
        session.start()
    }

    func retry() {
        loadQuestions()
    }

    func commitAnswer(answeredTrue: Bool) {
        guard session.questionIndex < questions.count else { return }
        isAnimating = true
        let question = questions[session.questionIndex]
        let isCorrect = answeredTrue == question.isTrue
        lastAnswerWasCorrect = isCorrect
        session.submitAnswer(isCorrect: isCorrect)
        showExplanation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let direction: CGFloat = answeredTrue ? 500 : -500
            withAnimation(.easeIn(duration: 0.25)) {
                cardOffset = direction
                cardRotation = answeredTrue ? 20 : -20
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                session.advance()
                cardOffset = 0
                cardRotation = 0
                swipeHint = .none
                showExplanation = false
                lastAnswerWasCorrect = nil
                isAnimating = false
            }
        }
    }
}

// MARK: - Helpers
private extension TriviaScreen {
    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(session.questionIndex) / CGFloat(questions.count)
    }

    var trueOpacity: Double {
        guard cardOffset > 0 else { return 0 }
        return min(1, cardOffset / 80)
    }

    var falseOpacity: Double {
        guard cardOffset < 0 else { return 0 }
        return min(1, -cardOffset / 80)
    }

    enum SwipeHint: Equatable {
        case none
        case trueSwipe
        case falseSwipe
    }
}
