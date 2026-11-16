import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

public struct QuizSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @AppStorage("quiz_answerMode") private var answerMode: QuizAnswerMode = .multipleChoice
    @AppStorage("quiz_comparisonMetric") private var comparisonMetric: ComparisonMetric = .population
    @AppStorage("quiz_showAutocomplete") private var showAutocomplete = false
    @AppStorage("quiz_gameMode") private var selectedGameMode: QuizGameMode = .standard
    @AppStorage("quiz_arcadeTimer") private var selectedArcadeTimer: ArcadeTimer = .sixty

    private let color = DesignSystem.Color.accent

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) { startButton }
    }
}

// MARK: - Subviews
private extension QuizSetupScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                header
                    .padding(.horizontal, DesignSystem.Spacing.md)
                quizTypeSection
                optionsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                regionSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.lg)
            .readableContentWidth()
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: layoutID)
        }
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
                .padding(.horizontal, DesignSystem.Spacing.md)
            TypeSelectionGrid(
                items: QuizType.allCases,
                selectedIDs: [selectedType.id],
                color: color,
                onSelect: { selectedType = $0 }
            )
        }
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
            RegionPicker(selectedRegion: $selectedRegion, color: color)
        }
    }
}

// MARK: - Options
private extension QuizSetupScreen {
    var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Options")
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
        GlassButton("Start \(selectedType.displayName)", systemImage: "play.fill", fullWidth: true) {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            coordinator.cover(PlayRoute.quizSession(makeConfiguration()))
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Helpers
private extension QuizSetupScreen {
    var facts: [GameIntroHeader.Fact] {
        var facts = [GameIntroHeader.Fact(selectedRegion.displayName, systemImage: selectedRegion.regionIcon)]
        switch selectedGameMode {
        case .standard:
            facts.append(GameIntroHeader.Fact("\(selectedCount.rawValue) questions", systemImage: "list.number"))
        case .arcade:
            facts.append(GameIntroHeader.Fact("3 lives", systemImage: "heart.fill"))
            facts.append(GameIntroHeader.Fact(selectedArcadeTimer.rawValue, systemImage: selectedArcadeTimer.icon))
        }
        let mode = effectiveAnswerMode.wrappedValue
        facts.append(GameIntroHeader.Fact(mode.displayName, systemImage: mode.icon))
        return facts
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
