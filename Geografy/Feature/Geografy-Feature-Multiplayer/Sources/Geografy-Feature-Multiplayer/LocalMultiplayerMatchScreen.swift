#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Quiz
import SwiftUI

public struct LocalMultiplayerMatchScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var selectedOptionID: UUID?
    @State private var answerStartTime = Date()

    public var body: some View {
        VStack(spacing: 0) {
            scoreBar
            progressBar
            questionContent
        }
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .onChange(of: coordinator.currentIndex) {
            selectedOptionID = nil
            answerStartTime = Date()
        }
    }
}

// MARK: - Score Bar
private extension LocalMultiplayerMatchScreen {
    var scoreBar: some View {
        HStack {
            scorePill(label: "You", score: coordinator.playerScore, color: DesignSystem.Color.accent)
            Spacer()
            QuestionCounterPill(current: coordinator.currentIndex + 1, total: coordinator.questions.count)
            Spacer()
            scorePill(
                label: coordinator.opponent?.displayName ?? "Opponent",
                score: coordinator.opponentScore,
                color: DesignSystem.Color.error
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    func scorePill(label: String, score: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(score)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.black)
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
        .frame(minWidth: 60)
    }
}

// MARK: - Progress
private extension LocalMultiplayerMatchScreen {
    var progressBar: some View {
        SessionProgressBar(
            progress: Double(coordinator.currentIndex + (coordinator.playerAnsweredCurrent ? 1 : 0))
                / Double(max(coordinator.questions.count, 1))
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Question
private extension LocalMultiplayerMatchScreen {
    @ViewBuilder
    var questionContent: some View {
        if coordinator.currentIndex < coordinator.questions.count {
            let question = coordinator.questions[coordinator.currentIndex]

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    questionPrompt(question)
                    optionsGrid(question)
                    opponentStatus
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.md)
            }
        }
    }

    func questionPrompt(_ question: QuizQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let flagCode = question.promptFlag {
                FlagView(countryCode: flagCode, height: 80)
                    .geoShadow(.elevated)
            }

            Text(question.promptText)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
    }

    func optionsGrid(_ question: QuizQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                QuizOptionButton(
                    text: option.text,
                    flagCode: option.flagCode,
                    state: optionState(for: option.id, question: question),
                    index: index,
                    action: { selectOption(option.id) }
                )
            }
        }
    }

    var opponentStatus: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(
                    coordinator.opponentHasAnswered
                        ? DesignSystem.Color.success
                        : DesignSystem.Color.warning
                )
                .frame(width: 6, height: 6)
            Text(
                coordinator.opponentHasAnswered
                    ? "Opponent answered"
                    : "Opponent thinking..."
            )
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.opponentHasAnswered)
    }
}

// MARK: - Actions
private extension LocalMultiplayerMatchScreen {
    func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil else { return }
        selectedOptionID = optionID
        let timeSpent = Date().timeIntervalSince(answerStartTime)

        hapticsService.impact(.light)
        coordinator.submitAnswer(optionID: optionID, timeSpent: timeSpent)
    }

    func optionState(for optionID: UUID, question: QuizQuestion) -> QuizOptionButton.OptionState {
        guard let selected = selectedOptionID else { return .default }
        if optionID == question.correctOptionID {
            return .correct
        }
        if optionID == selected {
            return .incorrect
        }
        return .disabled
    }
}
#endif
