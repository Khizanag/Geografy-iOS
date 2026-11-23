import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// Names the highlighted country on a continent's map. It plays like a quiz: the map on top, the answers at the
/// bottom, the next question a moment after each answer, and Give Up to leave.
struct MapPuzzleScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(HapticsService.self) private var hapticsService
    @Environment(SoundService.self) private var soundService
    #if !os(tvOS)
    @Environment(XPService.self) private var xpService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache

    @ScaledMetric(relativeTo: .body) private var mapHeight: CGFloat = 220

    /// Nil for the whole world.
    let continent: Country.Continent?
    /// The rounds chosen in setup; a region with fewer countries asks about each of them once.
    let questionCount: QuestionCount

    @State private var questions: [PuzzleQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var correctCount = 0
    @State private var showSummary = false
    @State private var outline: ContinentOutline?
    @State private var hasLoaded = false
    @State private var showQuitAlert = false
    @State private var transition = PendingAction()

    private let gameColor = DesignSystem.Color.purple

    // MARK: - Body
    var body: some View {
        mainContent
            .screenBackground()
            .navigationTitle(title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbarContent }
            .hideNavigationCloseButton(isPlaying || showSummary)
            .alert("Give Up?", isPresented: $showQuitAlert) {
                Button("Give Up", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Your answers so far won't be saved.")
            }
            .task { await loadMap() }
            .onDisappear { transition.cancel() }
    }
}

// MARK: - Subviews
private extension MapPuzzleScreen {
    @ViewBuilder
    var mainContent: some View {
        if showSummary {
            summaryView
        } else if let question = currentQuestion {
            puzzleContent(question)
        } else if hasLoaded {
            EmptyStateView(
                icon: "map",
                title: "Map Unavailable",
                message: "This region's map couldn't be loaded. Pick another region.",
                actionTitle: "Choose a Region"
            ) {
                dismiss()
            }
        } else {
            LoadingView("Building puzzle…")
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if isPlaying {
            ToolbarItem(placement: .topBarLeading) {
                LeaveGameButton { showQuitAlert = true }
            }
        }
    }

    func puzzleContent(_ question: PuzzleQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            progressHeader
            VStack(spacing: 0) {
                Spacer(minLength: DesignSystem.Spacing.md)
                mapPrompt(question)
                Spacer(minLength: DesignSystem.Spacing.lg)
                QuizOptionList(
                    options: question.options,
                    selectedOptionID: selectedOptionID,
                    correctOptionID: question.correctOptionID,
                    showFeedback: showFeedback,
                    onSelect: select
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
            .id(question.id)
            .transition(questionTransition)
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .readableContentWidth()
    }

    var progressHeader: some View {
        SessionProgressView(
            progress: Double(currentIndex) / Double(max(questions.count, 1)),
            current: currentIndex + 1,
            total: questions.count
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    /// The country is shown only by its place on the map; its name and flag appear once it's answered.
    func mapPrompt(_ question: PuzzleQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Which country is highlighted?")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            if let outline {
                ContinentOutlineView(
                    outline: outline,
                    fill: DesignSystem.Color.textTertiary.opacity(DesignSystem.Opacity.half),
                    highlight: ContinentOutlineView.Highlight(countryCode: question.country.code, color: gameColor)
                )
                .frame(height: mapHeight)
                .accessibilityHidden(true)
            }

            answerReveal(question)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: showFeedback)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            showFeedback
                ? "The highlighted country is \(question.country.name)."
                : "Which country is highlighted on the map of \(regionName)?"
        )
    }

    /// Holds its height before the answer, so the map doesn't jump when the name appears.
    func answerReveal(_ question: PuzzleQuestion) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: question.country.code, height: DesignSystem.Size.Flag.inline)
            Text(question.country.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .opacity(showFeedback ? 1 : 0)
        .accessibilityHidden(true)
    }

    var questionTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - Summary
private extension MapPuzzleScreen {
    var summaryView: some View {
        let isPassing = correctCount >= questions.count / 2
        return GameResultLayout(
            title: Text(summaryTitle),
            message: Text("You got \(correctCount) out of \(questions.count) correct"),
            xpEarned: XPRules.mapPuzzle(questions: questions.count, correct: correctCount),
            primaryAction: .playAgain { reset() },
            onDone: { dismiss() },
            hero: {
                IconBadge(
                    isPassing ? "star.fill" : "arrow.counterclockwise",
                    color: isPassing ? DesignSystem.Color.warning : gameColor,
                    size: .hero
                )
                .accessibilityHidden(true)
            },
            stats: { summaryStats }
        )
        .onAppear {
            let announcement = "\(summaryTitle) You got \(correctCount) out of \(questions.count) correct."
            AccessibilityNotification.Announcement(announcement).post()
        }
    }

    @ViewBuilder
    var summaryStats: some View {
        StatTile(
            value: "\(correctCount)",
            label: "Correct",
            icon: "checkmark.circle.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(questions.count - correctCount)",
            label: "Wrong",
            icon: "xmark.circle.fill",
            color: DesignSystem.Color.error
        )
        StatTile(
            value: "\(Int((Double(correctCount) / Double(max(questions.count, 1))) * 100))%",
            label: "Accuracy",
            icon: "chart.bar.fill",
            color: gameColor
        )
    }
}

// MARK: - Actions
private extension MapPuzzleScreen {
    func select(_ optionID: UUID) {
        guard selectedOptionID == nil, let question = currentQuestion else { return }
        selectedOptionID = optionID
        let isCorrect = optionID == question.correctOptionID
        if isCorrect {
            correctCount += 1
        }
        AnswerFeedback(soundService: soundService, hapticsService: hapticsService).play(
            isCorrect: isCorrect,
            announcement: isCorrect ? nil : AnswerFeedback.incorrectAnnouncement(answer: question.country.name)
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }
        transition.schedule(after: AnswerFeedback.revealDuration) { advance() }
    }

    func advance() {
        guard currentIndex + 1 < questions.count else {
            finish()
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            currentIndex += 1
            selectedOptionID = nil
            showFeedback = false
        }
    }

    func finish() {
        #if !os(tvOS)
        xpService.award(
            XPRules.mapPuzzle(questions: questions.count, correct: correctCount),
            source: .mapPuzzleCompleted
        )
        #endif
        showSummary = true
    }

    func loadMap() async {
        if outline == nil {
            let shapes = await geoJSONCache.loadShapes()
            outline = await ContinentOutline.puzzleOutline(for: continent, shapes: shapes)
        }
        buildQuestions()
        hasLoaded = true
    }

    /// Only countries drawn on the continent's map can be asked about. The answers are names only: a flag would
    /// turn the map question into a flag question.
    func buildQuestions() {
        guard let mappedCodes = outline.map({ Set($0.countryPaths.keys) }) else { return }
        let continentCountries = countryDataService.countries.filter { country in
            mappedCodes.contains(country.code) && (continent.map { country.continent == $0 } ?? true)
        }
        let questionCount = MapPuzzleRules.questionCount(
            requested: questionCount,
            countryCount: continentCountries.count
        )
        guard questionCount > 0 else { return }

        questions = continentCountries.shuffled().prefix(questionCount).map { country in
            let pool = continentCountries.filter { $0.code != country.code }.shuffled()
            let others = pool.prefix(MapPuzzleRules.optionsPerQuestion - 1).map { QuizOption(text: $0.name) }
            let answer = QuizOption(text: country.name)
            return PuzzleQuestion(country: country, options: (others + [answer]).shuffled(), correctOptionID: answer.id)
        }
    }

    func reset() {
        transition.cancel()
        currentIndex = 0
        selectedOptionID = nil
        showFeedback = false
        correctCount = 0
        showSummary = false
        buildQuestions()
    }
}

// MARK: - Helpers
private extension MapPuzzleScreen {
    struct PuzzleQuestion: Identifiable {
        let id = UUID()
        let country: Country
        let options: [QuizOption]
        let correctOptionID: UUID
    }

    var currentQuestion: PuzzleQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var title: LocalizedStringKey {
        if let continent {
            "\(continent.displayName) Puzzle"
        } else {
            "World Puzzle"
        }
    }

    var regionName: String {
        continent?.displayName ?? String(localized: "the world", bundle: .module)
    }

    var isPlaying: Bool {
        !showSummary && currentQuestion != nil
    }

    var summaryTitle: String {
        let fraction = Double(correctCount) / Double(max(questions.count, 1))
        return switch fraction {
        case 0.8...: "Excellent!"
        case 0.6..<0.8: "Well Done!"
        case 0.4..<0.6: "Good Try!"
        default: "Keep Practicing!"
        }
    }
}
