import SwiftUI
import GeografyDesign
import GeografyCore

struct MapPuzzleScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    let continent: Country.Continent

    @State private var questions: [PuzzleQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedOptionIndex: Int?
    @State private var showResult = false
    @State private var correctCount = 0
    @State private var showSummary = false

    var body: some View {
        Group {
            if showSummary {
                summaryView
            } else if questions.isEmpty {
                loadingView
            } else {
                puzzleContent
            }
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("\(continent.displayName) Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
        }
        .task {
            buildQuestions()
        }
    }
}

// MARK: - Subviews
private extension MapPuzzleScreen {
    var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
            Text("Building puzzle…")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var puzzleContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                progressBar
                if currentIndex < questions.count {
                    questionCard
                    optionsGrid
                    if selectedOptionIndex != nil {
                        nextButton
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var progressBar: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer()
                Text("\(correctCount) correct")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.success)
            }
            ProgressView(value: Double(currentIndex), total: Double(questions.count))
                .tint(DesignSystem.Color.accent)
        }
    }

    var questionCard: some View {
        let question = questions[currentIndex]
        return CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Which region is…")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .textCase(.uppercase)
                    .kerning(0.8)

                FlagView(countryCode: question.country.code, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))

                Text(question.country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Select the correct region on the map")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.lg)
        }
    }

    var optionsGrid: some View {
        let question = questions[currentIndex]
        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                optionButton(option: option, index: index, question: question)
            }
        }
    }

    func optionButton(option: Country, index: Int, question: PuzzleQuestion) -> some View {
        let isSelected = selectedOptionIndex == index
        let isCorrect = option.code == question.country.code
        let revealed = selectedOptionIndex != nil

        return Button {
            guard selectedOptionIndex == nil else { return }
            selectedOptionIndex = index
            if isCorrect {
                correctCount += 1
                hapticsService.notification(.success)
            } else {
                hapticsService.notification(.error)
            }
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: option.code, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                    Text(option.name)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            optionTextColor(isSelected: isSelected, isCorrect: isCorrect, revealed: revealed)
                        )
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer()
                    if revealed {
                        resultIcon(isSelected: isSelected, isCorrect: isCorrect)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
                .background(optionBackground(isSelected: isSelected, isCorrect: isCorrect, revealed: revealed))
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(revealed)
    }

    func resultIcon(isSelected: Bool, isCorrect: Bool) -> some View {
        Group {
            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DesignSystem.Color.success)
            } else if isSelected {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(DesignSystem.Color.error)
            }
        }
        .font(DesignSystem.Font.callout)
    }

    var nextButton: some View {
        GeoButton(currentIndex + 1 < questions.count ? "Next Question" : "See Results") {
            if currentIndex + 1 < questions.count {
                currentIndex += 1
                selectedOptionIndex = nil
            } else {
                showSummary = true
            }
        }
    }
}

// MARK: - Summary
private extension MapPuzzleScreen {
    var summaryView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            summaryIcon
            summaryText
            scoreCard
            Spacer()
            restartButton
        }
        .padding(DesignSystem.Spacing.md)
    }

    var summaryIcon: some View {
        let isPassing = correctCount >= questions.count / 2
        return Image(systemName: isPassing ? "star.fill" : "arrow.clockwise.circle.fill")
            .font(DesignSystem.Font.display)
            .foregroundStyle(isPassing ? DesignSystem.Color.warning : DesignSystem.Color.accent)
    }

    var summaryText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(summaryTitle)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("You got \(correctCount) out of \(questions.count) correct")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    var scoreCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.lg) {
                scoreStatView(value: "\(correctCount)", label: "Correct", color: DesignSystem.Color.success)
                Divider()
                let incorrectCount = questions.count - correctCount
                scoreStatView(value: "\(incorrectCount)", label: "Incorrect", color: DesignSystem.Color.error)
                Divider()
                scoreStatView(
                    value: "\(Int((Double(correctCount) / Double(questions.count)) * 100))%",
                    label: "Accuracy",
                    color: DesignSystem.Color.accent
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    func scoreStatView(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    var restartButton: some View {
        GeoButton("Play Again") {
            reset()
        }
    }
}

// MARK: - Actions
private extension MapPuzzleScreen {
    func buildQuestions() {
        let continentCountries = countryDataService.countries.filter { $0.continent == continent }
        guard continentCountries.count >= 4 else { return }

        let shuffled = continentCountries.shuffled()
        let questionCountries = Array(shuffled.prefix(min(10, shuffled.count)))

        questions = questionCountries.map { country in
            var options = [country]
            let pool = continentCountries.filter { $0.code != country.code }.shuffled()
            options += Array(pool.prefix(3))
            options.shuffle()
            return PuzzleQuestion(country: country, options: options)
        }
    }

    func reset() {
        currentIndex = 0
        selectedOptionIndex = nil
        correctCount = 0
        showSummary = false
        buildQuestions()
    }
}

// MARK: - Helpers
private extension MapPuzzleScreen {
    struct PuzzleQuestion {
        let country: Country
        let options: [Country]
    }

    var summaryTitle: String {
        let fraction = Double(correctCount) / Double(questions.count)
        return switch fraction {
        case 0.8...: "Excellent!"
        case 0.6..<0.8: "Well Done!"
        case 0.4..<0.6: "Good Try!"
        default: "Keep Practicing!"
        }
    }

    func optionTextColor(isSelected: Bool, isCorrect: Bool, revealed: Bool) -> Color {
        guard revealed else { return DesignSystem.Color.textPrimary }
        if isCorrect { return DesignSystem.Color.success }
        if isSelected { return DesignSystem.Color.error }
        return DesignSystem.Color.textSecondary
    }

    func optionBackground(isSelected: Bool, isCorrect: Bool, revealed: Bool) -> Color {
        guard revealed else { return .clear }
        if isCorrect { return DesignSystem.Color.success.opacity(0.12) }
        if isSelected { return DesignSystem.Color.error.opacity(0.12) }
        return .clear
    }
}
