import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SpeedRunSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService

    @AppStorage("speedrun_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage(SpeedRunMap.storageKey) private var showsMap = false

    private let color = DesignSystem.Color.pink

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Speed Run")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(.speedRun)
            .bottomActionBar { startButton }
    }
}

// MARK: - Subviews
private extension SpeedRunSetupScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                header
                personalBestCard
                regionSection
                optionsSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
        .setupSectionScrolling()
    }

    var header: some View {
        GameIntroHeader(
            title: "Speed Run",
            subtitle: "Name every country in the region, as fast as you can.",
            systemImage: "timer",
            color: color,
            facts: [
                GameIntroHeader.Fact(
                    "\(countryCount) countries",
                    systemImage: "flag.fill",
                    showing: SetupSection.region
                ),
                GameIntroHeader.Fact("Typing", systemImage: "keyboard"),
                GameIntroHeader.Fact("+50 XP", systemImage: "star.fill"),
            ]
        )
    }

    var personalBestCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                IconBadge("trophy.fill", color: DesignSystem.Color.warning, size: .medium)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Best in \(selectedRegion.displayName)")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text(personalBestText)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .contentTransition(.numericText())
                }
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
                .id(SetupSection.region)
            RegionPicker(selectedRegion: $selectedRegion, color: color)
        }
    }

    var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game")
                .id(SetupSection.game)
            CardView {
                Toggle(isOn: $showsMap.animation()) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("Show Map")
                            .font(DesignSystem.Font.body)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("Each country fills in on the map as you name it")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                .tint(color)
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var startButton: some View {
        GlassButton("Start Speed Run", systemImage: "bolt.fill", fullWidth: true) {
            // The run covers the screen at once; setup leaves the stack underneath it, so closing the run
            // returns to where Speed Run was opened from.
            coordinator.cover(PlayLocalRoute.speedRunSession(region: selectedRegion))
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { dismiss() }
        }
    }
}

// MARK: - Helpers
private extension SpeedRunSetupScreen {
    var countryCount: Int {
        selectedRegion.filter(countryDataService.countries).count
    }

    var personalBestText: String {
        guard let best = SpeedRunRecords.bestTime(for: selectedRegion) else { return "No time yet" }
        return Duration.seconds(best).formatted(.time(pattern: .minuteSecond))
    }
}
