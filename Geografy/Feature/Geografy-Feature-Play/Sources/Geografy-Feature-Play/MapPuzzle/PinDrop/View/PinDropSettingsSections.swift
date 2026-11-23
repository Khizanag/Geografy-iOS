import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Pin Drop's choices: the region, then the rounds, how small the countries get, and whether borders show.
/// The solo setup and the Local Play lobby both use it.
struct PinDropSettingsSections: View {
    // MARK: - Properties
    @Binding var configuration: PinDropConfiguration

    // MARK: - Body
    var body: some View {
        regionSection
        optionsSection
    }
}

// MARK: - Subviews
private extension PinDropSettingsSections {
    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
                .id(SetupSection.region)
            RegionPicker(
                selection: $configuration.region,
                regions: PinDropRegion.allCases,
                color: PinDropStyle.gameColor,
                continent: \.continent
            ) { [difficulty = configuration.difficulty] country in
                country.area >= difficulty.minimumArea
            }
        }
    }

    var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game")
                .id(SetupSection.game)
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    OptionPickerRow(
                        "Rounds",
                        selection: roundOption,
                        options: PinDropConfiguration.roundCounts.map(RoundOption.init)
                    ) { "\($0.count)" }
                    OptionPickerRow(
                        "Countries",
                        selection: $configuration.difficulty,
                        options: PinDropDifficulty.allCases,
                        note: configuration.difficulty == .expert ? "Microstates and islands included" : nil
                    ) { option in
                        switch option {
                        case .standard: "Large"
                        case .expert: "All"
                        }
                    }
                    Divider()
                    bordersToggle
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var bordersToggle: some View {
        Toggle(isOn: $configuration.showsBorders.animation()) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Show Borders")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(
                    configuration.showsBorders
                        ? "Countries are outlined and tinted apart"
                        : "Only coastlines. Harder, with its own record"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .contentTransition(.opacity)
            }
        }
        .tint(PinDropStyle.gameColor)
    }
}

// MARK: - Round Option
private extension PinDropSettingsSections {
    /// A round count as a picker option, which needs to be identifiable.
    struct RoundOption: Hashable, Identifiable {
        let count: Int

        var id: Int { count }
    }

    var roundOption: Binding<RoundOption> {
        Binding {
            RoundOption(count: configuration.roundCount)
        } set: { option in
            configuration.roundCount = option.count
        }
    }
}
