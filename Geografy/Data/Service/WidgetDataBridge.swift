#if !os(tvOS)
import Foundation
import Geografy_Core_Common
import Geografy_Core_Service
import Observation
import WidgetKit

@Observable
@MainActor
final class WidgetDataBridge {
    private static let reloadDebounceInterval: TimeInterval = 2

    private let countryDataService: CountryDataService
    private var reloadTask: Task<Void, Never>?

    init(countryDataService: CountryDataService) {
        self.countryDataService = countryDataService
    }

    func synchronize(
        streak: Int,
        totalXP: Int,
        level: UserLevel,
        progressFraction: Double,
        visitedCount: Int
    ) async {
        guard let defaults = WidgetContract.defaults else { return }

        defaults.set(streak, forKey: WidgetContract.Key.streak)
        defaults.set(totalXP, forKey: WidgetContract.Key.totalXP)
        defaults.set(level.level, forKey: WidgetContract.Key.level)
        defaults.set(level.title, forKey: WidgetContract.Key.levelTitle)
        defaults.set(progressFraction, forKey: WidgetContract.Key.progressFraction)
        defaults.set(visitedCount, forKey: WidgetContract.Key.visitedCount)
        defaults.set(197, forKey: WidgetContract.Key.totalCountries)

        await writeCountryOfDayIfNeeded(to: defaults)

        scheduleWidgetReload()
    }

    func loadCountriesIfNeeded() async {
        await countryDataService.loadCountries()
    }
}

// MARK: - Widget Reload Debounce
private extension WidgetDataBridge {
    func scheduleWidgetReload() {
        reloadTask?.cancel()
        reloadTask = Task {
            try? await Task.sleep(for: .seconds(Self.reloadDebounceInterval))
            guard !Task.isCancelled else { return }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

// MARK: - Country of Day
private extension WidgetDataBridge {
    func writeCountryOfDayIfNeeded(to defaults: UserDefaults) async {
        if countryDataService.countries.isEmpty {
            await countryDataService.loadCountries()
        }

        guard !countryDataService.countries.isEmpty else { return }

        let todayKey = todayDateKey()
        if let existing = defaults.string(forKey: WidgetContract.Key.countryOfDayDate),
           existing == todayKey,
           defaults.data(forKey: WidgetContract.Key.countryOfDay) != nil {
            return
        }

        guard let country = countryDataService.countryOfTheDay() else { return }

        let data = WidgetContract.CountryOfDay(
            code: country.code,
            name: country.name,
            capital: country.capital,
            continent: country.continent.displayName,
            flagEmoji: country.flagEmoji,
            funFact: funFact(for: country)
        )

        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: WidgetContract.Key.countryOfDay)
            defaults.set(todayKey, forKey: WidgetContract.Key.countryOfDayDate)
        }
    }

    func todayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }

    func funFact(for country: Country) -> String {
        let population = country.population.formatPopulation()
        let area = country.area.formatArea()
        return "Population \(population) · \(area)"
    }
}
#endif
