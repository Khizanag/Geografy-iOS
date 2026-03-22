import SwiftUI

struct FlagSequenceView: View {
    let content: DailyChallenge.FlagSequenceContent
    let seed: UInt64

    @Binding var score: Int
    @Binding var currentIndex: Int

    let onFinish: () -> Void

    @State private var options: [[Country]] = []
    @State private var selectedOption: Country?
    @State private var showFeedback = false
    @State private var correctCount = 0

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            progressRow
            if currentIndex < content.countries.count {
                questionView
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .task { prepareOptions() }
    }
}

// MARK: - Progress

private extension FlagSequenceView {
    var progressRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<content.countries.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index < currentIndex
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted
                    )
                    .frame(height: 6)
            }
        }
    }
}

// MARK: - Question

private extension FlagSequenceView {
    @ViewBuilder
    var questionView: some View {
        let country = content.countries[currentIndex]
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Which country does this flag belong to?")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            FlagView(
                countryCode: country.code,
                height: DesignSystem.Size.hero
            )

            if currentIndex < options.count {
                optionsGrid(
                    options: options[currentIndex],
                    correct: country
                )
            }
        }
    }

    func optionsGrid(
        options: [Country],
        correct: Country
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(
                Array(options.enumerated()),
                id: \.element.code
            ) { index, option in
                QuizOptionButton(
                    text: option.name,
                    flagCode: nil,
                    state: optionState(
                        option: option,
                        correct: correct
                    ),
                    index: index
                ) {
                    selectOption(option, correct: correct)
                }
            }
        }
    }
}

// MARK: - Actions

private extension FlagSequenceView {
    func prepareOptions() {
        let allCountries = content.countries
        var optionSets: [[Country]] = []

        for (index, country) in allCountries.enumerated() {
            let distractors = allCountries
                .filter { $0.code != country.code }
                .seededShuffle(seed: seed &+ UInt64(index) &* 7919)
                .prefix(3)
            var shuffledOptions = [country] + Array(distractors)
            shuffledOptions = shuffledOptions.seededShuffle(
                seed: seed &+ UInt64(index) &* 3571
            )
            optionSets.append(shuffledOptions)
        }
        options = optionSets
    }

    func selectOption(_ option: Country, correct: Country) {
        guard !showFeedback else { return }
        selectedOption = option

        let isCorrect = option.code == correct.code
        if isCorrect {
            correctCount += 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            withAnimation { score = max(0, score - 200) }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advance()
        }
    }

    func advance() {
        if currentIndex + 1 < content.countries.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIndex += 1
                selectedOption = nil
                showFeedback = false
            }
        } else {
            onFinish()
        }
    }
}

// MARK: - Helpers

private extension FlagSequenceView {
    func optionState(
        option: Country,
        correct: Country
    ) -> QuizOptionButton.OptionState {
        guard showFeedback else { return .default }
        if option.code == correct.code { return .correct }
        if selectedOption?.code == option.code { return .incorrect }
        return .disabled
    }
}
