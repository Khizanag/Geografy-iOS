import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

// MARK: - Results
extension SpeedRunSessionScreen {
    var resultShare: ResultShare {
        ResultShare(
            game: String(localized: "Speed Run"),
            score: "\(completedCodes.count)/\(targetCountries.count)",
            caption: SpeedRunClock.formatted(elapsedTime),
            fraction: Double(progressFraction),
            details: [ResultShare.Detail(region.displayName, systemImage: "globe")],
            onShare: achievementService.recordShare
        )
    }

    var resultsHero: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            IconBadge("trophy.fill", color: DesignSystem.Color.warning, size: .hero)
                .symbolEffect(.bounce, isActive: !reduceMotion)
                .accessibilityHidden(true)
            Text(SpeedRunClock.formatted(elapsedTime))
                .font(DesignSystem.Font.system(size: resultTimeFontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(DesignSystem.Color.pink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityLabel("Time")
                .accessibilityValue(SpeedRunClock.spokenValue(elapsedTime, isComplete: isComplete))
        }
    }

    @ViewBuilder
    var resultsStats: some View {
        StatTile(
            value: "\(completedCodes.count)",
            label: "Named",
            icon: "checkmark.circle.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(targetCountries.count - completedCodes.count)",
            label: "Missed",
            icon: "xmark.circle.fill",
            color: DesignSystem.Color.error
        )
        StatTile(
            value: "\(Int(progressFraction * 100))%",
            label: "Done",
            icon: "chart.bar.fill",
            color: DesignSystem.Color.blue
        )
    }

    var missedSection: some View {
        countrySection("Missed Countries", icon: "xmark.circle", countries: missedCountries)
    }

    var namedSection: some View {
        countrySection("Named Countries", icon: "checkmark.circle", countries: namedCountries)
    }

    func countrySection(_ title: LocalizedStringKey, icon: String, countries: [Country]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title, icon: icon)

            CountryRowListCard(countries, open: openCountry)
        }
    }
}

// MARK: - Helpers
extension SpeedRunSessionScreen {
    func openCountry(_ country: Country) {
        coordinator.sheet(CountryRoute.countryDetail(country))
    }

    var isComplete: Bool {
        !targetCountries.isEmpty && completedCodes.count == targetCountries.count
    }

    var missedCountries: [Country] {
        targetCountries
            .filter { !completedCodes.contains($0.code) }
            .sorted(by: \.name)
    }

    var namedCountries: [Country] {
        targetCountries
            .filter { completedCodes.contains($0.code) }
            .sorted(by: \.name)
    }

    var progressFraction: CGFloat {
        guard !targetCountries.isEmpty else { return 0 }
        return CGFloat(completedCodes.count) / CGFloat(targetCountries.count)
    }

    var completionMessage: String {
        let fraction = Double(completedCodes.count) / Double(targetCountries.count)
        if fraction >= 1.0 { return "Perfect" }
        if fraction >= 0.8 { return "Impressive" }
        if fraction >= 0.5 { return "Good Run" }
        return "Keep Training"
    }

    var speedRunLeaderboardID: String {
        switch region {
        case .world: GameCenterService.LeaderboardID.speedRunWorld
        case .africa: GameCenterService.LeaderboardID.speedRunAfrica
        case .asia: GameCenterService.LeaderboardID.speedRunAsia
        case .europe: GameCenterService.LeaderboardID.speedRunEurope
        case .northAmerica: GameCenterService.LeaderboardID.speedRunNorthAmerica
        case .southAmerica: GameCenterService.LeaderboardID.speedRunSouthAmerica
        case .oceania: GameCenterService.LeaderboardID.speedRunOceania
        }
    }
}
