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
    /// Set when playing against another phone; the match then brings the rounds and its own Give Up.
    let match: (any LocalMatch)?
    /// The host's rounds, in the host's order, when playing a match.
    private let matchRounds: [MapPuzzleRound]

    @State private var questions: [PuzzleQuestion] = []
    @State private var currentIndex = 0
    @State private var checkedAnswer: CheckedAnswer?
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var correctCount = 0
    @State private var showSummary = false
    @State private var outline: ContinentOutline?
    @State private var hasLoaded = false
    @State private var showQuitAlert = false
    @State private var transition = PendingAction()

    private let gameColor = DesignSystem.Color.purple

    init(
        continent: Country.Continent?,
        questionCount: QuestionCount,
        match: (any LocalMatch)? = nil,
        matchRounds: [MapPuzzleRound] = []
    ) {
        self.continent = continent
        self.questionCount = questionCount
        self.match = match
        self.matchRounds = matchRounds
    }

    // MARK: - Body
    var body: some View {
        mainContent
            .screenBackground()
            .navigationTitle(title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbarContent }
            .hideNavigationCloseButton(match == nil && (isPlaying || showSummary))
            .alert("Give Up?", isPresented: $showQuitAlert) {
                Button("Give Up", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Your answers so far won't be saved.")
            }
            .task { await loadMap() }
            .onDisappear { transition.cancel() }
            .answerHaptic(checkedAnswer)
    }
}

// MARK: - Subviews
private extension MapPuzzleScreen {
    @ViewBuilder
    var mainContent: some View {
        if showSummary, let match {
            MatchWaitingCard(opponentName: match.opponentName)
                .padding(DesignSystem.Spacing.md)
                .frame(maxHeight: .infinity)
                .readableContentWidth()
        } else if showSummary {
            MapPuzzleSummaryView(
                correctCount: correctCount,
                questionCount: questions.count,
                onPlayAgain: { reset() },
                onDone: { dismiss() }
            )
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
        if match == nil, isPlaying {
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
                // Only the prompt slides to the next question; the answers stay put and rise in anew, so their
                // glass never travels across the screen.
                mapPrompt(question)
                    .id(question.id)
                    .transition(.nextQuestion(reduceMotion: reduceMotion))
                if let match {
                    opponentChip(match)
                        .padding(.top, DesignSystem.Spacing.sm)
                }
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

    /// The other player's score and whether they've answered this question yet.
    func opponentChip(_ match: any LocalMatch) -> some View {
        let hasAnswered = match.hasOpponentScored(round: currentIndex)
        return MatchOpponentChip(
            name: match.opponentName,
            score: "\(match.opponentScore)/\(questions.count)",
            status: hasAnswered
                ? String(localized: "Answered", bundle: .module)
                : String(localized: "Thinking", bundle: .module),
            systemImage: hasAnswered ? "checkmark.circle.fill" : "ellipsis.circle"
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
        match?.didScore(round: currentIndex, points: isCorrect ? 1 : 0)
        checkedAnswer = AnswerFeedback(soundService: soundService).play(
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
        if let match {
            match.didFinishRounds()
            showSummary = true
            return
        }
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

    /// Only countries drawn on the continent's map can be asked about; a match asks the host's rounds instead, so
    /// both phones see the same countries with the same answers in the same order.
    func buildQuestions() {
        let rounds: [MapPuzzleRound]
        if match != nil {
            rounds = matchRounds
        } else {
            guard let mappedCodes = outline.map({ Set($0.countryPaths.keys) }) else { return }
            let continentCountries = countryDataService.countries.filter { country in
                mappedCodes.contains(country.code) && (continent.map { country.continent == $0 } ?? true)
            }
            rounds = MapPuzzleRules.makeRounds(from: continentCountries, requested: questionCount)
        }
        questions = rounds.compactMap { question(for: $0) }
    }

    /// The answers are names only: a flag would turn the map question into a flag question.
    func question(for round: MapPuzzleRound) -> PuzzleQuestion? {
        guard let country = countryDataService.country(for: round.answerCode) else { return nil }
        let answerID = UUID()
        let options = round.optionCodes.compactMap { code in
            countryDataService.country(for: code).map { option in
                QuizOption(id: code == round.answerCode ? answerID : UUID(), text: option.name)
            }
        }
        return PuzzleQuestion(country: country, options: options, correctOptionID: answerID)
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
}
