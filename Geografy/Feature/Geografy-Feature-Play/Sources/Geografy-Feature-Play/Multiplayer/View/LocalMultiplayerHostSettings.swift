#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The host's choices in the lobby: the game, then its settings in titled sections, as each game's own setup page
/// lays them out.
struct LocalMultiplayerHostSettings: View {
    // MARK: - Properties
    @Bindable var coordinator: LocalMultiplayerCoordinator

    // MARK: - Body
    var body: some View {
        sections
    }
}

// MARK: - Sections
private extension LocalMultiplayerHostSettings {
    var sections: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            gamePickerSection
            switch coordinator.game {
            case .quiz: quizSettings
            case .mapPuzzle: mapPuzzleSettings
            case .pinDrop: PinDropSettingsSections(configuration: $coordinator.pinDropConfiguration)
            case .speedRun: speedRunSettings
            case .wordSearch: wordSearchSettings
            }
        }
    }

    /// Five games are glyphs, each keeping its name for VoiceOver; the chosen one names the section.
    var gamePickerSection: some View {
        settingsSection(coordinator.game.title) {
            Picker("Game", selection: $coordinator.game) {
                ForEach(LocalGame.allCases) { game in
                    Label(game.title, systemImage: game.systemImage)
                        .labelStyle(.iconOnly)
                        .tag(game)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    func settingsSection(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            content()
        }
    }

    @ViewBuilder
    var quizSettings: some View {
        settingsSection("Quiz Type") {
            TypeSelectionGrid(
                items: QuizType.allCases,
                selectedIDs: [coordinator.quizType.id],
                color: LocalMultiplayerEntryScreen.color,
                layout: .grid,
                onSelect: { coordinator.quizType = $0 }
            )
        }
        settingsSection("Region") {
            RegionPicker(selectedRegion: $coordinator.region, color: LocalMultiplayerEntryScreen.color)
        }
        settingsSection("Game") { matchOptionsCard }
    }

    @ViewBuilder
    var mapPuzzleSettings: some View {
        settingsSection("Region") {
            RegionPicker(
                selection: $coordinator.mapPuzzleContinent,
                regions: [nil] + Country.Continent.allCases.filter { $0 != .antarctica },
                color: LocalMultiplayerEntryScreen.color,
                continent: { $0 }
            )
        }
        settingsSection("Game") {
            CardView {
                OptionPickerRow(
                    "Rounds",
                    selection: $coordinator.mapPuzzleQuestionCount,
                    options: QuestionCount.allCases,
                    label: \.displayName
                )
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var speedRunSettings: some View {
        settingsSection("Region") {
            RegionPicker(selectedRegion: $coordinator.region, color: LocalMultiplayerEntryScreen.color)
        }
    }

    var wordSearchSettings: some View {
        settingsSection("Theme") {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(WordSearchTheme.allCases) { theme in
                    WordSearchThemeTile(theme: theme, isSelected: coordinator.wordSearchTheme == theme) {
                        coordinator.wordSearchTheme = theme
                    }
                }
            }
        }
    }

    var matchOptionsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                OptionPickerRow(
                    "Difficulty",
                    selection: $coordinator.difficulty,
                    options: QuizDifficulty.allCases,
                    label: \.displayName
                )
                OptionPickerRow(
                    "Questions",
                    selection: $coordinator.questionCount,
                    options: QuestionCount.allCases,
                    label: \.displayName
                )
                if coordinator.quizType.hasComparisonMetric {
                    OptionPickerRow(
                        "Metric",
                        selection: $coordinator.comparisonMetric,
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
#endif
