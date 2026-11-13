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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @AppStorage("quiz_answerMode") private var answerMode: QuizAnswerMode = .multipleChoice
    @AppStorage("quiz_comparisonMetric") private var comparisonMetric: ComparisonMetric = .population
    @AppStorage("quiz_showAutocomplete") private var showAutocomplete = false
    @AppStorage("quiz_gameMode") private var selectedGameMode: QuizGameMode = .standard
    @AppStorage("quiz_arcadeTimer") private var selectedArcadeTimer: ArcadeTimer = .sixty

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { startButton }
    }
}

// MARK: - Subviews
private extension QuizSetupScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                headerSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                gameModeSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                quizTypeSection

                if selectedType.hasComparisonMetric {
                    metricSection
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .transition(sectionTransition)
                }

                if selectedType.supportedAnswerModes.count > 1 {
                    answerModeSection
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .transition(sectionTransition)
                }

                regionSection

                if selectedGameMode == .standard {
                    questionCountSection
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .transition(sectionTransition)
                }

                timerSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: selectedType)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: selectedGameMode)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: answerMode)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }
}

// MARK: - Header
private extension QuizSetupScreen {
    var gameModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game Mode")

            chipRow(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizGameMode.allCases) { mode in
                    gameModeChip(mode)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    func gameModeChip(_ mode: QuizGameMode) -> some View {
        let isSelected = selectedGameMode == mode
        return Button { selectGameMode(mode) } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: mode.icon)
                    .font(DesignSystem.Font.subheadline)
                    .accessibilityHidden(true)

                Text(mode.rawValue)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)

                Text(mode.description)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(
                        isSelected
                            ? DesignSystem.Color.onAccent.opacity(0.75)
                            : DesignSystem.Color.textSecondary
                    )
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .selectionChipBackground(isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    var timerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Timer")

            chipRow(spacing: DesignSystem.Spacing.sm) {
                ForEach(ArcadeTimer.allCases) { timer in
                    arcadeTimerChip(timer)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    func arcadeTimerChip(_ timer: ArcadeTimer) -> some View {
        let isSelected = selectedArcadeTimer == timer
        return Button { selectArcadeTimer(timer) } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: timer.icon)
                    .font(DesignSystem.Font.caption)
                    .accessibilityHidden(true)
                Text(timer.rawValue)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .selectionChipBackground(isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge(selectedType.icon, size: .large)
                .contentTransition(reduceMotion ? .opacity : .symbolEffect(.replace))
                .accessibilityHidden(true)
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(selectedType.displayName)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                Text(selectedType.description)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .contentTransition(.numericText())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: selectedType)
    }
}

// MARK: - Quiz Type Section
private extension QuizSetupScreen {
    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quiz Type")
                .padding(.horizontal, DesignSystem.Spacing.md)
            TypeSelectionGrid(
                items: QuizType.allCases.map { $0 },
                selectedIDs: [selectedType.id],
                onSelect: { selectedType = $0 }
            )
        }
    }
}

// MARK: - Answer Mode Section
private extension QuizSetupScreen {
    var answerModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Answer Mode")
            chipRow(spacing: DesignSystem.Spacing.sm) {
                ForEach(selectedType.supportedAnswerModes) { mode in
                    modeChip(mode)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            answerModeNote
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: answerMode)
    }

    func modeChip(_ mode: QuizAnswerMode) -> some View {
        let isSelected = answerMode == mode
        return Button { selectAnswerMode(mode) } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: mode.icon)
                    .font(DesignSystem.Font.caption)
                    .accessibilityHidden(true)
                Text(mode.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .selectionChipBackground(isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    var answerModeNote: some View {
        if answerMode == .typing {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                answerModeInfoRow(
                    icon: "star.fill",
                    text: "1.5× XP bonus for typing answers correctly"
                )

                Toggle(isOn: $showAutocomplete) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "text.magnifyingglass")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.accent)
                            .accessibilityHidden(true)

                        Text("Show suggestions")
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                }
                .tint(DesignSystem.Color.accent)
            }
            .transition(sectionTransition)
        } else if answerMode == .spellingBee {
            answerModeInfoRow(
                icon: "textformat.abc",
                text: "Spell the answer letter by letter — 2× XP bonus"
            )
            .transition(sectionTransition)
        }
    }

    func answerModeInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Region Section
private extension QuizSetupScreen {
    var metricSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Metric")

            chipRow(spacing: DesignSystem.Spacing.xs) {
                ForEach(ComparisonMetric.allCases) { metric in
                    metricChip(metric)
                }
            }
        }
    }

    func metricChip(_ metric: ComparisonMetric) -> some View {
        let isSelected = comparisonMetric == metric
        return Button { selectMetric(metric) } label: {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: metric.icon)
                    .font(DesignSystem.Font.caption)
                    .accessibilityHidden(true)

                Text(metric.rawValue)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .selectionChipBackground(isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
                .padding(.horizontal, DesignSystem.Spacing.md)
            #if !os(tvOS)
            RegionCarousel(selectedRegion: $selectedRegion)
            #endif
        }
    }
}

// MARK: - Question Count Section
private extension QuizSetupScreen {
    var questionCountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Questions")
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuestionCount.allCases) { count in
                    countChip(count)
                }
            }
        }
    }

    func countChip(_ count: QuestionCount) -> some View {
        let isSelected = selectedCount == count
        return Button { selectCount(count) } label: {
            Text(count.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .selectionChipBackground(isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Start Button
private extension QuizSetupScreen {
    var startButton: some View {
        GlassButton("Start \(selectedType.displayName)", systemImage: "play.fill", fullWidth: true) {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            coordinator.cover(.quizSession(makeConfiguration()))
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: selectedType)
    }
}

// MARK: - Helpers
private extension QuizSetupScreen {
    var sectionTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top))
    }

    func chipRow<Content: View>(spacing: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))
        return layout(content)
    }

    func hapticSelection() {
        #if !os(tvOS)
        hapticsService.selection()
        #endif
    }

    func selectGameMode(_ mode: QuizGameMode) {
        selectedGameMode = mode
        hapticSelection()
    }

    func selectArcadeTimer(_ timer: ArcadeTimer) {
        selectedArcadeTimer = timer
        hapticSelection()
    }

    func selectAnswerMode(_ mode: QuizAnswerMode) {
        answerMode = mode
        hapticSelection()
    }

    func selectMetric(_ metric: ComparisonMetric) {
        comparisonMetric = metric
        hapticSelection()
    }

    func selectCount(_ count: QuestionCount) {
        selectedCount = count
        hapticSelection()
    }

    func makeConfiguration() -> QuizConfiguration {
        let effectiveAnswerMode = selectedType.supportedAnswerModes.contains(answerMode) ? answerMode : .multipleChoice
        return QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
            answerMode: effectiveAnswerMode,
            comparisonMetric: comparisonMetric,
            gameMode: selectedGameMode,
            arcadeTimer: selectedArcadeTimer,
        )
    }
}
