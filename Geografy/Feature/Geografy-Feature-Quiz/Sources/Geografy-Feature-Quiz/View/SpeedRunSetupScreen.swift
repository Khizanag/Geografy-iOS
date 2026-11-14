import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SpeedRunSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @AppStorage("speedrun_selectedRegion") private var selectedRegion: QuizRegion = .world

    private let color = DesignSystem.Color.error

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Speed Run")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) { startButton }
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
                rulesSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
    }

    var header: some View {
        GameIntroHeader(
            title: "Speed Run",
            subtitle: "Name every country in the region, as fast as you can.",
            systemImage: "timer",
            color: color,
            facts: [
                GameIntroHeader.Fact("\(countryCount) countries", systemImage: "flag.fill"),
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
            RegionPicker(selectedRegion: $selectedRegion, color: color)
        }
    }

    var rulesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "How It Works")
            RowListCard(
                Self.rules,
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.iconBadgeWidth)
            ) { rule in
                ruleRow(rule)
            }
        }
    }

    func ruleRow(_ rule: Rule) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge(rule.systemImage, color: color, size: .small)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(rule.title)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(rule.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .rowListCardRow()
        .accessibilityElement(children: .combine)
    }

    var startButton: some View {
        GlassButton("Start Speed Run", systemImage: "bolt.fill", fullWidth: true) {
            hapticsService.impact(.light)
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                coordinator.cover(.speedRunSession(region: selectedRegion))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Rule
private extension SpeedRunSetupScreen {
    struct Rule: Identifiable {
        let title: String
        let subtitle: String
        let systemImage: String

        var id: String { title }
    }

    static let rules = [
        Rule(title: "Type and submit", subtitle: "Type country names one by one", systemImage: "keyboard"),
        Rule(
            title: "Instant feedback",
            subtitle: "Each correct name is ticked off",
            systemImage: "checkmark.circle.fill"
        ),
        Rule(title: "Race the clock", subtitle: "Finish faster for more XP", systemImage: "timer"),
        Rule(title: "Compete", subtitle: "Best times go to Game Center", systemImage: "trophy.fill"),
    ]
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
