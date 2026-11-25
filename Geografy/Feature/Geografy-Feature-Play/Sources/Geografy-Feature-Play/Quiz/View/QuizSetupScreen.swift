import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

/// Sets up a quiz: what it asks, where the countries come from, and how a round plays.
public struct QuizSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @AppStorage("quiz_answerMode") private var answerMode: QuizAnswerMode = .multipleChoice
    @AppStorage("quiz_comparisonMetric") private var comparisonMetric: ComparisonMetric = .population
    @AppStorage("quiz_showAutocomplete") private var showAutocomplete = false
    @AppStorage("quiz_gameMode") private var selectedGameMode: QuizGameMode = .standard
    @AppStorage("quiz_arcadeTimer") private var selectedArcadeTimer: ArcadeTimer = .sixty
    @AppStorage(QuizAnswerAdvance.storageKey) private var answerAdvance: QuizAnswerAdvance = .always

    private let color = DesignSystem.Color.blue

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(.quiz)
            .bottomActionBar { startButton }
    }
}

// MARK: - Subviews
private extension QuizSetupScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                header
                quizTypeSection
                regionSection
                optionsSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: layoutID)
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .sectionScrolling()
    }

    var header: some View {
        GameIntroHeader(
            title: selectedType.displayName,
            subtitle: selectedType.description,
            systemImage: selectedType.icon,
            color: color,
            facts: facts
        )
        .contentTransition(reduceMotion ? .identity : .opacity)
    }

    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quiz Type")
            TypeSelectionGrid(
                items: QuizType.allCases,
                selectedIDs: [selectedType.id],
                color: color,
                layout: .grid,
                onSelect: { selectedType = $0 }
            )
        }
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
                .id(SetupSection.region)
            RegionPicker(selectedRegion: $selectedRegion, color: color)
        }
    }
}

// MARK: - Options
private extension QuizSetupScreen {
    var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game")
                .id(SetupSection.game)
            CardView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    OptionPickerRow(
                        "Game Mode",
                        selection: $selectedGameMode,
                        options: QuizGameMode.allCases,
                        note: selectedGameMode.description,
                        label: \.rawValue
                    )
                    lengthRow
                    answerAdvanceRow
                    if selectedType.supportedAnswerModes.count > 1 {
                        answerModeRows
                    }
                    if selectedType.hasComparisonMetric {
                        OptionPickerRow(
                            "Metric",
                            selection: $comparisonMetric,
                            options: ComparisonMetric.allCases,
                            style: .menu,
                            label: \.rawValue
                        )
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var answerAdvanceRow: some View {
        OptionPickerRow(
            "Next Question",
            selection: $answerAdvance,
            options: QuizAnswerAdvance.allCases,
            note: answerAdvance.description,
            label: \.displayName
        )
    }

    @ViewBuilder
    var lengthRow: some View {
        switch selectedGameMode {
        case .standard:
            OptionPickerRow(
                "Questions",
                selection: $selectedCount,
                options: QuestionCount.allCases,
                label: \.displayName
            )
        case .arcade:
            OptionPickerRow(
                "Timer",
                selection: $selectedArcadeTimer,
                options: ArcadeTimer.allCases,
                label: \.rawValue
            )
        }
    }

    @ViewBuilder
    var answerModeRows: some View {
        OptionPickerRow(
            "Answer Mode",
            selection: effectiveAnswerMode,
            options: selectedType.supportedAnswerModes,
            note: answerModeNote,
            label: \.displayName
        )
        if effectiveAnswerMode.wrappedValue == .typing {
            Toggle("Show suggestions", isOn: $showAutocomplete)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var answerModeNote: String? {
        switch effectiveAnswerMode.wrappedValue {
        case .multipleChoice: nil
        case .typing: "Type each answer for 1.5× XP."
        case .spellingBee: "Spell each answer letter by letter for 2× XP."
        }
    }
}

// MARK: - Start Button
private extension QuizSetupScreen {
    var startButton: some View {
        GlassButton("Start", systemImage: "play.fill", fullWidth: true) {
            coordinator.cover(PlayRoute.quizSession(makeConfiguration()))
        }
    }
}

// MARK: - Helpers
private extension QuizSetupScreen {
    /// Where the countries come from and how long a round lasts; the rest of the setup sits below.
    /// Facts take plain text, so it's looked up in the chosen language here.
    var facts: [GameIntroHeader.Fact] {
        let region = GameIntroHeader.Fact(
            selectedRegion.displayName,
            systemImage: selectedRegion.regionIcon,
            showing: SetupSection.region
        )
        switch selectedGameMode {
        case .standard:
            let questions = String(localized: "\(selectedCount.rawValue) questions", in: locale)
            return [region, GameIntroHeader.Fact(questions, systemImage: "list.number", showing: SetupSection.game)]
        case .arcade:
            let lives = String(localized: "3 lives", in: locale)
            return [
                region,
                GameIntroHeader.Fact(lives, systemImage: "heart.fill", showing: SetupSection.game),
                GameIntroHeader.Fact(
                    selectedArcadeTimer.rawValue,
                    systemImage: selectedArcadeTimer.icon,
                    showing: SetupSection.game
                ),
            ]
        }
    }

    /// The saved answer mode when this quiz type supports it, multiple choice otherwise.
    var effectiveAnswerMode: Binding<QuizAnswerMode> {
        Binding(
            get: { selectedType.supportedAnswerModes.contains(answerMode) ? answerMode : .multipleChoice },
            set: { answerMode = $0 }
        )
    }

    /// Changes whenever a row appears or disappears, so one animation covers every transition.
    var layoutID: String {
        "\(selectedType.rawValue)-\(selectedGameMode.rawValue)-\(effectiveAnswerMode.wrappedValue.rawValue)"
    }

    func makeConfiguration() -> QuizConfiguration {
        QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
            answerMode: effectiveAnswerMode.wrappedValue,
            comparisonMetric: comparisonMetric,
            gameMode: selectedGameMode,
            arcadeTimer: selectedArcadeTimer,
        )
    }
}
