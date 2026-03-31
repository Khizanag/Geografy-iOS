import SwiftUI
import GeografyDesign
import GeografyCore

struct CapitalChainView: View {
    @Environment(HapticsService.self) private var hapticsService

    let content: DailyChallenge.CapitalChainContent

    @Binding var score: Int
    @Binding var currentStep: Int

    let onFinish: () -> Void

    @State private var selectedOption: Country?
    @State private var showFeedback = false
    @State private var correctCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                startSection
                if currentStep < content.chainSteps.count {
                    stepView(
                        step: content.chainSteps[currentStep]
                    )
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Start Section
private extension CapitalChainView {
    var startSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Starting Point")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(
                        countryCode: content.startingCountry.code,
                        height: DesignSystem.Size.md
                    )
                    VStack(alignment: .leading) {
                        Text(content.startingCapital)
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(content.startingCountry.name)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                progressDots
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var progressDots: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<content.chainSteps.count, id: \.self) { index in
                Circle()
                    .fill(
                        index < currentStep
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted
                    )
                    .frame(
                        width: DesignSystem.Spacing.xs,
                        height: DesignSystem.Spacing.xs
                    )
            }
        }
    }
}

// MARK: - Step View
private extension CapitalChainView {
    func stepView(step: DailyChallenge.ChainStep) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Find a country in \(step.continent.displayName)")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)

            Text("with capital: \(step.expectedCountry.capital)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)

            ForEach(
                Array(step.options.enumerated()),
                id: \.element.code
            ) { index, option in
                QuizOptionButton(
                    text: option.name,
                    flagCode: option.code,
                    state: optionState(
                        option: option,
                        step: step
                    ),
                    index: index
                ) {
                    selectOption(option, step: step)
                }
            }
        }
    }
}

// MARK: - Actions
private extension CapitalChainView {
    func selectOption(
        _ option: Country,
        step: DailyChallenge.ChainStep
    ) {
        guard !showFeedback else { return }
        selectedOption = option

        let isCorrect = option.code == step.expectedCountry.code
        if isCorrect {
            correctCount += 1
            hapticsService.notification(.success)
        } else {
            withAnimation { score = max(0, score - 250) }
            hapticsService.impact(.light)
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advance()
        }
    }

    func advance() {
        if currentStep + 1 < content.chainSteps.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStep += 1
                selectedOption = nil
                showFeedback = false
            }
        } else {
            onFinish()
        }
    }
}

// MARK: - Helpers
private extension CapitalChainView {
    func optionState(
        option: Country,
        step: DailyChallenge.ChainStep
    ) -> QuizOptionButton.OptionState {
        guard showFeedback else { return .default }
        if option.code == step.expectedCountry.code { return .correct }
        if selectedOption?.code == option.code { return .incorrect }
        return .disabled
    }
}
