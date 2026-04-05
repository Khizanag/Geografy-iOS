import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct TriviaScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService

    @State private var questions: [TriviaQuestion] = []
    @State private var currentIndex = 0
    @State private var streak = 0
    @State private var totalAnswered = 0
    @State private var totalCorrect = 0
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
        } else if currentIndex >= questions.count {
            completionView
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
        SessionProgressView(progress: progress, current: currentIndex + 1, total: questions.count)
    }

    var cardStack: some View {
        ZStack {
            if currentIndex + 1 < questions.count {
                triviaCard(for: questions[currentIndex + 1], isBack: true)
                    .scaleEffect(0.92)
                    .offset(y: 12)
            }
            triviaCard(for: questions[currentIndex], isBack: false)
                .offset(x: cardOffset)
                .rotationEffect(.degrees(cardRotation))
                #if !os(tvOS)
                .gesture(dragGesture)
                #endif
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
    var completionView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(DesignSystem.Font.display)
                .foregroundStyle(DesignSystem.Color.success)

            Text("All Done!")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            completionStats

            Spacer()

            completionDoneButton
        }
    }

    var completionStats: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.xl) {
                completionStat(value: "\(totalCorrect)/\(totalAnswered)", label: "Correct")
                Divider().frame(height: 40)
                completionStat(value: "\(streak)", label: "Best Streak")
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func completionStat(value: String, label: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    var completionDoneButton: some View {
        GlassButton("Done", fullWidth: true) {
            dismiss()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xl)
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
        questions = Array(generated.prefix(30))
    }

    func commitAnswer(answeredTrue: Bool) {
        guard currentIndex < questions.count else { return }
        isAnimating = true
        let question = questions[currentIndex]
        let isCorrect = answeredTrue == question.isTrue
        lastAnswerWasCorrect = isCorrect
        totalAnswered += 1

        if isCorrect {
            totalCorrect += 1
            streak += 1
        } else {
            streak = 0
        }

        showExplanation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let direction: CGFloat = answeredTrue ? 500 : -500
            withAnimation(.easeIn(duration: 0.25)) {
                cardOffset = direction
                cardRotation = answeredTrue ? 20 : -20
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentIndex += 1
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
        return CGFloat(currentIndex) / CGFloat(questions.count)
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
