import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct MapPuzzleScreen: View {
    // MARK: - Properties
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .largeTitle) private var summaryIconSize: CGFloat = 64
    @ScaledMetric(relativeTo: .body) private var mapHeight: CGFloat = 220

    let continent: Country.Continent

    @State private var questions: [PuzzleQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedOptionIndex: Int?
    @State private var showResult = false
    @State private var correctCount = 0
    @State private var showSummary = false
    @State private var outline: ContinentOutline?
    @State private var hasLoaded = false

    private let gameColor = DesignSystem.Color.purple

    // MARK: - Body
    var body: some View {
        mainContent
            .screenBackground()
            .navigationTitle("\(continent.displayName) Puzzle")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
            }
            .task {
                await loadMap()
            }
    }
}

// MARK: - Subviews
private extension MapPuzzleScreen {
    @ViewBuilder
    var mainContent: some View {
        if showSummary {
            summaryView
        } else if questions.isEmpty {
            if hasLoaded {
                ContentUnavailableView(
                    "Map Unavailable",
                    systemImage: "map",
                    description: Text("This region's map couldn't be loaded.")
                )
            } else {
                loadingView
            }
        } else {
            puzzleContent
        }
    }

    var loadingView: some View {
        LoadingView("Building puzzle…")
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
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            ProgressView(value: Double(currentIndex), total: Double(questions.count))
                .tint(gameColor)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    /// The country is shown only by its place on the map; its name and flag appear after answering.
    var questionCard: some View {
        let question = questions[currentIndex]
        return CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                EyebrowLabel("Which country is this?")

                if let outline {
                    ContinentOutlineView(
                        outline: outline,
                        fill: DesignSystem.Color.textTertiary.opacity(0.5),
                        highlight: ContinentOutlineView.Highlight(countryCode: question.country.code, color: gameColor)
                    )
                    .frame(height: mapHeight)
                }

                if selectedOptionIndex != nil {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        FlagView(countryCode: question.country.code, height: DesignSystem.Size.Flag.inline)
                            .accessibilityHidden(true)
                        Text(question.country.name)
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                    .accessibilityElement(children: .combine)
                } else {
                    Text("Pick the highlighted country")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            selectedOptionIndex == nil
                ? "Which country is highlighted on the map of \(continent.displayName)?"
                : "The highlighted country is \(question.country.name)."
        )
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
                #if !os(tvOS)
                hapticsService.notification(.success)
                #endif
                AccessibilityNotification.Announcement("Correct.").post()
            } else {
                #if !os(tvOS)
                hapticsService.notification(.error)
                #endif
                AccessibilityNotification.Announcement("Incorrect. The answer is \(question.country.name).").post()
            }
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // Names only: a flag would turn the map question into a flag question.
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
        .accessibilityLabel(option.name)
        .accessibilityValue(optionAccessibilityValue(isSelected: isSelected, isCorrect: isCorrect, revealed: revealed))
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
        .accessibilityHidden(true)
    }

    var nextButton: some View {
        GlassButton(currentIndex + 1 < questions.count ? "Next Question" : "See Results", fullWidth: true) {
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
        .onAppear {
            let announcement = "\(summaryTitle) You got \(correctCount) out of \(questions.count) correct."
            AccessibilityNotification.Announcement(announcement).post()
        }
    }

    var summaryIcon: some View {
        let isPassing = correctCount >= questions.count / 2
        return Image(systemName: isPassing ? "star.fill" : "arrow.clockwise.circle.fill")
            .font(DesignSystem.Font.system(size: summaryIconSize, weight: .bold))
            .foregroundStyle(isPassing ? DesignSystem.Color.warning : gameColor)
            .accessibilityHidden(true)
    }

    var summaryText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(summaryTitle)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("You got \(correctCount) out of \(questions.count) correct")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    var scoreCard: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.md))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.lg))
        let incorrectCount = questions.count - correctCount
        return CardView {
            layout {
                scoreStatView(value: "\(correctCount)", label: "Correct", color: DesignSystem.Color.success)
                Divider()
                scoreStatView(value: "\(incorrectCount)", label: "Incorrect", color: DesignSystem.Color.error)
                Divider()
                scoreStatView(
                    value: "\(Int((Double(correctCount) / Double(questions.count)) * 100))%",
                    label: "Accuracy",
                    color: gameColor
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }

    var restartButton: some View {
        GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true) {
            reset()
        }
    }
}

// MARK: - Actions
private extension MapPuzzleScreen {
    func loadMap() async {
        if outline == nil {
            let shapes = await geoJSONCache.loadShapes()
            outline = ContinentOutline(continent: continent, shapes: shapes)
        }
        buildQuestions()
        hasLoaded = true
    }

    /// Only countries drawn on the continent's map can be asked about.
    func buildQuestions() {
        guard let mappedCodes = outline.map({ Set($0.countryPaths.keys) }) else { return }
        let continentCountries = countryDataService.countries.filter {
            $0.continent == continent && mappedCodes.contains($0.code)
        }
        let questionCount = MapPuzzleRules.questionCount(forCountryCount: continentCountries.count)
        guard questionCount > 0 else { return }

        let questionCountries = Array(continentCountries.shuffled().prefix(questionCount))

        questions = questionCountries.map { country in
            var options = [country]
            let pool = continentCountries.filter { $0.code != country.code }.shuffled()
            options += Array(pool.prefix(MapPuzzleRules.optionsPerQuestion - 1))
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

    func optionAccessibilityValue(isSelected: Bool, isCorrect: Bool, revealed: Bool) -> String {
        guard revealed else { return "" }
        if isCorrect { return isSelected ? "Your answer, correct" : "Correct answer" }
        if isSelected { return "Your answer, incorrect" }
        return ""
    }

    func optionBackground(isSelected: Bool, isCorrect: Bool, revealed: Bool) -> Color {
        guard revealed else { return .clear }
        if isCorrect { return DesignSystem.Color.success.opacity(0.12) }
        if isSelected { return DesignSystem.Color.error.opacity(0.12) }
        return .clear
    }
}
