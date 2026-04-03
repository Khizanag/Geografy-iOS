#if !os(tvOS)
import Foundation
import Geografy_Core_Common
import Geografy_Core_Service
import Observation
import WidgetKit

@Observable
@MainActor
final class WidgetDataBridge {
    private static let defaults: UserDefaults? = UserDefaults(suiteName: "group.com.khizanag.geografy.dev")
    private static let reloadDebounceInterval: TimeInterval = 2

    private var countryDataService = CountryDataService()
    private var reloadTask: Task<Void, Never>?

    func synchronize(
        streak: Int,
        totalXP: Int,
        level: UserLevel,
        progressFraction: Double,
        visitedCount: Int
    ) async {
        guard let defaults = Self.defaults else { return }

        defaults.set(streak, forKey: "widget_streak")
        defaults.set(totalXP, forKey: "widget_xp")
        defaults.set(level.level, forKey: "widget_level")
        defaults.set(level.title, forKey: "widget_level_title")
        defaults.set(progressFraction, forKey: "widget_progress_fraction")
        defaults.set(visitedCount, forKey: "widget_visited_count")
        defaults.set(197, forKey: "widget_total_countries")

        await writeCountryOfDayIfNeeded(to: defaults)

        scheduleWidgetReload()
    }

    func loadCountriesIfNeeded() async {
        if countryDataService.countries.isEmpty {
            await countryDataService.loadCountries()
        }
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
        if let existing = defaults.string(forKey: "widget_country_of_day_date"),
           existing == todayKey,
           defaults.data(forKey: "widget_country_of_day") != nil {
            return
        }

        guard let country = countryDataService.countryOfTheDay() else { return }

        let data = WidgetCountryData(
            code: country.code,
            name: country.name,
            capital: country.capital,
            continent: country.continent.displayName,
            flagEmoji: country.flagEmoji,
            funFact: funFact(for: country)
        )

        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "widget_country_of_day")
            defaults.set(todayKey, forKey: "widget_country_of_day_date")
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

// MARK: - Shared Data Model
struct WidgetCountryData: Codable {
    let code: String
    let name: String
    let capital: String
    let continent: String
    let flagEmoji: String
    let funFact: String
}
#endif
